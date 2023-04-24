#!/bin/bash
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

hab_pkgs_dir="/hab/pkgs"
hab_cache_dir="/hab/cache"

enforce_purity=${HAB_ENFORCE_PURITY:-1}
# Determine the log level from most generic to most specific environment variable
log_level=${HAB_DEBUG:-${HAB_LD_DEBUG:-${HAB_NATIVE_CROSS_BINUTILS_DEBUG:-0}}}
# Determine the LD_RUN_PATH from most specific to most generic environment variable
ld_run_path=${HAB_NATIVE_CROSS_BINUTILS_LD_RUN_PATH:-${HAB_LD_RUN_PATH:-${LD_RUN_PATH:-""}}}
# The prefix of the current package being built
prefix=${PREFIX:-""}
# Initialize an empty stack
declare -a stack=()
# Global variables representing input file state
is_static=0
is_as_needed=0
is_copy_dt_needed_entries=0
is_dynamically_linked=0
impure_plugin=0
# Array of library directories
declare -a lib_dirs
# Associative array of required libraries indicating if the library is a strong or weak reference.
# 0 - weakly required
# 1 - strongly required
declare -A required_libs
declare -A found_libs
declare -A rpaths

if (("${log_level}" >= 7)); then
	set -x
fi

debug() {
	if (("$log_level" >= 1)); then
		echo "$1" >&2
	fi
}

# Function to print out an associative array
debug_associative_array() {
	declare -n array_ref=$2
	echo "$1:"
	for key in "${!array_ref[@]}"; do
		echo "${key}: ${array_ref[${key}]}"
	done
}

exists_in_ld_run_path() {
	[[ ":$ld_run_path:" == *":$1:"* ]]
}

skip() {
	debug "skipping impure value $1"
}

normalize_path() {
	local dir=$1
	if [[ $dir =~ [/.][/.] || $dir == "." ]]; then
		readlink -f "$dir"
	else
		echo "$dir"
	fi
}

# Checks whether a path is impure.  E.g., `/lib/foo.so' is impure, but
# `/hab/pkgs/.../lib/foo.so' isn't.
is_bad_path() {
	if [ "$enforce_purity" -eq 0 ]; then
		return 1
	fi
	local path=$1

	# Relative paths must be normalized before checking.
	# if [[ $path =~ [/.][/.] || $path == "." ]]; then
	# path=$(readlink -f "$path")
	# fi

	# Otherwise, the path should refer to the store or some temporary
	# directory (including the build directory).
	test \
		"$path" != "/dev/null" -a \
		"${path#"${hab_pkgs_dir}"}" = "$path" -a \
		"${path#"${hab_cache_dir}"}" = "$path" -a \
		"${path#/tmp}" = "$path" -a \
		"${path#"${TMP:-/tmp}"}" = "$path" -a \
		"${path#"${TMPDIR:-/tmp}"}" = "$path" -a \
		"${path#"${TEMP:-/tmp}"}" = "$path" -a \
		"${path#"${TEMPDIR:-/tmp}"}" = "$path"
}

# Combine the three flag values into a single numeric value
encode_flags() {
	local static_flag=$1
	local as_needed_flag=$2
	local copy_dt_needed_flag=$3
	local encoded=$(((static_flag << 2) | (as_needed_flag << 1) | copy_dt_needed_flag))
	echo "${encoded}"
}

# Extract the three flag values from the encoded numeric value
decode_flags() {
	local encoded=$1
	local static_flag=$(((encoded >> 2) & 1))
	local as_needed_flag=$(((encoded >> 1) & 1))
	local copy_dt_needed_flag=$((encoded & 1))
	echo "${static_flag}, ${as_needed_flag}, ${copy_dt_needed_flag}"
}

encode_lib_flags() {
	encode_flags "${is_static}" "${is_as_needed}" "${is_copy_dt_needed_entries}"
}

decode_lib_flags() {
	local encoded=$1
	IFS=', ' read -r is_static is_as_needed is_copy_dt_needed_entries <<<"$(decode_flags "${encoded}")"
}

# Push the current flag values onto the stack
push_flags() {
	local encoded=$(encode_flags "${is_static}" "${is_as_needed}" "${is_copy_dt_needed_entries}")
	stack+=("${encoded}")
}

