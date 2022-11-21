program="zstd"

pkg_origin="core"
pkg_name="zstd-stage1"
pkg_version="1.5.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-3-Clause')
pkg_description="Zstandard is a real-time compression algorithm, providing high compression ratios. " \
	"It offers a very wide range of compression / speed trade-off, while being backed by a very fast decoder"
pkg_upstream_url="http://facebook.github.io/zstd/"
pkg_source="https://github.com/facebook/zstd/archive/v${pkg_version}.tar.gz"
pkg_shasum="f7de13462f7a82c29ab865820149e778cbfe01087b3a55b5332707abf9db4a6e"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/glibc-base
	core/gcc-stage1
	core/build-tools-coreutils
	core/build-tools-make
	core/build-tools-patch
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

	patch -p1 <"$PLAN_CONTEXT/zstd-1.5.2-upstream_fixes-1.patch"
}

do_build() {
	make PREFIX="${pkg_prefix}"
}

# Note that this will take a while because it runs a few compressions(v1 -> v20)
# Also, runs a fuzzer for 5 minutes + 2 min(zbufftest) + 2 min(zstreamtest)
do_check() {
	make test
}

do_install() {
	make install

	# We want to statically link zstd into gcc so we remove
	# unnecessary shared libraries, binaries and pkgconfig
	rm -v "${pkg_prefix}"/lib/*.so*
	rm -rfv "${pkg_prefix:?}/lib/pkgconfig"
	rm -rfv "${pkg_prefix:?}/bin"
}
