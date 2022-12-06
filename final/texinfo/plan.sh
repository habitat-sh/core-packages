pkg_name=texinfo
pkg_origin=core
pkg_version=6.8
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Texinfo is the official documentation format of the GNU project. It was \
invented by Richard Stallman and Bob Chassell many years ago, loosely based on \
Brian Reid's Scribe and other formatting languages of the time. It is used by \
many non-GNU projects as well.\
"
pkg_upstream_url="http://www.gnu.org/software/texinfo/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$pkg_name/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="8eb753ed28bca21f8f56c1a180362aed789229bd62fff58bf8368e9beb59fec4"
pkg_deps=(
  core/glibc
  core/ncurses
  core/perl
  core/gawk
)
pkg_build_deps=(
  core/patch
  core/make
  core/gcc
  core/sed
)
pkg_bin_dirs=(bin)

do_check() {
  make check
}

