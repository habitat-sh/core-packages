program="gcc"

pkg_name="gcc-stage0"
pkg_origin="core"
pkg_version="9.4.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems. This package is a wrapper around the build-tools-gcc package with
additional configuration to link against core/glibc instead of core/build-tools-glibc.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')

pkg_deps=(
	core/glibc-stage0
	core/build-tools-gcc
	core/linux-headers
)

do_prepare() {
	local libc
	local linux_headers

	libc="$(pkg_path_for glibc-stage0)"
	linux_headers="$(pkg_path_for linux-headers)"
	case $pkg_target in
	aarch64-linux)
		set_runtime_env "HAB_BUILD_TOOLS_GCC_DYNAMIC_LINKER" "${libc}/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-linux)
		set_runtime_env "HAB_BUILD_TOOLS_GCC_DYNAMIC_LINKER" "${libc}/lib/ld-linux-x86-64.so.2"
		;;
	esac
	set_runtime_env "HAB_BUILD_TOOLS_GCC_C_START_FILES" "${libc}/lib"
	set_runtime_env "HAB_BUILD_TOOLS_GCC_C_STD_LIBS" "${libc}/lib"
	set_runtime_env "HAB_BUILD_TOOLS_GCC_C_STD_HEADERS" "${libc}/include:${linux_headers}/include"
}

do_build() {
	return 0
}

do_install() {
	return 0
}
