program="flex"
pkg_name="build-tools-flex"
pkg_origin="core"
pkg_version="2.6.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Flex is a fast lexical analyser generator. It is a tool for generating programs that    perform pattern-matching on text. Flex is a free (but non-GNU) implementation of the original Unix lex   program."
pkg_upstream_url="https://www.gnu.org/software/flex/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://github.com/westes/flex/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
	core/build-tools-m4
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
	--docdir="$pkg_prefix"/share/doc/flex-2.6.4 \
	--disable-static

    make
}

do_check() {
	make check
}

do_install() {
    make install
    ln -sv flex ${pkg_prefix}/bin/lex
}
