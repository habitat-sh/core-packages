#!@bash@
#
# # Usage
#
# ```
# $ @program@ [ARG ..]
# ```
#
# # Synopsis
#
# This program takes the place of
# @program@
# so that additional options can be added before invoking it.
#
# The idea and implementation which this is based upon is thanks to the nixpkgs
# project, specifically in the `ld-wrapper` package. For more details, see:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/bintools-wrapper/ld-wrapper.sh
#
# # Environment Variables
#
# There is one environment variables that is consumed by this program:
#
# * `$HAB_DEBUG`, `$HAB_LD_DEBUG`, `$HAB_BINUTILS_STAGE0_DEBUG` (*Optional*): If one of these is set,
#    this program will output the original and extra flags added to standard error
#

# # Main program
set -eu -o pipefail +o posix
shopt -s nullglob

HAB_BINUTILS_STAGE0_DEBUG=${HAB_DEBUG:-${HAB_LD_DEBUG:-${HAB_BINUTILS_STAGE0_DEBUG:-0}}}

if (("${HAB_BINUTILS_STAGE0_DEBUG}" >= 7)); then
	set -x
fi

HAB_PKGS="/hab/pkgs"
HAB_CACHE="/hab/cache"

# This is copy of the wrapper script utilities used by nix: https://github.com/NixOS/nixpkgs/blob/350fd0044447ae8712392c6b212a18bdf2433e71/pkgs/build-support/wrapper-common/utils.bash
skip() {
	if (("${HAB_DEBUG:-0}" >= 1)); then
		echo "skipping impure path $1" >&2
	fi
}

# Checks whether a path is impure.  E.g., `/lib/foo.so' is impure, but
# `/hab/pkgs/.../lib/foo.so' isn't.
badPath() {
	local p=$1

	# Relative paths are okay (since they're presumably relative to
	# the temporary build directory).
	if [ "${p:0:1}" != / ]; then return 1; fi

	# Otherwise, the path should refer to the store or some temporary
	# directory (including the build directory).
	test \
		"$p" != "/dev/null" -a \
		"${p#${HAB_PKGS}}" = "$p" -a \
		"${p#${HAB_CACHE}}" = "$p" -a \
		"${p#/tmp}" = "$p" -a \
		"${p#${TMP:-/tmp}}" = "$p" -a \
		"${p#${TMPDIR:-/tmp}}" = "$p" -a \
		"${p#${TEMP:-/tmp}}" = "$p" -a \
		"${p#${TEMPDIR:-/tmp}}" = "$p"
}

expandResponseParams() {
	declare -ga params=("$@")
	local arg
	for arg in "$@"; do
		if [[ "$arg" == @* ]]; then
			# phase separation makes this look useless
			# shellcheck disable=SC2157
			if [ -x "@expandResponseParams@" ]; then
				# params is used by caller
				#shellcheck disable=SC2034
				readarray -d '' params < <("@expandResponseParams@" "$@")
				return 0
			fi
		fi
	done
}

# Optionally filter out paths not refering to the store.
expandResponseParams "$@"

linkType=${HAB_LINK_TYPE:-"dynamic"}

# Verify that all library paths are from hab packages
rest=()
nParams=${#params[@]}
declare -i n=0

while (("$n" < "$nParams")); do
	p=${params[n]}
	p2=${params[n + 1]:-} # handle `p` being last one
	if [ "${p:0:3}" = -L/ ] && badPath "${p:2}"; then
		skip "${p:2} passed via -L"
	elif [ "$p" = -L ] && badPath "$p2"; then
		n+=1
		skip "$p2 passed via -L"
	elif [ "$p" = -rpath ] && badPath "$p2"; then
		n+=1
		skip "$p2 passed via -rpath"
	elif [ "$p" = -dynamic-linker ] && badPath "$p2"; then
		n+=1
		skip "$p2 passed via -dynamic-linker"
	elif [ "${p:0:1}" = / ] && badPath "$p"; then
		# We cannot skip this; barf.
		echo "impure path \`$p' used in link" >&2
		exit 1
	elif [ "${p:0:9}" = --sysroot ]; then
		# Our ld is not built with sysroot support (Can we fix that?)
		:
	else
		rest+=("$p")
	fi
	n+=1
done
# Old bash empty array hack
params=(${rest+"${rest[@]}"})

extraAfter=()
extraBefore=()

# Find all -L... switches for rpath
declare -a libDirs
declare -A libs

prev=
# Old bash thinks empty arrays are undefined, ugh.
for p in \
	${extraBefore+"${extraBefore[@]}"} \
	${params+"${params[@]}"} \
	${extraAfter+"${extraAfter[@]}"}; do
	case "$prev" in
	-L)
		libDirs+=("$p")
		;;
	-l)
		libs["lib${p}.so"]=1
		;;
	-dynamic-linker | -plugin)
		# Ignore this argument, or it will match *.so and be added to rpath.
		;;
	*)
		case "$p" in
		-L/*)
			libDirs+=("${p:2}")
			;;
		-l?*)
			libs["lib${p:2}.so"]=1
			;;
		"${HAB_PKGS:-}"/*.so | "${HAB_PKGS:-}"/*.so.*)
			# This is a direct reference to a shared library in another package.
			libDirs+=("${p%/*}")
			libs["${p##*/}"]=1
			;;
		*) ;;

		esac
		;;
	esac
	prev="$p"
done

# Add all used dynamic libraries to the rpath.
if [[ "$linkType" != static-pie ]]; then
	# For each directory in the library search path (-L...),
	# see if it contains a dynamic library used by a -l... flag.  If
	# so, add the directory to the rpath.
	# It's important to add the rpath in the order of -L..., so
	# the link time chosen objects will be those of runtime linking.
	declare -A rpaths
	for dir in ${libDirs+"${libDirs[@]}"}; do
		# Normalize relative paths
		if [[ "$dir" =~ [/.][/.] ]] && dir2=$(readlink -f "$dir"); then
			dir="$dir2"
		fi
		if [ -n "${rpaths[$dir]:-}" ] || [[ "$dir" != "${HAB_PKGS:-}"/* ]]; then
			# If the path is not in the hab packages, don't add it to the rpath.
			# This typically happens for libraries in /hab/cache/* that are later
			# copied to $pkg_prefix.  If not, we're screwed.
			continue
		fi
		for path in "$dir"/*; do
			file="${path##*/}"
			if [ "${libs[$file]:-}" ]; then
				rpaths["$dir"]=1
				extraAfter+=(-rpath "$dir")
				break
			fi
		done
	done

fi

# Optionally print debug info.
if (("${HAB_BINUTILS_STAGE0_DEBUG}" >= 1)); then
	# Old bash workaround, see above.
	echo "extra flags before to @program@:" >&2
	printf "  %q\n" ${extraBefore+"${extraBefore[@]}"} >&2
	echo "original flags to @program@:" >&2
	printf "  %q\n" ${params+"${params[@]}"} >&2
	echo "extra flags after to @program@:" >&2
	printf "  %q\n" ${extraAfter+"${extraAfter[@]}"} >&2
fi

# Old bash workaround, see above.
@program@ \
	${extraBefore+"${extraBefore[@]}"} \
	${params+"${params[@]}"} \
	${extraAfter+"${extraAfter[@]}"}
