program="zlib"
pkg_name="build-tools-zlib"
pkg_origin="core"
pkg_version="1.2.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Compression library implementing the deflate compression method found in gzip and PKZIP"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://zlib.net/fossils/${program}-${pkg_version}.tar.gz"
pkg_shasum="91844808532e5ce316b3c010929493c0244f3d37593afd6de04f71821d5136d9"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
	       --prefix="$pkg_prefix"
	make
}

do_check() {
	make check
}

do_install() {
	make install
}
