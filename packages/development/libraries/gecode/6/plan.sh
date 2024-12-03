pkg_name=gecode6
pkg_distname=gecode
pkg_origin=core
pkg_version="6.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_description="Gecode is a toolkit for developing constraint-based systems and applications"
pkg_upstream_url="http://www.gecode.org"
pkg_source="https://github.com/Gecode/${pkg_distname}/archive/release-${pkg_version}.tar.gz"
pkg_shasum="27d91721a690db1e96fa9bb97cec0d73a937e9dc8062c3327f8a4ccb08e951fd"
pkg_dirname=${pkg_distname}-release-${pkg_version}
pkg_deps=(
	core/gcc-libs
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/diffutils
	core/gcc
	core/make
	core/perl
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--disable-doc-dot \
		--disable-doc-search \
		--disable-doc-tagfile \
		--disable-doc-chm \
		--disable-doc-docset \
		--disable-qt \
		--disable-examples

	make -j "$(nproc)"
}

do_check() {
	LD_LIBRARY_PATH=$PWD make check
}
