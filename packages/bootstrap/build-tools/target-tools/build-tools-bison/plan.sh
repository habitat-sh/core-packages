program="bison"
pkg_name="build-tools-bison"
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
	core/build-tools-m4
	core/build-tools-glibc
	core/build-tools-bash-static
	core/build-tools-gettext
)
pkg_build_deps=(
	core/build-tools-gcc
)
pkg_bin_dirs=(bin)

do_check() {
	make check
}

do_install() {
	make install
	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/build-tools-bash-static bin/sh
}
