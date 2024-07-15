pkg_name=nss
pkg_origin=core
pkg_version="3.102"
pkg_license=('MPL-2.0' 'MPL-2.0-no-copyleft-exception' 'BSD-3-Clause' 'Zlib')
pkg_description="Network Security Services"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS"
pkg_source="https://ftp.mozilla.org/pub/security/nss/releases/NSS_${pkg_version//./_}_RTM/src/nss-${pkg_version}.tar.gz"
pkg_shasum="4ae9db6b117db1cc134bd587a23ff804d8da5bdd63fbb1bf0862b8e3e3aa2439"

pkg_deps=(
  core/glibc
  core/nspr
  core/sqlite
  core/zlib
)
pkg_build_deps=(
  core/gcc
  core/make
  core/perl
  core/patchelf
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include/nss)
pkg_lib_dirs=(lib)

do_prepare() {
  # Use LDFLAGS during linking
  sed -e "/\$(MKSHLIB) -o/ s/$/ \$(LDFLAGS)/" -i nss/coreconf/rules.mk
}

do_build() {
  pushd ${pkg_name} || exit 1

  make -j1 BUILD_OPT=1 \
    NSS_USE_SYSTEM_SQLITE=1 \
    USE_SYSTEM_ZLIB=1 \
    USE_64=1 \
    XCFLAGS="${CFLAGS}"

  popd >/dev/null || exit 1
}

do_install() {
  install -m0644 dist/public/nss/*.h "${pkg_prefix}"/include/nss
  install -m0644 dist/Linux*/lib/{*.so,*.chk,libcrmf.a} "${pkg_prefix}"/lib
  # copy only select binaries
  install -m0755 dist/Linux*/bin/{*util,derdump,pp,shlibsign,signtool,signver,ssltap,vfychain,vfyserv} "${pkg_prefix}"/bin

  OUT=$(ls ${pkg_prefix}/bin)
  for file in $OUT; do
    patchelf --set-rpath "$(pkg_path_for nspr)/lib:${pkg_prefix}/lib" ${pkg_prefix}/bin/$file
  done

  patchelf --set-rpath "$(pkg_path_for nspr)/lib:$(pkg_path_for zlib)/lib:${pkg_prefix}/lib" ${pkg_prefix}/bin/modutil
  patchelf --set-rpath "$(pkg_path_for nspr)/lib:$(pkg_path_for zlib)/lib:${pkg_prefix}/lib" ${pkg_prefix}/bin/signtool
  patchelf --shrink-rpath ${pkg_prefix}/bin/shlibsign
  #patchelf --set-rpath "$(pkg_path_for nspr)/lib" ${pkg_prefix}/bin/shlibsign
}