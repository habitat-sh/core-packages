pkg_name=cyrus-sasl
pkg_origin=core
pkg_version=2.1.28
pkg_description="Cyrus Simple Authentication Service Layer (SASL) library"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("custom") # 4-Clause-BSD-like, see http://www.cyrusimap.org/mediawiki/index.php/Downloads#Licensing
pkg_upstream_url=http://www.cyrusimap.org/
pkg_source=https://ftp.osuosl.org/pub/blfs/conglomeration/cyrus-sasl/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=7ccfc6abd01ed67c1a0924b353e526f1b766b21f42d4562ee635a8ebfc5bb38c
pkg_deps=(
           core/glibc 
	   core/openssl
         )
pkg_build_deps=(
          core/gcc 
	  core/make
         )
pkg_bin_dirs=(sbin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
  ./configure --prefix="${pkg_prefix}" \
              --with-plugindir="${pkg_prefix}/lib/sasl2" \
              --enable-auth-sasldb \
              --with-saslauthd="${pkg_svc_var_path}/run/saslauthd"
  make
}

do_install() {
  make install
  install -m644 COPYING "${pkg_prefix}/share/"
}
