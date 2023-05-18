program="openssl"

pkg_name="openssl"
pkg_origin="core"
pkg_version="3.0.7"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
OpenSSL is an open source project that provides a robust, commercial-grade, \
and full-featured toolkit for the Transport Layer Security (TLS) and Secure \
Sockets Layer (SSL) protocols. It is also a general-purpose cryptography \
library.\
"
pkg_upstream_url="https://www.openssl.org"
pkg_license=('Apache-2.0')
pkg_source="https://www.openssl.org/source/${program}-${pkg_version}.tar.gz"
pkg_shasum="83049d042a260e696f62406ac5c08bf706fd84383f945cf21bd61e9ed95c396e"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/build-tools-perl
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	local perl
	perl="$(pkg_path_for core/build-tools-perl)"

	export CROSS_SSL_ARCH="${native_target}"
	export PERL="${perl}/bin/perl"

	patch -p1 <"$PLAN_CONTEXT/hab-ssl-cert-file.patch"

	# Apply all reported CVE patches for OpenSSL version 3.0.7
	# https://www.openssl.org/news/vulnerabilities-3.0.html
	patch -p1 <"$PLAN_CONTEXT/CVE-2022-3996.patch"

	build_line "Setting CROSS_SSL_ARCH=${CROSS_SSL_ARCH}"
	build_line "Setting PERL=${PERL}"
}

do_build() {
	"$(pkg_path_for core/build-tools-perl)"/bin/perl ./Configure \
		--prefix="${pkg_prefix}" \
		--openssldir=ssl \
		fips

	make -j"$(nproc)"
}

do_check() {
	make test
}

do_install() {
	do_default_install

	# Remove dependency on Perl at runtime
	rm -rfv "$pkg_prefix/ssl/misc" "$pkg_prefix/bin/c_rehash"
}
