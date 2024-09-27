program=gnupg
pkg_name=gnupg
pkg_distname=$pkg_name
pkg_origin=core
pkg_version=2.4.5
pkg_license=('GPL-3.0-or-later')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="GnuPG is a complete and free implementation of the OpenPGP standard as defined by RFC4880 (also known as PGP)"
pkg_upstream_url="https://gnupg.org/"
pkg_source=https://gnupg.org/ftp/gcrypt/${pkg_distname}/${pkg_distname}-${pkg_version}.tar.bz2
pkg_shasum=f68f7d75d06cb1635c336d34d844af97436c3f64ea14bcb7c869782f96f44277
pkg_deps=(
  core/npth 
  core/libksba 
  core/libassuan 
  core/libgcrypt 
  core/libgpg-error
  core/glibc
  core/zlib 
  core/bzip2 
  core/readline
  core/gcc
)
pkg_build_deps=(
  core/coreutils
  core/diffutils
  core/patch
  core/make 
  core/sed 
  core/findutils 
)
pkg_bin_dirs=(bin)

do_build() {
  ./configure \
    --prefix="$pkg_prefix" \
    --sbindir="$pkg_prefix/bin"
  make
}

do_check() {
  find tests -type f -print0 \
    | xargs -0 sed -e "s,/bin/pwd,$(pkg_path_for coreutils)/bin/pwd,g" -i

  make check
}

