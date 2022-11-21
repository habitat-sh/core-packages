#!@bash@
# shellcheck disable=SC2206,2068
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
# project, specifically in the `cc-wrapper` package. For more details, see:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/cc-wrapper/cc-wrapper.sh
#
# # Environment Variables
#
# There is one environment variables that is consumed by this program:
#
# * `$HAB_DEBUG` (*Optional*): If set, this program will output the original and
#    extra flags added to standard error
#

# # Main program

# Fail whenever a command returns a non-zero exit code.
set -e

HAB_GCC_DEBUG=${HAB_DEBUG:-${HAB_GCC_DEBUG:-0}}

: "${HAB_GCC_BINUTILS_BIN_PATH:=@binutils@}"
: "${HAB_GCC_GLIBC_PKG_PATH:=@glibc@}"
: "${HAB_GCC_GLIBC_DYNAMIC_LINKER:=@dynamic_linker@}"
: "${HAB_GCC_LINUX_HEADERS_PKG_PATH:=@linux_headers@}"

# Force gcc to use our ld wrapper from binutils when calling `ld`
extraAfterFlags="$extraAfterFlags -B${HAB_GCC_BINUTILS_BIN_PATH}"

# Figure out if linker flags should be passed.  GCC prints annoying
# warnings when they are not needed.
dontLink=0
linkType="dynamic"
nonFlagArgs=0
cxxLibrary=1
cInclude=1
startFilesInclude=1

params=("$@")

declare -i n=0
nParams=${#params[@]}
# Determine is we add dynamic linker arguments to the extra arguments by
# looking at the calling arguments to this program. This may not work 100% of
# the time, but it has shown to be fairly reliable
while (("$n" < "$nParams")); do
	p=${params[n]}
	p2=${params[n + 1]:-} # handle `p` being last one
	n+=1

	case "$p" in
	-[cSEM] | -MM) dontLink=1 ;;
	-nostdinc) cInclude=0 ;;
	-nostdlib) cxxLibrary=0 ;;
	-nostartfiles) startFilesInclude=0 ;;
	-static) linkType="static" ;;
	-static-pie) linkType="static-pie" ;;
	-x)
		case "$p2" in
		*-header) dontLink=1 ;;
		esac
		;;
	-?*) ;;
	*) nonFlagArgs=1 ;; # Includes a solitary dash (`-`) which signifies standard input; it is not a flag
	esac
done

# If we pass a flag like -Wl, then gcc will call the linker unless it
# can figure out that it has to do something else (e.g., because of a
# "-c" flag).  So if no non-flag arguments are given, don't pass any
# linker flags.  This catches cases like "gcc" (should just print
# "gcc: no input files") and "gcc -v" (should print the version).
if [ "$nonFlagArgs" = 0 ]; then
	dontLink=1
fi

# Add the path to the C runtime start files if they are required
if [[ "$startFilesInclude" = 1 ]]; then
	extraAfterFlags="$extraAfterFlags -B${HAB_GCC_GLIBC_PKG_PATH}/lib/"
fi

if [[ "$cxxLibrary" = 1 ]]; then
	extraAfterFlags="$extraAfterFlags -L${HAB_GCC_GLIBC_PKG_PATH}/lib"
fi

if [[ "$cInclude" = 1 ]]; then
	extraAfterFlags="$extraAfterFlags -idirafter ${HAB_GCC_GLIBC_PKG_PATH}/include"
	extraAfterFlags="$extraAfterFlags -idirafter ${HAB_GCC_LINUX_HEADERS_PKG_PATH}/include"
fi

# Add the flags for the C compiler proper.
extraBefore=()
extraAfter=($extraAfterFlags)

if [ "$dontLink" != 1 ]; then
	if [[ "$linkType" = "dynamic" ]]; then
		extraBefore+=("-Wl,-dynamic-linker=${HAB_GCC_GLIBC_DYNAMIC_LINKER}")
	fi
	export HAB_LINK_TYPE=${linkType}
fi

# As a very special hack, if the arguments are just `-v', then don't
# add anything.  This is to prevent `gcc -v' (which normally prints
# out the version number and returns exit code 0) from printing out
# `No input files specified' and returning exit code 1.
if [ "$*" = -v ]; then
	extraAfter=()
	extraBefore=()
fi

# Optionally print debug info.
if (("${HAB_GCC_DEBUG}" >= 1)); then
	echo "original flags to @program@:" >&2
	for i in "${params[@]}"; do
		echo "  $i" >&2
	done
	echo "extraBefore flags to @program@:" >&2
	for i in ${extraBefore[@]}; do
		echo "  $i" >&2
	done
	echo "extraAfter flags to @program@:" >&2
	for i in ${extraAfter[@]}; do
		echo "  $i" >&2
	done
fi

# Become the underlying real program
exec @program@ ${extraBefore[@]} "${params[@]}" "${extraAfter[@]}"
