pkg_name="libffi"
pkg_version="3.4.4"
pkg_origin="core"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/libffi/libffi/releases/download/v${pkg_version}/libffi-${pkg_version}.tar.gz"
pkg_upstream_url="https://sourceware.org/libffi"
pkg_description="The libffi library provides a portable, high level programming interface to various calling conventions.\
  This allows a programmer to call any function specified by a call interface description at run-time."
pkg_filename=${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=d66c56ad259a82cf2a9dfc408b32bf5da52371500b84745f7fb8b645712df676
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/dejagnu
	core/file
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--with-gcc-arch="generic" \
		--disable-multi-os-directory
	make
}

do_check() {
	make check
}
