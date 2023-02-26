pkg_name="libassuan"
pkg_origin="core"
pkg_version="2.5.5"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Libassuan is a small library implementing the so-called Assuan protocol."
pkg_upstream_url="https://www.gnupg.org/software/libassuan/index.html"
pkg_license=('LGPL-2.0-or-later')
pkg_source="https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.5.tar.bz2"
pkg_shasum="8e8c2fcc982f9ca67dcbb1d95e2dc746b1739a4668bc20b3a3c5be632edb34e4"

pkg_deps=(
	core/glibc
	core/libgpg-error
)
pkg_build_deps=(
	core/make
	core/gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-libgpg-error-prefix="$(pkg_path_for libgpg-error)" \
		--enable-static \
		--enable-shared
	make
}

do_check() {
	make check
}
