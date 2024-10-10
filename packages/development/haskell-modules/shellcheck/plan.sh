program=ShellCheck

pkg_name=shellcheck
pkg_origin=core
pkg_version="0.10.0"
pkg_license=('GPL-3.0-only')
pkg_upstream_url="http://www.shellcheck.net/"
pkg_description="ShellCheck is a GPLv3 tool that gives warnings and suggestions for bash/sh shell scripts"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://hackage.haskell.org/package/ShellCheck-${pkg_version}/ShellCheck-${pkg_version}.tar.gz"
pkg_shasum="4d08db432d75a34486a55f6fff9d3e3340ce56125c7804b7f8fd14421b936d21"
pkg_dirname="ShellCheck-${pkg_version}"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

pkg_deps=(
	core/glibc
	core/gmp
	core/libffi
)

pkg_build_deps=(
	core/cabal-install
	core/ghc
)

do_clean() {
	do_default_clean

	# Strip any previous cabal config
	rm -rf /root/.cabal
}

do_build() {
	cabal update

	# Install dependencies
	#cabal install --only-dependencies

	# Configure and Build
	cabal configure --prefix="$pkg_prefix" --disable-executable-dynamic --disable-shared
	cabal build
}

do_install() {
	cabal install --installdir=${pkg_prefix}
}

do_check() {
	cabal test
}
