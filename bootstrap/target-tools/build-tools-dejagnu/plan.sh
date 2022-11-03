program="dejagnu"
pkg_name="build-tools-dejagnu"
pkg_origin="core"
pkg_version="1.6.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description=""
pkg_upstream_url="https://www.gnu.org/software/dejagnu/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="87daefacd7958b4a69f88c6856dbd1634261963c414079d0c371f589cd66a2e3"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)

do_build() {
    mkdir -v build
    pushd build || exit 1

    "../configure" \
        --prefix="$pkg_prefix" \

    make

    popd >/dev/null || exit 1
}

do_check() {
	pushd build || exit 1

	make check

	popd >/dev/null || exit 1
}

do_install() {
    pushd build || exit 1
    make install
    popd >/dev/null || exit 1
}
