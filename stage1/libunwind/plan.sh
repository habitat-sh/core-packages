program="libunwind"

pkg_name="libunwind-stage1"
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
	core/glibc-stage0
	core/gcc-libs-stage1
	core/xz-stage0
)
pkg_build_deps=(
	core/gcc-stage1
	core/zlib-stage0
	core/build-tools-coreutils
	core/build-tools-gawk
	core/build-tools-grep
	core/build-tools-make
	core/build-tools-sed
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_check() {
	make check
}