# Pop flag values off the stack and restore the global variables
pop_flags() {
	if [ ${#stack[@]} -gt 0 ]; then
		local encoded="${stack[-1]}"
		unset 'stack[-1]'
		stack=("${stack[@]}") # Re-index the array
		IFS=', ' read -r is_static is_as_needed is_copy_dt_needed_entries <<<"$(decode_flags "${encoded}")"
	else
		echo "Error: Stack is empty."
		exit 1
	fi
}

declare -a params=("$@")
declare -i params_count=${#params[@]}
declare -i param_index=0
declare -a rest=()

debug "original flags to @program@:"
debug "$(printf "  %q\n" ${params+"${params[@]}"})"
# Parse all lib directories
# Parse all libraries with reference info
# Remove impure library paths, libraries and linker

# Go through each directory
# - Search for library
#   - if found and library is

prev_param=
while (("$param_index" < "$params_count")); do
	current_param=${params[param_index]}
	next_param=${params[param_index + 1]-} # handle `next_param` being last one
	skip_param=0
	case "$current_param" in
	-dynamic-linker)
		linker="$next_param"
		if is_bad_path "$linker"; then
			param_index+=1
			skip_param=1
			skip "$linker passed via $current_param"
		fi
		;;
	-dynamic-linker=*)
		linker="${current_param#-dynamic-linker=*}"
		if is_bad_path "$linker"; then
			skip_param=1
			skip "$linker passed via $current_param"
		fi
		;;
	-plugin)
		plugin="$next_param"
		if is_bad_path "$plugin"; then
			param_index+=1
			skip_param=1
			impure_plugin=1
			skip "$plugin passed via $current_param"
		else
			impure_plugin=0
		fi
		;;
	-plugin=*)
		plugin="${current_param#-plugin=*}"
		if is_bad_path "$plugin"; then
			param_index+=1
			skip_param=1
			impure_plugin=1
			skip "$plugin passed via $current_param"
		else
			impure_plugin=0
		fi
		;;
	-plugin-opt)
		plugin_opt="$next_param"
		if [[ $impure_plugin -eq 1 ]]; then
			param_index+=1
			skip_param=1
			skip "$plugin_opt passed via $current_param, due to last plugin being impure"
		fi
		;;
	-plugin-opt=*)
		plugin_opt="${current_param#-plugin-opt=*}"
		if [[ $impure_plugin -eq 1 ]]; then
			skip_param=1
			skip "$plugin_opt passed via $current_param, due to last plugin being impure"
		fi
		;;
	# TODO: is this needed?
	--no-dynamic-linker)
		is_dynamically_linked=0
		;;
	-Bstatic | -dn | -non_shared | -static)
		is_static=1
		;;
	-Bdynamic | -dy | -call_shared)
		is_static=0
		;;
	--as-needed)
		is_as_needed=1
		;;
	--no-as-needed)
		is_as_needed=0
		;;
	--copy-dt-needed-entries)
		is_copy_dt_needed_entries=1
		;;
	--no-copy-dt-needed-entries)
		is_copy_dt_needed_entries=0
		;;
	--push-state)
		push_flags
		;;
	--pop-state)
		pop_flags
		;;
	-o | --output | -h | -soname)
		# Ignore these parameters as it's the name of the output shared library.
		# If we don't ignore it, the script might pick it up as a shared library to be
		# linked into the output.
		;;
	-rpath)
		# We track rpaths that are already specified after normalizing them
		# to avoid adding duplicate or unneccsary rpath entries
		rpath=$(normalize_path "$next_param")
		rpaths["${rpath}"]=0
		;;
	-rpath=)
		# We track rpaths that are already specified after normalizing them
		# to avoid adding duplicate or unneccsary rpath entries
		rpath="${current_param#-rpath=*}"
		rpath=$(normalize_path "$rpath")
		rpaths["${rpath}"]=0
		;;
	-R | --just-symbols)
		rpath=$(normalize_path "$next_param")
		# The linker only adds the value passed to -R/--just-symbols as an rpath
		# if the path is not a file. It doesn't actually care that the value is
		# actually an existing directory.
		if [ ! -f "$rpath" ]; then
			rpaths["${rpath}"]=0
		fi
		;;
	-R?* | --just-symbols=*)
		rpath="${current_param#--just-symbols=*}"
		rpath="${rpath#-R*}"
		rpath=$(normalize_path "$rpath")
		# The linker only adds the value passed to -R/--just-symbols as an rpath
		# if the path is not a file. It doesn't actually care that the value is
		# actually an existing directory.
		if [ ! -f "$rpath" ]; then
			rpaths["${rpath}"]=0
		fi
		;;
	# Search for library directories specified as '-L/path/to/lib' or '--library-path=/path/to/lib'
	-L?* | --library-path=*)
		lib_dir="${current_param#--library-path=*}"
		lib_dir="${lib_dir#-L*}"
		lib_dir=$(normalize_path "$lib_dir")
		if is_bad_path "$lib_dir"; then
			skip_param=1
			skip "$lib_dir passed via $current_param"
		else
			lib_dirs+=("$lib_dir")
		fi
		;;
	# Search for library directories specified as '-L /path/to/lib' or '--library-path /path/to/lib'
	-L | --library-path)
		lib_dir="$next_param"
		if is_bad_path "$lib_dir"; then
			param_index+=1
			skip_param=1
			skip "$lib_dir passed via $current_param"
		else
			lib_dirs+=("$lib_dir")
		fi
		;;
	# Search for libraries specified as '-lx' or '--library=x'
	# x might be specified as ':y'(exact name) or 'y'(search for static or shared library)
	-l?* | --library=*)
		lib="${current_param#--library=*}"
		lib="${lib#-l*}"
		case $lib in
		# exact name
		:*)
			required_libs[$lib]=$(encode_lib_flags)
			;;
		*)
			# should search for static lib
			if [[ is_static -eq 1 ]]; then
				required_libs[$lib]=$(encode_lib_flags)
			# should search for dynamic lib
			else
				required_libs[$lib]=$(encode_lib_flags)
			fi
			;;
		esac
		;;
	# Search for libraries specified as '-l x' or '--library=x'
	# x might be specified as ':y'(exact name) or 'y'(search for static or shared library)
	-l | --library)
		lib="$next_param"
		case $lib in
		# exact name
		:*)
			required_libs[$lib]=$(encode_lib_flags)
			;;
		*)
			# should search for static lib
			if [[ is_static -eq 1 ]]; then
				required_libs[$lib]=$(encode_lib_flags)
			# should search for dynamic lib
			else
				required_libs[$lib]=$(encode_lib_flags)
			fi
			;;
		esac
		;;
	/*.so | /*.so.*)
		case $prev_param in
		-plugin | -dynamic-linker)
			# ignore this as it's not a shared library to be linked
			;;
		*)
			lib=":${current_param##*/}"
			lib_dir="${current_param%/*}"
			required_libs[$lib]=$(encode_lib_flags)
			lib_dirs+=("$lib_dir")
			;;
		esac
		;;
	/*)
		if is_bad_path "$current_param"; then
			skip_param=1
			skip "$current_param used in link"
		fi
		;;
	*) ;;
	esac
	if [[ $skip_param -eq 0 ]]; then
		rest+=("$current_param")
	fi
	param_index+=1
	prev_param="$current_param"
done

# Old bash empty array hack
params=(${rest+"${rest[@]}"})

debug "final flags to @program@:"
debug "$(printf "  %q\n" ${params+"${params[@]}"})"

extra_after=()
extra_before=()
for lib_dir in ${lib_dirs+"${lib_dirs[@]}"}; do
	lib_dir=$(normalize_path "$lib_dir")
	# If we have already searched the directory skip it
	if [[ ${rpaths[$lib_dir]-} -eq 1 ]]; then
		continue
	fi
	for required_lib in "${!required_libs[@]}"; do
		lib_flags=${required_libs[$required_lib]}
		decode_lib_flags "$lib_flags"
		case $required_lib in
		:*)
			lib_file="${required_lib##:}"
			debug "Searching for $lib_file in $lib_dir"
			if [ -f "$lib_dir/$lib_file" ]; then
				found_libs[$required_lib]="$lib_dir/$lib_file"
			fi
			;;
		*)
			if [ "$is_static" -eq 1 ]; then
				lib_file="lib${required_lib}.a"
				if [ -f "$lib_dir/$lib_file" ]; then
					found_libs[$required_lib]="$lib_dir/$lib_file"
				fi
			else
				lib_file="lib${required_lib}.so"
				if [ -f "$lib_dir/$lib_file" ]; then
					found_libs[$required_lib]="$lib_dir/$lib_file"
					if [ "${rpaths[$lib_dir]:-1}" -ne 0 ]; then
						if [ "$is_as_needed" -eq 1 ]; then
							if exists_in_ld_run_path $lib_dir; then
								extra_after+=("-rpath $lib_dir")
							fi
						else
							extra_after+=("-rpath $lib_dir")
						fi
					fi
				else
					lib_file="lib${required_lib}.a"
					if [ -f "$lib_dir/$lib_file" ]; then
						found_libs[$required_lib]="$lib_dir/$lib_file"
					fi
				fi
			fi
			;;
		esac
	done
	rpaths[$lib_dir]=1
done

debug "lib_dirs: ${lib_dirs+"${lib_dirs[@]}"}"
debug "$(debug_associative_array "required_libs" required_libs)"
debug "$(debug_associative_array "found_libs" found_libs)"
debug "$(debug_associative_array "rpaths" rpaths)"
debug "is_dynamically_linked: $is_dynamically_linked"
debug "extra_after: ${extra_after+"${extra_after[@]}"}"

exit 1

# Add all used dynamic libraries to the rpath.
if [[ $linkType != static-pie && -n $HAB_NATIVE_CROSS_BINUTILS_LD_RUN_PATH ]]; then
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
			if [[ ${libs[$lib]} == 2 && ":$HAB_NATIVE_CROSS_BINUTILS_LD_RUN_PATH:" == *":$dir:"* ]]; then
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
		IFS=: read -r -d '' -a ldPathArray < <(printf '%s:\0' "$HAB_NATIVE_CROSS_BINUTILS_LD_RUN_PATH")
		for dir in ${ldPathArray+"${ldPathArray[@]}"}; do
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
if (("${HAB_NATIVE_CROSS_BINUTILS_DEBUG}" >= 1)); then
	echo "env PREFIX=${PREFIX-}" >&2
	echo "env HAB_LINK_TYPE=${HAB_LINK_TYPE-}" >&2
	echo "env LD_RUN_PATH=${LD_RUN_PATH-}" >&2
	echo "env HAB_LD_RUN_PATH=${HAB_LD_RUN_PATH-}" >&2
	echo "env HAB_NATIVE_CROSS_BINUTILS_LD_RUN_PATH=${HAB_NATIVE_CROSS_BINUTILS_LD_RUN_PATH-}" >&2
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
