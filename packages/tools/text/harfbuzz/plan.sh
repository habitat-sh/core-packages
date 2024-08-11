pkg_name=harfbuzz
pkg_origin=core
pkg_version="9.0.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT' 'MIT-Modern-Variant' 'OFL-1.1-no-RFN')
#https://www.freedesktop.org/wiki/Software/HarfBuzz/
pkg_upstream_url="http://harfbuzz.org/"
pkg_description="HarfBuzz is an OpenType text shaping engine"
pkg_source="https://github.com/harfbuzz/harfbuzz/archive/refs/tags/${pkg_version}.tar.gz"
pkg_shasum="b7e481b109d19aefdba31e9f5888aa0cdfbe7608fed9a43494c060ce1f8a34d2"

pkg_deps=(
  core/coreutils
  core/freetype
  core/glib
  core/cairo
  core/icu
  core/glibc
)
pkg_build_deps=(
  core/meson
  core/gcc
  core/make
  core/cmake
  core/pkg-config
  core/ninja
  core/sed
  core/python
  core/patchelf
)

pkg_include_dirs=(include/harfbuzz)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
  export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/

  find "${CACHE_PATH}/src" -type f -name "*.py" -exec sed -e "s,/usr/bin/env python3,$(pkg_path_for python)/bin/python,g" -i {} \;

  meson setup builddir --prefix=${pkg_prefix} --buildtype=release -D tests=disabled -D docs=disabled

  ninja -C builddir  
}

do_install() {
  ninja -C builddir install

  patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/lib/libharfbuzz.so.0.60900.0
  patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/lib/libharfbuzz-subset.so.0.60900.0
  patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/lib/libharfbuzz-icu.so.0.60900.0
}

do_check() {
  meson test -C builddir
}