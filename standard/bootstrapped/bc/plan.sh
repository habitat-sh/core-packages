pkg_name="bc"
pkg_origin="core"
pkg_version="6.0.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
bc is an arbitrary precision numeric processing language. Syntax is similar \
to C, but differs in many substantial areas. It supports interactive \
execution of statements. bc is a utility included in the POSIX P1003.2/D11 \
draft standard.\
"
pkg_upstream_url="https://git.yzena.com/gavin/bc"
pkg_license=("BSD-2-Clause")
pkg_source="https://github.com/gavinhoward/bc/releases/download/${pkg_version}/bc-${pkg_version}.tar.xz"
pkg_shasum="d1d8bd3c2bb4ec0f00aed9c14f2f1a1ed32343f3235bac1822cd18971ad130d3"

pkg_deps=(
    core/glibc
    core/readline
)
pkg_build_deps=(
    core/gcc-bootstrap
    core/build-tools-make
    core/build-tools-bash
    core/build-tools-coreutils
    core/build-tools-patchelf
)
pkg_bin_dirs=(bin)

do_prepare() {
    export CC="gcc"
}

do_build() {
    ./configure --prefix="${pkg_prefix}" -G -O3 -r
    make
}

do_check() {
    make test
}

do_install() {
    make install

    patchelf --shrink-rpath "${pkg_prefix}/bin/bc"
    patchelf --shrink-rpath "${pkg_prefix}/bin/dc"
}
