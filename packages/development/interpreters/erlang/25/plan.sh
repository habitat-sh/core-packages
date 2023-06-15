pkg_name="erlang25"
pkg_origin=core
pkg_version="25.0.4"
pkg_description="A programming language for massively scalable soft real-time systems."
pkg_upstream_url="http://www.erlang.org/"
pkg_license=('Apache-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/erlang/otp/releases/download/OTP-${pkg_version}/otp_src_${pkg_version}.tar.gz"
pkg_filename="otp_src_${pkg_version}.tar.gz"
pkg_shasum="8fc707f92a124b2aeb0f65dcf9ac8e27b2a305e7bcc4cc1b2fdf770eec0165bf"
pkg_dirname="otp_src_${pkg_version}"
pkg_build_deps=(
	core/bison
	core/gcc
	core/make
	core/patch
	core/perl
	core/m4
	core/coreutils
)
pkg_deps=(
	core/gcc-libs
	core/glibc
	core/zlib
	core/ncurses
	core/openssl11
	core/sed
	core/gawk
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_interpreters=(
	bin/escript
)

do_prepare() {
	# We eliminate extra default platform-specific RPATHs to OpenSSL crypto libraries
	# from the internal Erlang libraries to prevent accidental usage of the host
	# system's crypto library.
	awk '!f && /std_ssl_locations=/ { print "std_ssl_locations=\"\""; f=1; next } /"/ && f == 1 { f=2; next } f == 1 { next } !f || f == 2' lib/crypto/configure >lib/crypto/configure.new
	mv lib/crypto/configure.new lib/crypto/configure && chmod +x lib/crypto/configure

	# Replace all host system env interpreters with our packaged env
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_path_for coreutils)/bin/env,g" -i "$f"
	done
}

do_build() {
	CFLAGS="${CFLAGS} -O2" ./configure \
		--prefix="${pkg_prefix}" \
		--enable-threads \
		--enable-smp-support \
		--enable-kernel-poll \
		--enable-dynamic-ssl-lib \
		--enable-shared-zlib \
		--enable-hipe \
		--with-ssl="$(pkg_path_for openssl11)" \
		--without-javac
	make -j"$(nproc)"
}

do_check() {
	make test
}

do_install() {
	make install

	# Fix all the script interpreters
	grep -nrlI '^\#\! escript' "$pkg_prefix" | while read -r target; do
		sed -e "s|#! escript|#!${pkg_prefix}/bin/escript|" -i "$target"
	done
}
