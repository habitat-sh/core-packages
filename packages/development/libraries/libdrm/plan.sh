pkg_name=libdrm
pkg_origin=core
pkg_version="2.4.122"
pkg_description="Direct Rendering Manager"
pkg_upstream_url="https://dri.freedesktop.org/wiki/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('')
pkg_source="https://dri.freedesktop.org/${pkg_name}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="d9f5079b777dffca9300ccc56b10a93588cdfbc9dde2fae111940dfb6292f251"

pkg_deps=(
  core/glibc
)

pkg_build_deps=(
  core/gcc
  core/libxslt
  core/meson
  core/ninja
  core/pkg-config
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
  export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/
  meson build --prefix="${pkg_prefix}"
  meson configure build -Dprefix="${pkg_prefix}"
}

do_install() {
  ninja -C build install
}

do_check() {
  meson test -C build
}