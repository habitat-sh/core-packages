pkg_name=gnutls
pkg_origin=core
pkg_version="3.7.11"
pkg_description="GnuTLS is a secure communications library implementing the SSL, TLS and DTLS protocols and technologies around them"
pkg_upstream_url="https://www.gnutls.org/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-3.0-or-later' 'LGPL-2.1-only' 'BSD-3-Clause' 'MIT')
pkg_source="https://www.gnupg.org/ftp/gcrypt/gnutls/v3.7/gnutls-${pkg_version}.tar.xz"
pkg_shasum="90e337504031ef7d3077ab1a52ca8bac9b2f72bc454c95365a1cd1e0e81e06e9"

pkg_deps=(
  core/glibc
  core/gmp
  core/libidn2
  core/libunistring
  core/nettle
  core/p11-kit
  core/zlib
)
pkg_build_deps=(
  core/file
  core/gcc
  core/gettext
  core/make
  core/pkg-config
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
  if [[ ! -r /usr/bin/file ]]; then
    ln -sv "$(pkg_path_for file)/bin/file" /usr/bin/file
    _clean_file=true
  fi
}

do_build() {
  ./configure \
    --prefix="${pkg_prefix}" \
    --with-included-libtasn1 \
    --disable-valgrind-tests
  make -j"$(nproc)"
}

do_install(){
  make install

  find "${pkg_prefix}/bin" -type f -executable -exec patchelf --set-rpath "LD_RUN_PATH" {} \; 
}

do_check() {
  # two tests fail
  # 1. a pkg config test which sets the PKG_CONFIG_PATH without nettle in it, would need to modify the test
  # 2. a libgcc_s.so.1 not found for one test, modifying LD_* variables does not seem to help
  make check
}

do_end() {
  if [[ -n "$_clean_file" ]]; then
    rm -fv /usr/bin/file
  fi
}