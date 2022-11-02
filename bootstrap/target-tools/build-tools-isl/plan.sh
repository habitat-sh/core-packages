program="isl"
pkg_name="build-tools-isl"
pkg_origin="core"
pkg_version="0.25"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="ISL is a library for manipulating sets and relations of integer points bounded by linear constraints."
pkg_upstream_url="https://libisl.sourceforge.io"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://libisl.sourceforge.io/${program}-${pkg_version}.tar.gz"
pkg_shasum="acac270b41f6a533cbe5cf26463877ed5e4107051a5457b9d50b58576a59c6c5"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
)

pkg_build_deps=(
	core/build-tools-gcc
	core/build-tools-gmp
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
	--disable-static \
	--docdir=$pkg_prefix/share/doc/isl-0.25

    make
}

do_check() {
	make check
}

do_install() {
    make install
}
