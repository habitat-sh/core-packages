program="bash"

pkg_name="bash"
pkg_origin="core"
pkg_version="5.1"
patch_version=".16"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
 Bash is the GNU Project's shell. Bash is the Bourne Again SHell. Bash is an \
sh-compatible shell that incorporates useful features from the Korn shell \
(ksh) and C shell (csh). It is intended to conform to the IEEE POSIX \
P1003.2/ISO 9945.2 Shell and Tools standard. It offers functional \
improvements over sh for both programming and interactive use. In addition, \
most sh scripts can be run by Bash without modification.\
"
pkg_upstream_url="http://www.gnu.org/software/bash/bash.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}${patch_versoin}.tar.gz"
pkg_shasum="cc012bc860406dcf42f64431bcd3d2fa7560c02915a601aba9cd597a39329baa"
pkg_dirname="${program}-${pkg_version}"
pkg_interpreters=(
	bin/sh
	bin/bash
)
pkg_deps=(
	core/glibc
	core/ncurses
	core/readline
)
pkg_build_deps=(
	core/bison
	core/gcc
	core/shadow
	core/expect-stage1
	core/build-tools-perl
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-curses \
		--with-installed-readline="$(pkg_path_for readline)/lib" \
		--without-bash-malloc
	make
}

do_check() {
	# Create symlinks to all package binaries used during the tests
	for prog in "$(pkg_path_for coreutils)"/bin/*; do
		ln -s "$prog" /bin/"$(basename "$prog")"
	done

	chown -R hab .
	su -s "$(pkg_path_for expect-stage1)"/bin/expect hab <<EOF
set timeout -1
set ::env(PATH) "${PATH}"
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
	make check
}

do_install() {
	make install
	ln -sv bash "$pkg_prefix/bin/sh"

	# Fix interpreter
	rm -v "${pkg_prefix}/bin/bashbug"
}
