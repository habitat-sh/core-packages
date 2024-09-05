pkg_name=pango
pkg_origin=core
pkg_version="1.54.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('LGPL-2.0-only')
pkg_upstream_url="http://www.pango.org"
pkg_description="Pango is a library for laying out and rendering of text, with an emphasis on internationalization."
pkg_source="https://download.gnome.org/sources/pango/${pkg_version%.*}/pango-${pkg_version}.tar.xz"
pkg_shasum="8a9eed75021ee734d7fc0fdf3a65c3bba51dfefe4ae51a9b414a60c70b2d1ed8"
pkg_filename=${pkg_name}-${pkg_version}.tar.xz

pkg_deps=(
  #core/glib
  core/glibc
  core/fontconfig
  core/freetype
  core/cairo
  core/harfbuzz
  core/expat
  
  #core/libpng
  #core/xproto
  #core/libxau
  #core/libxcb
  #core/libxdmcp  
)
pkg_build_deps=(
  core/gcc
  core/cmake
  core/pkg-config
  core/fribidi
  core/python
  core/meson
  core/ninja
  core/git
  core/libxml2
  core/zlib
  core/libpng
  core/pixman
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
  export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/

  meson subprojects update

  meson setup builddir --prefix=${pkg_prefix} \
    --buildtype=release \
    -Ddocumentation=false \
    -Dbuild-testsuite=false \
    -Dbuild-examples=false \
    -Dintrospection="disabled" \
    -Dlibthai="disabled" \
    -Dxft="disabled"

  ninja -C builddir
}

do_install() {
  ninja -C builddir install
}

do_check() {
  ninja -C builddir test
}