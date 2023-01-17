pkg_name="libidn2"
pkg_origin="core"
pkg_version="2.3.3"
pkg_description="Implementation of IDNA2008, Punycode and TR46 (Internationalized domain names)"
pkg_upstream_url="https://www.gnu.org/software/libidn/#libidn2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0' 'LGPL-3.0')
pkg_source="https://ftp.gnu.org/gnu/libidn/libidn2-${pkg_version}.tar.gz"
pkg_shasum="f3ac987522c00d33d44b323cae424e2cffcb4c63c6aa6cd1376edacbf1c36eb0"
pkg_deps=(
	core/glibc
	core/libunistring
)
pkg_build_deps=(
	core/diffutils
	core/gcc
	core/gettext
	core/make
	core/pkg-config
	core/valgrind-stage1
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_check() {
	make check
}
