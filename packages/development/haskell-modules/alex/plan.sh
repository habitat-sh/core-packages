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
)
pkg_build_deps=(
	core/cabal-install
	core/ghc
	core/pkg-config
)

pkg_bin_dirs=(bin)

do_clean() {
	do_default_clean

	# Strip any previous cabal config/cache
	rm -rf /root/.cache/cabal
}

do_build() {
	cabal update
	cabal configure --prefix=${pkg_prefix} -w ghc-9.10.1 --extra-lib-dirs=$(pkg_path_for gmp)/lib --disable-documentation --disable-tests --disable-coverage
	cabal build
}

do_install() {
	cabal install --installdir=${pkg_prefix}/bin
	# delete symlink to binary and copy binary
	rm -f ${pkg_prefix}/bin/alex
	cp $CACHE_PATH/dist-newstyle/build/x86_64-linux/ghc-9.10.1/alex-3.5.1.0/x/alex/build/alex/alex ${pkg_prefix}/bin
}

do_check() {
	cabal test
}
