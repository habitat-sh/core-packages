program="patchelf"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-patchelf"
pkg_origin="core"
pkg_version="0.15.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
A small utility to modify the dynamic linker and RPATH of ELF executables.\
"
pkg_upstream_url="https://nixos.org/patchelf.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="https://github.com/NixOS/patchelf/archive/refs/tags/${pkg_version}.tar.gz"
pkg_shasum="5d1eda9bad4439bb9c0a87fcba198d7c0d372f361e77de41d68d6308062e5000"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
    core/build-tools-glibc
    core/build-tools-libstdcpp
)

pkg_build_deps=(
    core/native-cross-gcc
)

pkg_bin_dirs=(bin)

# updating build steps with v0.13
do_build() {
    ./bootstrap.sh
    ./configure \
        --prefix="$pkg_prefix" \
        --build="$(build-aux/config.guess)" \
        --host="$native_target"
    make
}

do_check() {
    make check
}

do_install() {
    build_line "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/src/${program}"
    build_line "${pkg_prefix}/bin/"
    cp "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/src/${program}" "${pkg_prefix}/bin/"
}
