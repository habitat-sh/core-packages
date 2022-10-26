program="zstd"
pkg_name="build-tools-zstd"
pkg_origin="core"
pkg_version="1.5.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Zstandard is a real-time compression algorithm, providing high compression ratios. It offers a very wide range of compression speed trade-off, while being backed by a very fast decoder"
pkg_upstream_url="http://facebook.github.io/zstd/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://github.com/facebook/${program}/archive/v${pkg_version}.tar.gz"
pkg_shasum="f7de13462f7a82c29ab865820149e778cbfe01087b3a55b5332707abf9db4a6e"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    make PREFIX="${pkg_prefix}"
}

do_check() {
	make check
}

do_install() {
    make PREFIX="${pkg_prefix}" install
    # remove static library
    rm -v ${pkg_prefix}/lib/libzstd.a
}
