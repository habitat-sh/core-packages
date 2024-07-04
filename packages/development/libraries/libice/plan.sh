program=libice
pkg_name=libice
pkg_distname=libICE
pkg_origin=core
pkg_version=1.1.1
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X11 Inter-Client Exchange library"
pkg_upstream_url="https://www.x.org/"
pkg_license=('MIT')
pkg_source="https://www.x.org/releases/individual/lib/${pkg_distname}-${pkg_version}.tar.xz"
pkg_shasum="03e77afaf72942c7ac02ccebb19034e6e20f456dcf8dddadfeb572aa5ad3e451"
pkg_deps=(core/glibc)
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
