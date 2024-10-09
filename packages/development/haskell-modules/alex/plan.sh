pkg_name=alex
pkg_origin=core
pkg_version="3.5.1.0"
pkg_license=("BSD-3-Clause")
pkg_upstream_url=http://www.haskell.org/alex/
pkg_description="Alex is a tool for generating lexical analysers in Haskell. It takes a description of tokens based on regular expressions and generates a Haskell module containing code for scanning text efficiently. It is similar to the tool lex or flex for C/C++."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://hackage.haskell.org/package/${pkg_name}-${pkg_version}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="c92efe86f8eb959ee03be6c04ee57ebc7e4abc75a6c4b26551215d7443e92a07"

pkg_deps=(
	core/glibc
	core/gmp
	#core/libffi
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

do_build() {
	export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(pkg_path_for gmp)/lib
	cabal v2-update
	cabal v2-configure --prefix=${pkg_prefix} -w "$(pkg_path_for ghc-stage1)/bin/ghc" --disable-documentation
	cabal v2-build -v --extra-lib-dirs="$(pkg_path_for gmp)/lib" --extra-include-dirs="$(pkg_path_for gmp)/include"
}

do_install() {
	cabal v2-install --installdir="${pkg_prefix}/bin" --install-method=copy --extra-include-dirs="$(pkg_path_for gmp)/include" --extra-lib-dirs="$(pkg_path_for gmp)/lib"
}

do_check() {
	cabal v2-test
}
