pkg_name="curl"
pkg_origin="core"
pkg_version="7.87.0"
pkg_description="curl is an open source command line tool and library for
  transferring data with URL syntax."
pkg_upstream_url="https://curl.haxx.se/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('curl')
pkg_source="https://curl.haxx.se/download/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="8a063d664d1c23d35526b87a2bf15514962ffdd8ef7fd40519191b3c23e39548"
pkg_deps=(
	core/cacerts
	core/glibc
	core/openssl
	core/zlib
	core/zstd
	core/nghttp2
	core/libidn2
	core/libpsl
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/make
	core/perl
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# Patch the zsh-generating program to use our perl at build time
	sed -i "s,/usr/bin/env/perl,$(pkg_path_for perl)/bin/perl,g" scripts/completion.pl
	
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
