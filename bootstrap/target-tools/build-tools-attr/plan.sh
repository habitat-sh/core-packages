program="attr"
pkg_name="build-tools-attr"
pkg_origin="core"
pkg_version="2.5.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Commands for Manipulating Filesystem Extended Attributes."
pkg_upstream_url="https://savannah.nongnu.org/projects/attr/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://download.savannah.gnu.org/releases/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="bae1c6949b258a0d68001367ce0c741cebdacdd3b62965d17e5eb23cd78adaf8"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
)

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
	--disable-static \
	--docdir="$pkg_prefix"/share/doc/attr-2.5.1

    make
}

do_check() {
	make check
}

do_install() {
    make install
}
