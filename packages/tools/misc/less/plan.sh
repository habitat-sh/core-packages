program="less"

pkg_name="less"
pkg_origin="core"
pkg_version="643"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
A terminal pager program used to view (but not change) the contents of a text \
file.\
"
pkg_upstream_url="http://www.greenwoodsoftware.com/less/index.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://www.greenwoodsoftware.com/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="2911b5432c836fa084c8a2e68f6cd6312372c026a58faaa98862731c8b6052e8"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/ncurses
	core/libpcre2
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--sysconfdir=/etc \
		--with-regex=pcre2
	make
}
