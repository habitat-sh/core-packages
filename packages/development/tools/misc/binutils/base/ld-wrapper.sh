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

set -eu -o pipefail +o posix
shopt -s nullglob

HAB_BINUTILS_DEBUG=${HAB_DEBUG:-${HAB_LD_DEBUG:-${HAB_BINUTILS_DEBUG:-0}}}
HAB_BINUTILS_LD_RUN_PATH=${HAB_BINUTILS_LD_RUN_PATH:-${HAB_LD_RUN_PATH:-${LD_RUN_PATH:-""}}}
PREFIX=${PREFIX:-""}

if (("${HAB_BINUTILS_DEBUG}" >= 7)); then
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

normalizePath() {
	local dir=$1
	if [[ $dir =~ [/.][/.] || $dir == "." ]] && dir2=$(readlink -f "$dir"); then
		dir="$dir2"
	fi
	echo "$dir"
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
		if [[ $arg == @* ]]; then
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
	p2=${params[n + 1]-} # handle `p` being last one
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

# Find all library directorys, librariers and rpaths specified
declare -a libDirs
declare -A libs
declare -A rpaths

prev=
# Old bash thinks empty arrays are undefined, ugh.
for p in \
	${extraBefore+"${extraBefore[@]}"} \
	${params+"${params[@]}"} \
	${extraAfter+"${extraAfter[@]}"}; do
	case "$prev" in
	-o | --output | -h | -soname)
		# Ignore these parameters as it's the name of the output shared library.
		# If we don't ignore it, the script might pick it up as a shared library to be
		# linked into the output.
		;;
	-L | --library-path)
		libDirs+=("$p")
		;;
	-l | --library)
		libs["-l${p}"]=1
		;;
	-rpath)
		# We track rpaths that are already specified after normalizing them
		# to avoid adding duplicate or unneccary rpath entries
		rpath=$(normalizePath "$p")
		rpaths["${rpath}"]=0
		;;
	-R | --just-symbols)
		rpath=$(normalizePath "$p")
		# The linker only adds the value passed to -R/--just-symbols as an rpath
		# if the path is not a file. It doesn't actually care that the value is
		# actually an existing directory.
		if [ ! -f "$rpath" ]; then
			rpaths["${rpath}"]=0
		fi
		;;
	-dynamic-linker | -plugin)
		# Ignore this argument, or it will match *.so and be added to rpath.
		;;
	*)
		# Process all the different forms of specifying the arguments
		# in the same manner as the above cases
		case "$p" in
		--output=* | -h?* | -soname=*)
			# Ignore these parameters as it's the name of the output shared library.
			# If we don't ignore it, the script might pick it up as a shared library to be
			# linked into the output.
			;;
		-L?*)
			libDirs+=("${p:2}")
			;;
		--library-path=*)
			libDirs+=("${p#"--library-path="}")
			;;
		-l?*)
			libs["-l${p:2}"]=1
			;;
		--library=*)
			libs["-l${p#"--library="}"]=1
			;;
		-R?*)
			rpath=$(normalizePath "${p:2}")
			if [ ! -f "$rpath" ]; then
				rpaths["${rpath}"]=0
			fi
			;;
		-rpath=*)
			rpath=$(normalizePath "${p#"-rpath="}")
			if [ ! -f "$rpath" ]; then
				rpaths["${rpath}"]=0
			fi
			;;
		--just-symbols=*)
			rpath=$(normalizePath "${p#"--just-symbols="}")
			if [ ! -f "$rpath" ]; then
				rpaths["${rpath}"]=0
			fi
			;;
		"${HAB_PKGS-}"/*.so | "${HAB_PKGS-}"/*.so.*)
			# This is a direct reference to a shared library in another package.
			libDirs+=("${p%/*}")
			libs["${p##*/}"]=1
			;;
		*.so | *.so.*)
			# This is possibly a direct reference to a shared library
			case "$p" in
			-*)
				# This is a shared library passed as an argument to some other paramater
				;;
			*)
				# This is a shared library reference
				libs["${p##*/}"]=1
				;;
			esac
			;;
		*) ;;
		esac
		;;
	esac
	prev="$p"
done

