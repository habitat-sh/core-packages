program="gcc"

pkg_name="gcc-stage1-with-glibc"
pkg_origin="core"
pkg_version="9.4.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
This is wrapper package that ensures gcc-stage1 uses the core/glibc as the
C library for compiling other stage1 dependencies\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/gcc-stage1
	core/glibc
	core/linux-headers
)

do_prepare() {
	local libc
	local linux_headers

	# Change the dynamic linker and glibc library to link against core/glibc
	libc=$(pkg_path_for glibc)
	linux_headers="$(pkg_path_for linux-headers)"
	case $pkg_target in
	aarch64-linux)
		dynamic_linker="${libc}/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-linux)
		dynamic_linker="${libc}/lib/ld-linux-x86-64.so.2"
		;;
	esac

	set_runtime_env "HAB_GCC_STAGE1_DYNAMIC_LINKER" "${dynamic_linker}"
	set_runtime_env "HAB_GCC_STAGE1_C_START_FILES" "${libc}/lib"
	set_runtime_env "HAB_GCC_STAGE1_C_STD_LIBS" "${libc}/lib"
	set_runtime_env "HAB_GCC_STAGE1_C_STD_HEADERS" "${libc}/include:${linux_headers}/include"
}

do_build() {
	return 0
}

do_install() {
	return 0
}

do_strip() {
	return 0
}
