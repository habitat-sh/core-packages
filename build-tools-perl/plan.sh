program=perl
pkg_name=build-tools-perl
pkg_origin=core
pkg_version=5.36.0
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Perl 5 is a highly capable, feature-rich programming language with over 29 \
years of development.\
"
pkg_upstream_url="http://www.perl.org/"
pkg_license=('GPL-1.0-or-later' 'Artistic-1.0-Perl')
pkg_source="http://www.cpan.org/src/5.0/${program}-${pkg_version}.tar.gz"
pkg_shasum="e26085af8ac396f62add8a533c3a0ea8c8497d836f0689347ac5abd7b7a4e00a"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
)
pkg_build_deps=(
  core/build-tools-gcc
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_interpreters=(bin/perl)


do_build() {
  # Use the already-built shared libraries for zlib and bzip2 modules

  sh Configure \
    -de \
    -Dprefix="$pkg_prefix" \
    -Dcc=gcc \
    -Dvendorprefix="$pkg_prefix" \
             -Dprivlib="$pkg_prefix/lib/perl5/5.36/core_perl"     \
             -Darchlib="$pkg_prefix/lib/perl5/5.36/core_perl"     \
             -Dsitelib="$pkg_prefix/lib/perl5/5.36/site_perl"     \
             -Dsitearch="$pkg_prefix/lib/perl5/5.36/site_perl"    \
             -Dvendorlib="$pkg_prefix/lib/perl5/5.36/vendor_perl" \
             -Dvendorarch="$pkg_prefix/lib/perl5/5.36/vendor_perl"
  make -j"$(nproc)"

  # Clear temporary build time environment variables
}
do_install() {
  make install PREFIX="$pkg_prefix"
}
# ----------------------------------------------------------------------------
# **NOTICE:** What follows are implementation details required for building a
# first-pass, "stage1" toolchain and environment. It is only used when running
# in a "stage1" Studio and can be safely ignored by almost everyone. Having
# said that, it performs a vital bootstrapping process and cannot be removed or
# significantly altered. Thank you!
# ----------------------------------------------------------------------------
if [[ "$STUDIO_TYPE" = "stage1" ]]; then
  pkg_build_deps=(
    core/gcc
    core/procps-ng
    core/inetutils
    core/iana-etc
  )
fi
