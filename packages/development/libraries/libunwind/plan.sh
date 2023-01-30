program="libunwind"

pkg_name="libunwind"
pkg_origin="core"
pkg_version="1.6.2"
pkg_description="A C programming interface to determine the call-chain of a program."
# additional package info at https://github.com/libunwind/libunwind
pkg_upstream_url="http://www.nongnu.org/libunwind/"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://download.savannah.nongnu.org/releases/libunwind/libunwind-${pkg_version}.tar.gz"
pkg_shasum="4a6aec666991fb45d0889c44aede8ad6eb108071c3554fcdff671f9c94794976"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/xz
)
pkg_build_deps=(
	core/coreutils
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
	core/zlib
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	CFLAGS="-g -fexceptions ${CFLAGS}"
	export CFLAGS
	build_line "Updating CFLAGS=${CFLAGS}"
}

do_check() {
	make check
}