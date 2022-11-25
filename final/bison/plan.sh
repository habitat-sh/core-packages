program="bison"
pkg_name="bison"
pkg_origin="core"
pkg_version="3.8.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Bison is a general-purpose parser generator that converts an annotated \
context-free grammar into a deterministic LR or generalized LR (GLR) parser \
employing LALR(1) parser tables.\
"
pkg_upstream_url="https://www.gnu.org/software/bison/"
pkg_license=('GPL-3.0')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.xz"
pkg_shasum="9bba0214ccf7f1079c5d59210045227bcf619519840ebfa80cd3849cff5a5bf2"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/m4
	core/glibc
	core/bash-static
	core/readline
	core/gettext
)
pkg_build_deps=(
	core/coreutils
	core/diffutils
	core/gcc
	core/grep
	core/make
	core/sed
	core/build-tools-perl
)
pkg_bin_dirs=(bin)

do_check() {
	# Some of the bison test cases around diagnostics require this environment variable to be set.
	# If it is not set, the bash shell emits an warning which causes the test to fail.
	export LC_ALL="en_US.utf8"
	make check
}

do_install() {
	make install
	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/bash-static bin/sh
}
