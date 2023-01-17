program="m4"

pkg_name="m4-stage0"
pkg_origin="core"
pkg_version="1.4.19"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="GNU M4 is an implementation of the traditional Unix macro processor. It is mostly SVR4 compatible although it has some extensions (for example, handling more than 9 positional parameters to macros). GNU M4 also has built-in functions for including files, running shell commands, doing arithmetic, etc."
pkg_upstream_url="http://www.gnu.org/software/m4"
pkg_license=('gplv3')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc-stage0
)

pkg_build_deps=(
	core/gcc-stage0
	core/build-tools-make
	core/build-tools-bash-static
	core/build-tools-coreutils
	core/build-tools-patchelf
)

pkg_bin_dirs=(bin)

do_check() {
	make check
}

do_install() {
	make install
	patchelf --shrink-rpath "$pkg_prefix/bin/m4"
}
