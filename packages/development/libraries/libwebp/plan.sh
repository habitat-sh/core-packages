pkg_name="libwebp"
pkg_version="0.6.1"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-3-Clause')
pkg_description="WebP codec: library to encode and decode images in WebP format."
pkg_upstream_url="https://developers.google.com/speed/webp"
pkg_source="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="06503c782d9f151baa325591c3579c68ed700ffc62d4f5a32feead0ff017d8ab"
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
	core/jbigkit
	core/gcc
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
