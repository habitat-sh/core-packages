pkg_name=libxcursor
pkg_distname=libXcursor
pkg_origin=core
pkg_version=1.2.0
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X11 miscellaneous extensions library"
pkg_upstream_url="https://www.x.org/"
pkg_license=('MIT')
pkg_source="https://www.x.org/releases/individual/lib/${pkg_distname}-${pkg_version}.tar.bz2"
pkg_shasum="3ad3e9f8251094af6fe8cb4afcf63e28df504d46bfa5a5529db74a505d628782"
pkg_deps=(
  core/glibc
  core/libxau
  core/libxcb
  core/libxdmcp
  core/libxfixes
  core/libxrender
  core/xlib
)
pkg_build_deps=(
  core/fixesproto
  core/gcc
  core/kbproto
  core/libpthread-stubs
  core/make
  core/pkg-config
  core/renderproto
  core/util-macros
  core/xextproto
  core/xproto
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)
