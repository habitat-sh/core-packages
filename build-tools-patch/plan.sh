app_name="patch"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-patch"
pkg_origin="core"
pkg_version="2.7.6"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Patch takes a patch file containing a difference listing produced by the diff \
program and applies those differences to one or more original files, producing \
patched versions.\
"
pkg_upstream_url="https://www.gnu.org/software/patch/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${app_name}/${app_name}-${pkg_version}.tar.xz"
pkg_shasum="ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd"
pkg_dirname="${app_name}-${pkg_version}"

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
        --host="$native_target"

    make
}

do_check() {
    make check
}
