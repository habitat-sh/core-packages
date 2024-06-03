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
pkg_build_deps=(
	core/perl
	core/clang
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	patch -p1 <"$PLAN_CONTEXT/hab-ssl-cert-file.patch"
}

do_build() {
	./Configure \
		--libdir=lib \
		--prefix="${pkg_prefix}" \
		--openssldir=ssl \
		shared \
		fips \
		darwin64-arm64

	make -j"$(nproc)"
}

do_strip() {
	# TODO: remove this once studio corrects the strip
	return 0
}

do_check() {
	make test
}

do_install() {
	do_default_install

	# Remove dependency on Perl at runtime
	rm -rfv "$pkg_prefix/ssl/misc" "$pkg_prefix/bin/c_rehash"
}
