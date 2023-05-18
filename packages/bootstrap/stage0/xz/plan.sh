program="xz"

pkg_name="xz-stage0"
pkg_origin="core"
pkg_version="5.2.5"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="XZ Utils is free general-purpose data compression software with a high compression ratio. XZ Utils were written for POSIX-like systems, but also work on some not-so-POSIX systems. XZ Utils are the successor to LZMA Utils."
pkg_upstream_url="http://tukaani.org/xz/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.0-or-later')
pkg_source="http://tukaani.org/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="f6f4910fd033078738bd82bfba4f49219d03b17eb0794eb91efbae419f4aba10"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc-stage0
)
pkg_build_deps=(
	core/gcc-stage0
	core/build-tools-make
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--disable-static \
		--docdir="$pkg_prefix"/share/doc/xz-5.2.5

	make
}

do_check() {
	make check
}

do_install() {
	make install
}
