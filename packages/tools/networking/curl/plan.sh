pkg_name="curl"
pkg_origin="core"
pkg_version="8.7.1"
pkg_description="curl is an open source command line tool and library for
  transferring data with URL syntax."
pkg_upstream_url="https://curl.haxx.se/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('curl')
pkg_source="https://curl.haxx.se/download/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="f91249c87f68ea00cf27c44fdfa5a78423e41e71b7d408e5901a9896d905c495"
pkg_deps=(
	core/cacerts
	core/glibc
	core/openssl
	core/zlib
	core/zstd
	core/nghttp2
	core/libidn2
	core/libpsl
	core/coreutils
)
pkg_build_deps=(
	core/gcc
	core/perl
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# Patch the zsh-generating program to use our perl at build time
	sed -i "s,/usr/bin/env/perl,$(pkg_path_for perl)/bin/perl,g" scripts/completion.pl

	# Replace /usr/bin/env with our coreutils env in scripts prior to build
    grep -lr '/usr/bin/env' . | while read -r f; do
		fix_interpreter "$f" core/coreutils bin/env
	done

	# Stop configuration warnings due to incorrect use of CFLAGS and CXXFLAGS
	unset CFLAGS
	unset CXXFLAGS
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-ca-bundle="$(pkg_path_for cacerts)/ssl/certs/cacert.pem" \
		--with-openssl \
		--disable-manual \
		--disable-ldap \
		--disable-ldaps \
		--disable-rtsp \
		--enable-proxy \
		--enable-optimize \
		--disable-dependency-tracking \
		--enable-ipv6 \
		--without-gnutls \
		--without-librtmp
	make
}

do_install () {
	do_default_install

	# copy license files to package
	install -Dm644 ${CACHE_PATH}/COPYING ${pkg_prefix}
}
