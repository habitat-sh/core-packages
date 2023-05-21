program="libunwind"

pkg_name="libunwind-stage1"
pkg_origin="core"
pkg_version="1.6.0"
pkg_description="A C programming interface to determine the call-chain of a program."
# additional package info at https://github.com/libunwind/libunwind
pkg_upstream_url="http://www.nongnu.org/libunwind/"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://download.savannah.nongnu.org/releases/libunwind/libunwind-${pkg_version}.tar.gz"
pkg_shasum="205f41997c4e17d8e25966601c924e4ad93e6a3576bf59b6baa3eadababa6a5f"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc-stage0
	core/gcc-libs-stage1
	core/xz-stage0
)
pkg_build_deps=(
	core/gcc-stage1
	core/zlib-stage0
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_check() {
	make check
}
