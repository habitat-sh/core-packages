pkg_name="libgpg-error"
pkg_origin="core"
pkg_version="1.43"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Libgpg-error is a small library that originally \
defined common error values for all GnuPG components."
pkg_upstream_url="https://www.gnupg.org/software/libgpg-error/index.html"
pkg_license=('GPL-2.0-or-later')
pkg_source="https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${pkg_version}.tar.bz2"
pkg_shasum="a9ab83ca7acc442a5bd846a75b920285ff79bdb4e3d34aa382be88ed2c3aebaf"

pkg_build_deps=(
	core/gcc
	core/readline
)
pkg_deps=(
	core/glibc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--enable-shared \
		--enable-install-gpg-error-config \
		--enable-werror \
		--with-libiconv-prefix=$(pkg-path-for core/libiconv) \
		--with-readline=$(pkg_path_for core/readline)
	make
}

do_check() {
	make check
}
