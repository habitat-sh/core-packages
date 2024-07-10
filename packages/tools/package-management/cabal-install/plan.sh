pkg_name="cabal-install"
pkg_origin=core
pkg_version="3.10.3.0"
pkg_license=('')
pkg_upstream_url="https://www.haskell.org/cabal/"
pkg_description="Command-line interface for Cabal and Hackage"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://downloads.haskell.org/~cabal/cabal-install-${pkg_version}/cabal-install-${pkg_version}-x86_64-linux-deb9.tar.xz"
pkg_shasum="97e61bcd143f0b8a181ea2261a1de587b58fa9f84d123b9b9cec4463ae2f41c6"
#pkg_dirname="${pkg_name}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/zlib
	core/gmp
)

pkg_build_deps=(
	core/patchelf
)

pkg_bin_dirs=(bin)

do_clean() {
  do_default_clean

  # Strip any previous cabal config
  rm -rf /root/.cabal
}

do_build() {
	return 0
}

do_install() {
	mv ${HAB_CACHE_SRC_PATH}/cabal ${pkg_prefix}/bin
	mv ${HAB_CACHE_SRC_PATH}/plan.json ${pkg_prefix}/bin

	dynamic_linker="$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2"
	patchelf --set-rpath "$(pkg_path_for glibc)/lib:$(pkg_path_for zlib)/lib:$(pkg_path_for gmp)/lib" --set-interpreter "$dynamic_linker" "$pkg_prefix"/bin/cabal
}

do_strip() {
	return 0
}