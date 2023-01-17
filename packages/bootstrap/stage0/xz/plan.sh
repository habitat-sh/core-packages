program="xz"

pkg_name="xz-stage0"
pkg_origin="core"
pkg_version="5.2.6"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="XZ Utils is free general-purpose data compression software with a high compression ratio. XZ Utils were written for POSIX-like systems, but also work on some not-so-POSIX systems. XZ Utils are the successor to LZMA Utils."
pkg_upstream_url="http://tukaani.org/xz/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.0-or-later')
pkg_source="http://tukaani.org/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="a2105abee17bcd2ebd15ced31b4f5eda6e17efd6b10f921a01cda4a44c91b3a0"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc-stage0
)
pkg_build_deps=(
	core/gcc-stage0
	core/build-tools-make
	core/build-tools-patchelf
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--disable-static \
		--docdir="$pkg_prefix"/share/doc/xz-5.2.6

	make
}

do_check() {
	make check
}

do_install() {
	make install
	patchelf --shrink-rpath "${pkg_prefix}/bin/lzmadec"
	patchelf --shrink-rpath "${pkg_prefix}/bin/lzmainfo"
	patchelf --shrink-rpath "${pkg_prefix}/bin/xz"
	patchelf --shrink-rpath "${pkg_prefix}/bin/xzdec"
	patchelf --shrink-rpath "${pkg_prefix}/lib/liblzma.so.${pkg_version}"
}
