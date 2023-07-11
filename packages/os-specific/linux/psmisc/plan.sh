pkg_name="psmisc"
pkg_origin="core"
pkg_version="23.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The PSmisc package is a set of some small useful utilities that use the proc \
filesystem.\
"
pkg_upstream_url="http://psmisc.sourceforge.net/index.html"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://downloads.sourceforge.net/psmisc/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="7f0cceeace2050c525f3ebb35f3ba01d618b8d690620580bdb8cd8269a0c1679"
pkg_deps=(
	core/glibc
	core/ncurses
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)
