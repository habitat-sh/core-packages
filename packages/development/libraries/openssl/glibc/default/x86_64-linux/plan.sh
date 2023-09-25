program="openssl"
pkg_name="openssl"
pkg_origin=core
pkg_version="1.0.2zf"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
OpenSSL is an open source project that provides a robust, commercial-grade, \
and full-featured toolkit for the Transport Layer Security (TLS) and Secure \
Sockets Layer (SSL) protocols. It is also a general-purpose cryptography \
library.\
"
pkg_upstream_url="https://www.openssl.org"
pkg_license=('OpenSSL')
pkg_source="https://s3.amazonaws.com/chef-releng/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="85d2242b7d11a33d5f239f1f34a1ff7eb37431a554b7df99c52c646b70b14b2e"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/openssl-fips
	core/cacerts
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/perl
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	local perl
	perl="$(pkg_path_for core/perl)"

	export BUILD_CC=gcc
	# Set PERL environment variable for scripts in `do_check` that use Perl
	export PERL="${perl}/bin/perl"

	# Set CA dir to `$pkg_prefix/ssl` by default and use the cacerts from the
	# `cacerts` package. Note that `patch(1)` is making backups because
	# we need an original for the test suite.
	# DO NOT REMOVE
	sed -e "s,@cacerts_prefix@,$(pkg_path_for cacerts),g" \
		"$PLAN_CONTEXT/ca_dir.patch" |
		patch -p1 --backup

	if [[ ! -f "/bin/rm" ]]; then
		hab pkg binlink core/coreutils rm --dest /bin
		export BINLINKED_RM=true
	fi

	build_line "Setting BUILD_CC=$BUILD_CC"
	build_line "Setting PERL=${PERL}"
}

do_build() {
	perl ./Configure \
		--prefix="${pkg_prefix}" \
		--openssldir=ssl \
		--with-fipsdir="$(pkg_path_for core/openssl-fips)" \
		no-idea \
		no-mdc2 \
		no-rc5 \
		no-sslv2 \
		no-sslv3 \
		no-comp \
		no-zlib \
		shared \
		disable-gost \
		linux-${pkg_target%%-*} \
		fips \
		-DOPENSSL_TRUSTED_FIRST_DEFAULT

	make CC= depend
	make --jobs="$(nproc)" CC="$BUILD_CC"
}

do_check() {
	# Flip back to the original sources to satisfy the test suite, but keep the
	# final version for packaging.
	for f in apps/CA.pl.in apps/CA.sh apps/openssl.cnf crypto/cryptlib.h; do
		cp -fv $f ${f}.final
		cp -fv ${f}.orig $f
	done

	make test

	# Finally, restore the final sources to their original locations.
	for f in apps/CA.pl.in apps/CA.sh apps/openssl.cnf crypto/cryptlib.h; do
		cp -fv ${f}.final $f
	done
}

do_install() {
	make install

	# Remove dependency on Perl at runtime
	rm -rfv "$pkg_prefix/ssl/misc" "$pkg_prefix/bin/c_rehash"
}

do_end() {
	# Clean up binlinked rm if we made it
	if [[ $BINLINKED_RM == true ]]; then
		rm -f /bin/rm
	fi
}
