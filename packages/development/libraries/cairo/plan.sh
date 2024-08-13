pkg_name=cairo
pkg_origin=core
pkg_version="1.18.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('LGPL-2.1-only' 'GPL-3.0-only' 'MPL-1.1')
pkg_source="https://www.cairographics.org/releases/${pkg_name}-${pkg_version}.tar.xz"
pkg_description="Cairo is a 2D graphics library with support for multiple output devices."
pkg_upstream_url="https://www.cairographics.org"
pkg_shasum="243a0736b978a33dee29f9cca7521733b78a65b5418206fef7bd1c3d4cf10b64"

pkg_deps=(
  core/freetype
  core/glibc
  core/libice
  core/libpng
  core/pixman
  core/zlib
)
pkg_build_deps=(
  core/fontconfig
  core/pkg-config
  core/xextproto
  core/xproto
  core/meson
  core/ninja
  core/python
  core/sed
  core/gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(
  include
  include/cairo
)
pkg_lib_dirs=(
  lib
  lib/cairo
)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
  export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/

  sed -e "s,/usr/bin/env python3,$(pkg_path_for python)/bin/python,g" -i "${CACHE_PATH}/version.py"
  meson setup builddir --prefix=${pkg_prefix} --buildtype=release
  ninja -C builddir
}

do_install() {
  ninja -C builddir install

  find "${pkg_prefix}/lib" -type f -name "*.so*" -exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;
}

do_check() {
  meson test -C builddir -v cairo
}
