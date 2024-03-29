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
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.xz"
pkg_shasum="9bba0214ccf7f1079c5d59210045227bcf619519840ebfa80cd3849cff5a5bf2"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/m4
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/build-tools-perl
	core/readline
)
pkg_bin_dirs=(bin)

do_check() {
	# Some of the bison test cases are invoked by shell scripts which set
	# the locale. This requires a shell that has been built with the supported
	# locales. So we replace the standard shell with bash-static
	rm -v /bin/{sh,bash}
	ln -sv "$(pkg_path_for bash-static)"/bin/bash /bin/sh
	ln -sv "$(pkg_path_for bash-static)"/bin/bash /bin/bash
	make check
}

do_install() {
	make install
}
