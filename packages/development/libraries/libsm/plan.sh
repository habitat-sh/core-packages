program=libsm
pkg_name=libsm
pkg_distname=libSM
pkg_origin=core
pkg_version=1.2.4
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X11 Session Management library"
pkg_upstream_url="https://www.x.org/"
pkg_license=('MIT')
pkg_source="https://www.x.org/releases/individual/lib/${pkg_distname}-${pkg_version}.tar.xz"
pkg_shasum="fdcbe51e4d1276b1183da77a8a4e74a137ca203e0bcfb20972dd5f3347e97b84"
pkg_deps=(
	core/glibc
	core/libice
)
pkg_build_deps=(
	core/gcc
	core/make
	core/pkg-config
	core/xproto
	core/xtrans
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_check() {
    make check
}
