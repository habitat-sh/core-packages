program="libxtst"
pkg_name="libxtst"
pkg_distname=libXtst
pkg_origin=core
pkg_version=1.2.4
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X.Org Libraries: libXtst"
pkg_upstream_url="https://www.x.org/"
pkg_license=('HPND' 'HPND-sell-variant' 'MIT-open-group' 'X11')
pkg_source="https://www.x.org/releases/individual/lib/${pkg_distname}-${pkg_version}.tar.xz"
pkg_shasum="84f5f30b9254b4ffee14b5b0940e2622153b0d3aed8286a3c5b7eeb340ca33c8"
pkg_deps=(
	core/glibc 
	core/xlib 
	core/libxcb 
	core/libxau 
	core/libxdmcp 
	core/libxext 
	core/libxi
)
pkg_build_deps=(
	core/gcc 
	core/make 
	core/pkg-config 
	core/xproto 
	core/kbproto 
	core/renderproto 
	core/inputproto 
	core/xextproto 
	core/libpthread-stubs 
	core/libxfixes 
	core/fixesproto 
	core/recordproto
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)
pkg_dirname="${pkg_distname}-${pkg_version}"

do_check() {
  make check
}
