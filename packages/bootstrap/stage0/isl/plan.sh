program="isl"

pkg_name="isl-stage0"
pkg_origin="core"
pkg_version="0.25"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
isl is a library for manipulating sets and relations of integer points bounded by linear constraints.
"
pkg_upstream_url="http://www.multiprecision.org/"
pkg_license=('MIT')
pkg_source="https://libisl.sourceforge.io/${program}-${pkg_version}.tar.xz"
pkg_shasum="be7b210647ccadf90a2f0b000fca11a4d40546374a850db67adb32fad4b230d9"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc-stage0
	core/gmp-stage0
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	# We disable shared libraries so that when this package is used as a dependency
	# for core/gcc-stage1, it will get linked into gcc statically. Thus gcc won't have
	# a runtime dependency back to this library.
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix/share/doc/isl-0.25" \
		--disable-shared

	make V=1
}

do_check() {
	make check
}

do_install() {
	make install

	# Remove unnecessary files and pkgconfig
	rm -v "${pkg_prefix}/lib/libisl.la"
	rm -rfv "${pkg_prefix}/lib/pkgconfig"
}
