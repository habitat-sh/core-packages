program="diffutils"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-diffutils"
pkg_origin="core"
pkg_version="3.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Diffutils is a package of several programs related to finding differences \
between files.\
"
pkg_upstream_url="https://www.gnu.org/software/diffutils"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="a6bdd7d1b31266d11c4f4de6c1b748d4607ab0231af5188fc2533d0ae2438fec"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
    core/build-tools-glibc
)
pkg_build_deps=(
    core/native-cross-gcc
)
pkg_bin_dirs=(bin)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --build="$(build-aux/config.guess)" \
        --host="$native_target" \
        --target="$native_target"
    make
}
