program="less"

pkg_name="less"
pkg_origin="core"
pkg_version="608"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
A terminal pager program used to view (but not change) the contents of a text \
file.\
"
pkg_upstream_url="http://www.greenwoodsoftware.com/less/index.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://www.greenwoodsoftware.com/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="a69abe2e0a126777e021d3b73aa3222e1b261f10e64624d41ec079685a6ac209"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/ncurses
	core/pcre
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--sysconfdir=/etc \
		--with-regex=pcre
	make
}
