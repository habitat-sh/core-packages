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
pkg_license=('gplv3+')
pkg_source="http://www.greenwoodsoftware.com/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="a69abe2e0a126777e021d3b73aa3222e1b261f10e64624d41ec079685a6ac209"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/ncurses
)
pkg_build_deps=(
	core/pcre2
	core/coreutils
	core/diffutils
	core/gcc
	core/grep
	core/patch
	core/make

)
pkg_bin_dirs=(bin)

do_prepare() {
	# Statically link in PCRE2 by replacing the linking flag
	# from -lpcre2-8 to -l:libpcre2-8.a which forces the linker
	# to pick up the static archive instead of the shared library.
	# We do this to remove pcre2 as a runtime dep as it has several
	# binaries and runtime deps itself.
	sed -i configure -e 's|-lpcre2-8|-l:libpcre2-8.a|'
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--sysconfdir=/etc \
		--with-regex=pcre2
	make
}
