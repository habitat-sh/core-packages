program="mpfr"

pkg_name="mpfr-stage1"
pkg_origin="core"
pkg_version="4.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU MPFR (GNU Multiple Precision Floating-Point Reliably) is a GNU portable \
C library for arbitrary-precision binary floating-point computation with \
correct rounding, based on GNU Multi-Precision Library.\
"
pkg_upstream_url="http://www.mpfr.org/"
pkg_license=('LGPL-3.0-or-later')
pkg_source="http://www.mpfr.org/${program}-${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/glibc
	core/gcc-stage1
	core/gmp-stage1
	core/build-tools-coreutils
	core/build-tools-make
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# Change the dynamic linker and glibc library to link against core/glibc
	case $pkg_target in
	aarch64-linux)
		HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc)/lib/ld-linux-aarch64.so.1"
		export HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER
		build_line "Setting HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER=${HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER}"
		;;
	x86_64-linux)
		HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2"
		export HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER
		build_line "Setting HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER=${HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER}"
		;;
	esac
	HAB_GCC_STAGE1_GLIBC_PKG_PATH="$(pkg_path_for glibc)"
	export HAB_GCC_STAGE1_GLIBC_PKG_PATH
	build_line "Setting HAB_GCC_STAGE1_GLIBC_PKG_PATH=${HAB_GCC_STAGE1_GLIBC_PKG_PATH}"
}

do_build() {
	# We disable shared libraries so that when this package is used as a dependency
	# for core/gcc, it will get linked into gcc statically. Thus gcc won't have
	# a runtime dependency back to this library.
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix/share/doc/mpfr-4.1.0" \
		--enable-thread-safe \
		--disable-shared

	make
}

do_check() {
	make check
}

do_install() {
	make install

	# Remove unnecessary files and pkgconfig
	rm -v "${pkg_prefix}/lib/libmpfr.la"
	rm -rfv "${pkg_prefix}/lib/pkgconfig"
}
