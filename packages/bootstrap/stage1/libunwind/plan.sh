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
pkg_shasum="7194c20dda841b26917c0579e6467b53f7ad2e3f9452e5c77f3c3829c4656b70"
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
