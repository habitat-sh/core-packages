pkg_name="groff"
pkg_origin="core"
pkg_version="1.22.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-3.0-or-later')
pkg_description="Groff (GNU troff) is a typesetting system that reads plain text mixed with formatting commands and produces formatted output. Output may be PostScript or PDF, html, or ASCII/UTF8 for display at the terminal. Formatting commands may be either low-level typesetting requests ("primitives") or macros from a supplied set. Users may also write their own macros. All three may be combined."
pkg_upstream_url="https://www.gnu.org/software/groff/"
pkg_source="http://ftp.gnu.org/gnu/groff/groff-${pkg_version}.tar.gz"
pkg_shasum="e78e7b4cb7dec310849004fa88847c44701e8d133b5d4c13057d876c1bad0293"

pkg_deps=(
	core/gcc-libs
	core/coreutils
	core/perl
	core/bash
)
pkg_build_deps=(
	core/gcc
	core/texinfo
)

pkg_bin_dirs=(bin)

do_prepare() {
	# Fix `/usr/bin/perl` interpreter in source files
	# We need to correct the timestamp after modifying the interpreter
	# otherwise it triggers unnecessary build rules that think the source
	# has changed.
	grep -lr '^#\!\s*/usr/bin/perl' . | while read -r f; do
		# Replace the interpreter
		sed -e "s,^#\!\s*/usr/bin/perl,#\!$(pkg_path_for perl)/bin/perl,g" -i.bak "$f"
		# Sync the timestamp of the modified file with the backup
		touch -r "$f.bak" "$f"
		# Remove the backup
		rm "$f.bak"
	done
}

do_build() {
	./configure --prefix="${pkg_prefix}"
	make -j"$(nproc)"
}

do_check() {
	make check
}

do_install() {
	make install
	fix_interpreter "${pkg_prefix}/bin/*" core/coreutils bin/env
	fix_interpreter "${pkg_prefix}/lib/groff/**/**" core/coreutils bin/env
}
