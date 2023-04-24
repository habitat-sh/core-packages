program="isl"

pkg_name="native-isl"
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

pkg_deps=(
	core/native-gmp
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(./config.guess)" \
		--host="$(./config.guess)" \
		--disable-static
	make V=1
}

do_check() {
	make check
}
