program="autoconf"
pkg_name="autoconf"
pkg_origin="core"
pkg_version="2.71"
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
	core/coreutils
	core/diffutils
	core/gcc
	core/grep
	core/make
	core/patch
	core/sed
	core/zlib
	core/libtool
)
pkg_bin_dirs=(bin)

do_prepare() {
	# fix stale autom4te cache race condition:
	# https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/tools/misc/autoconf/default.nix#L17-L21
	# https://savannah.gnu.org/support/index.php?110521
	patch -p1 <"$PLAN_CONTEXT/2.71-fix-race.patch"
}

do_check() {
	# Some of the packages are included to enable test cases:
	# * core/zlib
	# * core/libtool
	# Create a link to echo in coreutils to be used by the pcre2 test case
	ln -sv "$(pkg_path_for coreutils)"/bin/echo /bin/echo

	TESTSUITEFLAGS="-j$(nproc)" make check
}
