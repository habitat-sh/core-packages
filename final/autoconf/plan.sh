program=autoconf
pkg_name=autoconf
pkg_origin=core
pkg_version=2.71
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Autoconf is an extensible package of M4 macros that produce shell scripts to \
automatically configure software source code packages.\
"
pkg_upstream_url="https://www.gnu.org/software/autoconf/autoconf.html"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="f14c83cfebcc9427f2c3cea7258bd90df972d92eb26752da4ddad81c87a0faa4"
pkg_deps=(
  core/m4
  core/perl
)
pkg_build_deps=(
  core/diffutils
  core/inetutils
  core/gcc
  core/make
)
pkg_bin_dirs=(bin)
