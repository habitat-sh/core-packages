program="acl"
pkg_name="build-tools-acl"
pkg_origin="core"
pkg_version="2.3.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Commands for Manipulating POSIX Access Control Lists."
pkg_upstream_url="https://savannah.nongnu.org/projects/acl"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://download.savannah.gnu.org/releases/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum=""
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
)

pkg_build_deps=(
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
	--disable-static \
	--docdir="$pkg_prefix"/share/doc/acl-2.3.1

    make
}

do_check() {
	make check
}

do_install() {
    make install
}
