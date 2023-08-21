pkg_name=erlang
pkg_origin=core
pkg_version=23.3.4.9
pkg_description="A programming language for massively scalable soft real-time systems."
pkg_upstream_url="http://www.erlang.org/"
pkg_dirname="otp_src_${pkg_version}"
pkg_license=('Apache-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/erlang/otp/releases/download/OTP-${pkg_version}/otp_src_${pkg_version}.tar.gz"
pkg_filename="otp_src_${pkg_version}.tar.gz"
pkg_shasum=2a2a6538c25736bda659af647ea2aac10eeeabc26c889e051487507045a24581
pkg_build_deps=(
	core/gcc
	core/make
	core/perl
	core/m4
)
pkg_deps=(
	core/coreutils
	core/glibc
	core/zlib
	core/ncurses
	core/openssl11
	core/sed
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_prepare() {
	# We eliminate extra default platform-specific RPATHs to OpenSSL crypto libraries
	# from the internal Erlang libraries to prevent accidental usage of the host
	# system's crypto library.
	sed -i 's/std_ssl_locations=.*/std_ssl_locations=""/' lib/crypto/configure

	# The `/bin/pwd` path is hardcoded, so we'll add a symlink if needed.
	if [[ ! -r /bin/pwd ]]; then
		ln -sv "$(pkg_path_for coreutils)/bin/pwd" /bin/pwd
		_clean_pwd=true
	fi

	if [[ ! -r /bin/rm ]]; then
		ln -sv "$(pkg_path_for coreutils)/bin/rm" /bin/rm
		_clean_rm=true
	fi
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
		--with-ssl-include="$(pkg_path_for openssl11)/include" \
		--without-javac
	make
}
do_install() {
	make install
	grep -nrlI '^\#\!.*bin/env' "$pkg_prefix" | while read -r target; do
		sed -e "s|#!.*bin/env|#!$(pkg_path_for coreutils)/bin/env|" -i "$target"
	done
}
do_end() {
	# Clean up the `pwd` link, if we set it up.
	if [[ -n $_clean_pwd ]]; then
		rm -fv /bin/pwd
	fi

	if [[ -n $_clean_rm ]]; then
		rm -fv /bin/rm
	fi
}