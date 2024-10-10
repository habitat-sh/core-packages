pkg_name="cabal-install"
pkg_origin=core
pkg_version="3.12.1.0"
pkg_license=('')
pkg_upstream_url="https://www.haskell.org/cabal/"
pkg_description="Command-line interface for Cabal and Hackage"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://downloads.haskell.org/~cabal/cabal-install-${pkg_version}/cabal-install-${pkg_version}-x86_64-linux-deb11.tar.xz"
pkg_shasum="4f60cf1c72f4ad4d82d668839ac61ae15ae4faf6c4b809395799e8a3ee622051"

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
	cp ${HAB_CACHE_SRC_PATH}/cabal ${pkg_prefix}/bin
	cp ${HAB_CACHE_SRC_PATH}/plan.json ${pkg_prefix}/bin

	LD_RUN_PATH=${LD_RUN_PATH}:$(pkg_path_for glibc)/lib:$(pkg_path_for gmp)/lib:$(pkg_path_for zlib)/lib

	build_line "Setting rpath for all binaries to '${LD_RUN_PATH}'"
	patchelf --set-rpath "${LD_RUN_PATH}" ${pkg_prefix}/bin/cabal
	patchelf --set-interpreter $(pkg_path_for glibc)/lib64/ld-linux-x86-64.so.2 ${pkg_prefix}/bin/cabal
}

do_strip() {
	return 0
}
