program="gzip"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-gzip"
pkg_origin="core"
pkg_version="1.11"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Gzip is a popular data compression program originally written by Jean-loup \
Gailly for the GNU project.\
"
pkg_upstream_url="https://www.gnu.org/software/gzip/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="9b9a95d68fdcb936849a4d6fada8bf8686cddf58b9b26c9c4289ed0c92a77907"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
    core/build-tools-glibc
    core/build-tools-grep
)
pkg_build_deps=(
    core/native-cross-gcc
)
pkg_bin_dirs=(bin)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --host="$native_target"
}

do_check() {
    make check
}