# Add all used dynamic libraries to the rpath.
if [[ $linkType != static-pie && -n $HAB_BINUTILS_LD_RUN_PATH ]]; then
	# For each directory in the library search path (-L...),
	# see if it contains a dynamic library used by a -l... flag.  If
	# so, add the directory to the rpath.
	# It's important to add the rpath in the order of -L..., so
	# the link time chosen objects will be those of runtime linking.
	for dir in ${libDirs+"${libDirs[@]}"}; do
		# Normalize relative paths
		dir=$(normalizePath "$dir")

		# There may be duplicate library folder entries, if we have already
		# added the directory we skip it
		if [[ ${rpaths[$dir]-} -eq 1 ]]; then
			continue
		fi

		addDir=0
		for lib in "${!libs[@]}"; do
			# If we already found the library, no need to search for it
			if [[ ${libs[$lib]} -gt 1 ]]; then
				continue
			fi
			case $lib in
			-l:*.a)
				# Check if the exact static library exists
				if [ -f "$dir/${lib##-l:}" ]; then
					libs[$lib]=3
				fi
				;;
			-l:*.so | -l:*.so.*)
				# Check if the exact shared library exists
				if [[ -f "$dir/${lib##-l:}" && $dir == "${HAB_PKGS-}"/* ]]; then
					libs[$lib]=2
				fi
				;;
			-l*)
				# Check if the shared library exists
				if [ -f "$dir/lib${lib##-l}.so" ]; then
					# Check that it is within a hab package
					if [[ $dir == "${HAB_PKGS-}"/* ]]; then
						libs[$lib]=2
					fi
				elif [ -f "$dir/lib${lib##-l}.a" ]; then
					# Check if the static library exists
					libs[$lib]=3
				fi
				;;
			*)
				if [[ -f "$dir/$lib" && $dir == "${HAB_PKGS-}"/* ]]; then
					libs[$lib]=2
				fi
				;;
			esac
			# If the directory is present in the LD_RUN_PATH and it's a shared library we add it to the rpath
			if [[ ${libs[$lib]} == 2 && ":$HAB_BINUTILS_LD_RUN_PATH:" == *":$dir:"* ]]; then
				addDir=1
			fi
		done
		# Only add the directory if it is a hab folder, otherwise we violate purity
		# We do still want to check these directories for libraries to determine if we
		# need to add lib directories that are children of the prefix dir to the rpath
		if [[ $addDir == 1 && ${rpaths[$dir]:-1} -ne 0 ]]; then
			rpaths["$dir"]=1
			extraAfter+=(-rpath "$dir")
		fi
	done

	# Check if we have found all shared libraries
	missingLibs=0
	for lib in "${!libs[@]}"; do
		if [[ ${libs[$lib]} -eq 1 ]]; then
			missingLibs=1
			break
		fi
	done

	# Check and add the library paths of the current package if
	# present in the current packages and we have missing shared libraries
	if [[ -n $PREFIX && $missingLibs == 1 ]]; then
		IFS=: read -r -d '' -a ldPathArray < <(printf '%s:\0' "$HAB_BINUTILS_LD_RUN_PATH")
		for dir in "${ldPathArray[@]}"; do
			if [ -n "${rpaths[$dir]-}" ] || [[ $dir != "${HAB_PKGS-}"/* ]]; then
				# If the path is not in the hab packages, don't add it to the rpath.
				continue
			fi
			if [[ $dir =~ ^$PREFIX ]]; then
				rpaths["$dir"]=1
				extraAfter+=(-rpath "$dir")
			fi
		done
	fi
fi

# Optionally print debug info.
if (("${HAB_BINUTILS_DEBUG}" >= 1)); then
	echo "env PREFIX=${PREFIX-}" >&2
	echo "env HAB_LINK_TYPE=${HAB_LINK_TYPE-}" >&2
	echo "env LD_RUN_PATH=${LD_RUN_PATH-}" >&2
	echo "env HAB_LD_RUN_PATH=${HAB_LD_RUN_PATH-}" >&2
	echo "env HAB_BINUTILS_LD_RUN_PATH=${HAB_BINUTILS_LD_RUN_PATH-}" >&2
	echo "extra flags before to @program@:" >&2
	printf "  %q\n" ${extraBefore+"${extraBefore[@]}"} >&2
	echo "original flags to @program@:" >&2
	printf "  %q\n" ${params+"${params[@]}"} >&2
	echo "extra flags after to @program@:" >&2
	printf "  %q\n" ${extraAfter+"${extraAfter[@]}"} >&2
fi

## Unset the LD_RUN_PATH so that it doesn't influence the linker
unset LD_RUN_PATH

# Old bash workaround, see above.
@program@ \
	${extraBefore+"${extraBefore[@]}"} \
	${params+"${params[@]}"} \
	${extraAfter+"${extraAfter[@]}"}
