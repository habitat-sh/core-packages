program="isl"

pkg_name="libisl-stage1"
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
	core/glibc-base
	core/gcc-stage1
	core/libgmp-stage1
	core/build-tools-coreutils
	core/build-tools-make
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# Change the dynamic linker and glibc library to link against core/glibc-base
	case $pkg_target in
	aarch64-linux)
		HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc-base)/lib/ld-linux-aarch64.so.1"
		export HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER
		build_line "Setting HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER=${HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER}"
		;;
	x86_64-linux)
		HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc-base)/lib/ld-linux-x86-64.so.2"
		export HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER
		build_line "Setting HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER=${HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER}"
		;;
	esac
	HAB_GCC_STAGE1_GLIBC_PKG_PATH="$(pkg_path_for glibc-base)"
	export HAB_GCC_STAGE1_GLIBC_PKG_PATH
	build_line "Setting HAB_GCC_STAGE1_GLIBC_PKG_PATH=${HAB_GCC_STAGE1_GLIBC_PKG_PATH}"
}

do_build() {
	# We disable shared libraries so that when this package is used as a dependency
	# for core/gcc, it will get linked into gcc statically. Thus gcc won't have
	# a runtime dependency back to this library.
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix/share/doc/isl-0.25" \
		--disable-shared

	make
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
