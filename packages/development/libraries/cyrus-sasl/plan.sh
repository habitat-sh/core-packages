pkg_name="cyrus-sasl"
pkg_origin="core"
pkg_version="2.1.27"
pkg_description="Cyrus Simple Authentication Service Layer (SASL) library"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("BSD-3-Clause-Attribution") # 4-Clause-BSD-like, see http://www.cyrusimap.org/mediawiki/index.php/Downloads#Licensing
pkg_upstream_url="http://www.cyrusimap.org/"
pkg_source="https://ftp.osuosl.org/pub/blfs/conglomeration/cyrus-sasl/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="26866b1549b00ffd020f188a43c258017fa1c382b3ddadd8201536f72efb05d5"
pkg_deps=(
	core/glibc
	core/openssl
	core/gdbm
)
pkg_build_deps=(
	core/gcc
#	core/gdbm
)
pkg_bin_dirs=(sbin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# We apply a patch to Cyrus SASL to guarantee compatibility with OpenSSL 3, thanks to Nixpkgs.
	# https://github.com/NixOS/nixpkgs/blob/22.11/pkgs/development/libraries/cyrus-sasl/default.nix#L22-L26
	patch -p1 <"$PLAN_CONTEXT/openssl-3.0.patch"
}

do_build() {
	./configure --prefix="${pkg_prefix}" \
		--enable-auth-sasldb \
		--with-sphinx-build=no \
		--with-dbpath="${pkg_svc_path}/etc/sasldb2" \
		--with-plugindir="${pkg_prefix}/lib/sasl2" \
		--with-saslauthd="${pkg_svc_var_path}/run/saslauthd"
	make
}

do_install() {
	make install
	install -m644 COPYING "${pkg_prefix}/share/"
}
