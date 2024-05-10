pkg_name=erlang26
pkg_origin=core
pkg_version=26.2.2
pkg_description="A programming language for massively scalable soft real-time systems."
pkg_upstream_url="http://www.erlang.org/"
pkg_license=('Apache-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/erlang/otp/releases/download/OTP-${pkg_version}/otp_src_${pkg_version}.tar.gz"
pkg_filename="otp_src_${pkg_version}.tar.gz"
pkg_shasum="d537ff4ac5d8c1cb507aedaf7198fc1f155ea8aa65a8d83edb35c2802763cc28"
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
	core/openssl
	core/sed
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
	patch -p1 <"$PLAN_CONTEXT/remove_ssl_rpaths.patch"

	# Replace all host system env interpreters with our packaged env
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_path_for coreutils)/bin/env,g" -i "$f"
	done
}

do_build() {
	sed -i 's/std_ssl_locations=.*/std_ssl_locations=""/' erts/configure
	CFLAGS="${CFLAGS} -O2" ./configure \
		--prefix="${pkg_prefix}" \
		--enable-threads \
		--enable-smp-support \
		--enable-kernel-poll \
		--enable-dynamic-ssl-lib \
		--enable-shared-zlib \
		--enable-hipe \
		--with-ssl="$(pkg_path_for openssl)" \
		--with-ssl-include="$(pkg_path_for openssl)/include" \
		--without-javac
	make -j"$(nproc)"
}

do_check() {
	make test
}

do_install() {
	make install
	cp $CACHE_PATH/LICENSE.txt "$pkg_prefix"
	# Fix all the script interpreters
	grep -nrlI '^\#\! escript' "$pkg_prefix" | while read -r target; do
		sed -e "s|#! escript|#!${pkg_prefix}/bin/escript|" -i "$target"
	done
}
