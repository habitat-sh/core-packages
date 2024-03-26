pkg_name="texinfo"
pkg_origin="core"
pkg_version="7.0.1"
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
pkg_shasum="bcd221fdb2d807a8a09938a0f8d5e010ebd2b58fca16075483d6fcb78db2c6b2"
pkg_deps=(
	core/gawk
	core/glibc
	core/ncurses
	core/perl
)
pkg_build_deps=(
	core/automake
	core/coreutils
	core/diffutils
	core/gcc
	core/gettext
	core/grep
	core/make
	core/sed
)
pkg_bin_dirs=(bin)

do_prepare() {
	# Fix `/usr/bin/env` interpreter in source files
	# We need to correct the timestamp after modifying the interpreter
	# otherwise it triggers unnecessary build rules that think the source
	# has changed.
	grep -lr '^#\!\s*/usr/bin/env' . | while read -r f; do
		# Replace the interpreter
		sed -e "s,^#\!\s*/usr/bin/env,#\!$(pkg_path_for coreutils)/bin/env,g" -i.bak "$f"
		# Sync the timestamp of the modified file with the backup
		touch -r "$f.bak" "$f"
		# Remove the backup
		rm "$f.bak"
	done
}

do_check() {
	make check
}

do_install() {
	make install
}
