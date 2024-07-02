pkg_name="cabal-stage1"
pkg_origin=core
pkg_version="3.0.0.0"
pkg_license=('')
pkg_upstream_url="https://www.haskell.org/cabal/"
pkg_description="Command-line interface for Cabal and Hackage"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://downloads.haskell.org/~cabal/cabal-install-${pkg_version}/cabal-install-${pkg_version}-x86_64-unknown-linux.tar.xz"
pkg_shasum="ee911ba67a70756eedeac662955b896d7e89432a99372aa45d2c6e71fa95a5e4"
pkg_dirname="${pkg_name}-${pkg_version}"

pkg_deps=(
	core/build-tools-glibc
	core/build-tools-gcc-libs
)

pkg_build_deps=(
	core/native-patchelf
)

pkg_bin_dirs=(bin)

do_build() {
	return 0
}

do_install() {
	mv ${HAB_CACHE_SRC_PATH}/cabal ${pkg_prefix}/bin
	mv ${HAB_CACHE_SRC_PATH}/cabal.sig ${pkg_prefix}

	dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-x86-64.so.2"
	patchelf --set-rpath "$(pkg_path_for build-tools-glibc)/lib:$(pkg_path_for build-tools-gcc-libs)/lib" --set-interpreter "$dynamic_linker" "$pkg_prefix"/bin/cabal
}
