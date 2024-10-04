pkg_name=openssl-musl
_distname="openssl"
pkg_origin=core
pkg_version="3.0.9"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
OpenSSL is an open source project that provides a robust, commercial-grade, \
and full-featured toolkit for the Transport Layer Security (TLS) and Secure \
Sockets Layer (SSL) protocols. It is also a general-purpose cryptography \
library.\
"
pkg_upstream_url="https://www.openssl.org"
pkg_license=('Apache-2.0' 'Artistic-1.0' 'GPL-1.0-only')
pkg_source="https://www.openssl.org/source/${_distname}-${pkg_version}.tar.gz"
pkg_shasum="eb1ab04781474360f77c318ab89d8c5a03abc38e63d65a603cabbf1b00a1dc90"
pkg_dirname="${_distname}-${pkg_version}"
pkg_deps=(
  core/musl
  core/zlib-musl
  core/cacerts
)
pkg_build_deps=(
  core/coreutils
  core/diffutils
  core/patch
  core/make
  core/gcc
  core/sed
  core/grep
  core/perl
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib64)
pkg_pconfig_dirs=(lib64/pkgconfig)

_common_prepare() {
  do_default_prepare

  # The openssl build process hard codes /bin/rm in many places. Unfortunately
  # we cannot modify the contents of the build scripts to fix this or else we
  # risk violating the sanctity of the official fips build process.
  # Instead, we link rm to maintain integrity.
  # Reference: https://www.openssl.org/docs/fips/UserGuide-2.0.pdf
  if [[ ! -f "/bin/rm" ]]; then
    hab pkg binlink core/coreutils rm --dest /bin
    BINLINKED_RM=true
  fi
}

do_prepare() {
  PLAN_CONTEXT="$(abspath "$PLAN_CONTEXT")" _common_prepare
  patch -p1 <"$PLAN_CONTEXT/hab-ssl-cert-file.patch"
#  dynamic_linker="$(pkg_path_for musl)/lib/ld-musl-x86_64.so.1"
  dynamic_linker="$(pkg_path_for musl)/lib/libc.so"
  LDFLAGS="$LDFLAGS -Wl,--dynamic-linker=$dynamic_linker"
 
  export BUILD_CC=musl-gcc
  build_line "Setting BUILD_CC=$BUILD_CC"
}

do_build() {
  # Set PERL var for scripts in `do_check` that use Perl
  PERL=$(pkg_path_for core/perl)/bin/perl
  export PERL
  "$(pkg_path_for core/perl)/bin/perl" ./Configure \
    no-idea \
    no-mdc2 \
    no-rc5 \
    no-comp \
    no-zlib \
    shared \
    disable-gost \
    --prefix="${pkg_prefix}" \
    --openssldir=ssl \
    linux-x86_64

  make CC= depend
  make --jobs="$(nproc)" CC="$BUILD_CC"
}

do_check() {
  # Flip back to the original sources to satisfy the test suite, but keep the
  # final version for packaging.
  for f in apps/CA.pl.in apps/CA.sh apps/openssl.cnf; do
    cp -fv $f ${f}.final
    cp -fv ${f}.orig $f
  done

  make test

  # Finally, restore the final sources to their original locations.
  for f in apps/CA.pl.in apps/CA.sh apps/openssl.cnf; do
    cp -fv ${f}.final $f
  done
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