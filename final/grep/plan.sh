program="grep"

pkg_name="grep"
pkg_origin="core"
pkg_version="3.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Grep searches one or more input files for lines containing a match to a \
specified pattern. By default, Grep outputs the matching lines.\
"
pkg_upstream_url="https://www.gnu.org/software/grep/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="498d7cc1b4fb081904d87343febb73475cf771e424fb7e6141aff66013abc382"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/bash-static
)
pkg_build_deps=(
	core/pcre2
	core/coreutils
	core/diffutils
	core/gcc
	core/make
	core/pkg-config
	core/build-tools-perl
)
pkg_bin_dirs=(bin)

do_prepare() {
	sed -i "s/echo/#echo/" src/egrep.sh
}

do_build() {
	./configure \
		PCRE_LIBS="-L$(pkg_path_for pcre2)/lib -l:libpcre2-8.a" \
		--prefix="$pkg_prefix"
	make
}

do_check() {
	make RUN_EXPENSIVE_TESTS=yes check
}

do_install() {
	make install
	# Fix scripts
	fix_interpreter "${pkg_prefix}"/bin/egrep core/bash-static bin/sh
	fix_interpreter "${pkg_prefix}"/bin/fgrep core/bash-static bin/sh
}
