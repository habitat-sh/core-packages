pkg_name="isl"
pkg_origin="core"
pkg_version="0.25"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
isl is a library for manipulating sets and relations of integer points bounded by linear constraints.
"
pkg_upstream_url="http://www.multiprecision.org/"
pkg_license=('MIT')
pkg_source="https://libisl.sourceforge.io/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="be7b210647ccadf90a2f0b000fca11a4d40546374a850db67adb32fad4b230d9"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/build-tools-make
	core/gcc-bootstrap
	core/gmp
	core/build-tools-patchelf
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --docdir="$pkg_prefix/share/doc/isl-0.25" \
        --disable-static

    make
}

do_check() {
    make check
}

do_install() {
	make install
	patchelf --shrink-rpath "${pkg_prefix}/lib/libisl.so.23.2.0"
}
