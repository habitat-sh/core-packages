pkg_name="libwebp"
pkg_version="1.2.4"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('WebM') # Custom BSD3-like license, see: https://www.webmproject.org/license/software/
pkg_description="WebP codec: library to encode and decode images in WebP format."
pkg_upstream_url="https://developers.google.com/speed/webp"
pkg_source="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="7bf5a8a28cc69bcfa8cb214f2c3095703c6b73ac5fba4d5480c205331d9494df"
pkg_deps=(
	core/giflib
	core/glibc
	core/libjpeg-turbo
	core/libpng
	core/libtiff
	core/xz
	core/zlib
)
pkg_build_deps=(
	core/coreutils
	core/jbigkit
	core/gawk
	core/gcc
	core/grep
	core/make
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--enable-libwebpmux \
		--enable-libwebpdemux \
		--enable-libwebpdecoder \
		--enable-libwebpextras \
		--enable-swap-16bit-csp
	make
}
