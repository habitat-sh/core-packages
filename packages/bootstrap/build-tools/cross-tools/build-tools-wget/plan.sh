program="wget"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-wget"
pkg_origin="core"
pkg_version="1.21.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Wget is a free software package for retrieving files using HTTP, HTTPS, \
FTP and FTPS the most widely-used Internet protocols.\
"
pkg_upstream_url="https://www.gnu.org/software/wget/"
pkg_license=('GPL-3.0-or-later')
pkg_source="https://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="e6d4c76be82c676dd7e8c61a29b2ac8510ae108a810b5d1d18fc9a1d2c9a2497"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/build-tools-glibc
	core/build-tools-openssl
)

pkg_build_deps=(
	core/native-cross-gcc
	core/build-tools-coreutils
)

pkg_bin_dirs=(bin)

do_prepare() {
	# Purge the codebase (mostly tests & build Perl scripts) of the hardcoded
	# reliance on `/usr/bin/env`.
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_path_for build-tools-coreutils)/bin/env,g" -i "$f"
	done
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--host="$native_target" \
		--with-ssl=openssl \
		--without-zlib
	make -j"$(nproc)"
}
