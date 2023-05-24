pkg_name="git"
pkg_version="2.33.1"
pkg_origin="core"
pkg_description="Git is a free and open source distributed version control
  system designed to handle everything from small to very large projects with
  speed and efficiency."
pkg_upstream_url="https://git-scm.com/"
pkg_license=('GPL-2.0-only' 'LGPL-2.1-only')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://www.kernel.org/pub/software/scm/git/${pkg_name}-${pkg_version}.tar.gz"
pkg_filename="${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="02047f8dc8934d57ff5e02aadd8a2fe8e0bcf94a7158da375e48086cc46fce1d"
pkg_deps=(
	core/bash
	core/cacerts
	core/curl
	core/expat
	core/gettext
	core/glibc
	core/openssh
	core/openssl
	core/perl
	core/sed
	core/zlib
	core/python
)
pkg_build_deps=(
	core/gcc
	core/texinfo
	core/pkg-config
)
pkg_bin_dirs=(bin)

do_prepare() {
	local perl_path
	perl_path="$(pkg_path_for perl)/bin/perl"
	sed -e "s#/usr/bin/perl#$perl_path#g" -i Makefile
}

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--with-gitconfig=/etc/gitconfig \
		--with-perl="$(pkg_path_for perl)/bin/perl" \
		--with-python="$(pkg_path_for python)/bin/python3" \
		--with-shell="$(pkg_path_for bash)/bin/sh" \
		--with-zlib="$(pkg_path_for zlib)" \
		--with-openssl \
		--with-libpcre

	make -j"$(nproc)"
}

do_check() {
	make test
}

do_install() {
	make install
}
