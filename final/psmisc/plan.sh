pkg_name="psmisc"
pkg_origin="core"
pkg_version="23.5"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The PSmisc package is a set of some small useful utilities that use the proc \
filesystem.\
"
pkg_upstream_url="http://psmisc.sourceforge.net/index.html"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://downloads.sourceforge.net/psmisc/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="dc37ecc2f7e4a90a94956accc6e1c77adb71316b7c9cbd39b26738db0c3ae58b"
pkg_deps=(
	core/glibc
	core/ncurses
)
pkg_build_deps=(
	core/coreutils
	core/diffutils
	core/gcc
	core/make
	core/patch
)
pkg_bin_dirs=(bin)
