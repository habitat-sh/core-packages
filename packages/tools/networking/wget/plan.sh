program="wget"

pkg_name="wget"
pkg_origin="core"
pkg_version="1.21.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Wget is a free software package for retrieving files using HTTP, HTTPS, \
FTP and FTPS the most widely-used Internet protocols.\
"
pkg_upstream_url="https://www.gnu.org/software/wget/"
pkg_license=('GPL-3.0+')
pkg_source="https://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="5726bb8bc5ca0f6dc7110f6416e4bb7019e2d2ff5bf93d1ca2ffcc6656f220e5"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/openssl
	core/libidn2
	core/libpsl
	core/libpcre2
	core/zlib
)

pkg_build_deps=(
	core/coreutils
	core/gcc
	core/gettext
	core/grep
	core/make
	core/pkg-config
	core/sed
	core/build-tools-perl
)

pkg_bin_dirs=(bin)

do_prepare() {
	# Purge the codebase (mostly tests & build Perl scripts) of the hardcoded
	# reliance on `/usr/bin/env`.
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_path_for coreutils)/bin/env,g" -i "$f"
	done
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-ssl=openssl
	make -j"$(nproc)"
}

do_check() {
	make check
}
