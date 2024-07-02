program="ghc"

pkg_name="ghc-stage1"
pkg_origin=core
pkg_version="8.10.7"
pkg_license=('BSD-3-Clause' 'BSD-2-Clause' 'BSD-Source-Code' 'HaskellReport')
pkg_upstream_url="https://www.haskell.org/ghc/"
pkg_description="The Glasgow Haskell Compiler"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://downloads.haskell.org/~ghc/${pkg_version}/ghc-${pkg_version}-x86_64-centos7-linux.tar.xz"
pkg_shasum="262a50bfb5b7c8770e0d99f54d42e5876968da7bf93e2e4d6cfe397891a36d05"
pkg_dirname="ghc-${pkg_version}"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=("lib/ghc-${pkg_version}/include")
#pkg_interpreters=(bin/runhaskell bin/runghc)

pkg_build_deps=(
	core/make
	core/gcc-base
	core/ncurses
	core/cabal-install
)

pkg_deps=(
)

do_build() {
	${CACHE_PATH}/configure --prefix=${pkg_prefix}
}

do_install() {
	make install
}
