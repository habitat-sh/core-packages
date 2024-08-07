pkg_name=pixman
pkg_origin=core
pkg_version="0.43.4"
pkg_description="A low-level software library for pixel manipulation"
pkg_license=("MIT")
pkg_upstream_url="http://pixman.org/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://www.cairographics.org/releases/pixman-${pkg_version}.tar.gz"
pkg_shasum="a0624db90180c7ddb79fc7a9151093dc37c646d8c38d3f232f767cf64b85a226"

pkg_deps=(
    core/glibc
)
pkg_build_deps=(
    core/gcc
    core/make
    core/cmake
    core/pkg-config
    core/meson
    core/ninja
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
    export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/
    meson setup build --prefix=${pkg_prefix}
    ninja -C build
}

do_check() {
    ninja -C build test
}

do_install() {
    ninja -C build install
}