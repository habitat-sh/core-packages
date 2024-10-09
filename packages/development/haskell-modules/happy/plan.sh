pkg_name=happy
pkg_origin=core
pkg_version="1.20.1.1"
pkg_license=('BSD-2-Clause')
pkg_upstream_url="https://www.haskell.org/happy/"
pkg_description="Happy is a parser generator for Haskell. Given a grammar specification in BNF, Happy generates Haskell code to parse the grammar. Happy works in a similar way to the yacc tool for C."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://hackage.haskell.org/package/${pkg_name}-${pkg_version}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="8b4e7dc5a6c5fd666f8f7163232931ab28746d0d17da8fa1cbd68be9e878881b"

pkg_deps=(
	core/glibc
	core/gmp
	# core/libffi
)
pkg_build_deps=(
	core/gcc-base
	core/cabal-install
	core/ghc-stage1
	core/make
)

pkg_bin_dirs=(bin)

do_clean() {
	do_default_clean

	# Strip any previous cabal config/cache
	rm -rf /root/.cabal
}

do_prepare() {
	# Set locale
	export LANG="en_US.utf8"
}

do_build() {
	cabal v2-update
	cabal v2-configure --prefix=${pkg_prefix} -w "$(pkg_path_for ghc-stage1)/bin/ghc" --disable-documentation
	cabal v2-build -v --extra-lib-dirs="$(pkg_path_for gmp)/lib" --extra-include-dirs="$(pkg_path_for gmp)/include"
}

do_install() {
	cabal install --installdir="${pkg_prefix}/bin" --install-method=copy --extra-include-dirs="$(pkg_path_for gmp)/include" --extra-lib-dirs="$(pkg_path_for gmp)/lib"
}

do_check() {
	cabal v2-test
}
