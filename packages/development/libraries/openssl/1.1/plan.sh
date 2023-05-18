pkg_name=openssl11
_distname=openssl
pkg_origin=core
_version=1.1.1
_revision=q
pkg_version="${_version}${_revision}"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
OpenSSL is an open source project that provides a robust, commercial-grade, \
and full-featured toolkit for the Transport Layer Security (TLS) and Secure \
Sockets Layer (SSL) protocols. It is also a general-purpose cryptography \
library.\
"
pkg_upstream_url="https://www.openssl.org"
pkg_license=('Apache-2.0')
pkg_source="https://www.openssl.org/source/old/${_version}/${_distname}-${pkg_version}.tar.gz"
pkg_shasum="d7939ce614029cdff0b6c20f0e2e5703158a489a72b2507b8bd51bf8c8fd10ca"
pkg_dirname="${_distname}-${pkg_version}"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/build-tools-perl
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	patch -p1 <"$PLAN_CONTEXT/hab-ssl-cert-file.patch"
	export BUILD_CC=gcc
	build_line "Setting BUILD_CC=$BUILD_CC"

	if [[ ! -f "/bin/rm" ]]; then
		hab pkg binlink core/coreutils rm --dest /bin
		BINLINKED_RM=true
	fi
}

do_build() {
	"$(pkg_path_for core/build-tools-perl)/bin/perl" ./Configure \
		no-idea \
		no-mdc2 \
		no-rc5 \
		no-comp \
		shared \
		disable-gost \
		--prefix="${pkg_prefix}" \
		--openssldir=ssl \
		linux-${pkg_target%%-*}

	make CC= depend
	make --jobs="$(nproc)" CC="$BUILD_CC"
}

do_check() {
	make test
}

do_install() {
	do_default_install

	# Remove dependency on Perl at runtime
	rm -rfv "$pkg_prefix/ssl/misc" "$pkg_prefix/bin/c_rehash"
}

do_end() {
	do_default_end

	# Clean up binlinked rm if we made it
	if [[ $BINLINKED_RM == true ]]; then
		rm -f /bin/rm
	fi
}
