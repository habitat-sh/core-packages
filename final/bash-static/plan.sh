program="bash"

pkg_name="bash-static"
pkg_origin="core"
pkg_version="5.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
 Bash is the GNU Project's shell. Bash is the Bourne Again SHell. Bash is an \
sh-compatible shell that incorporates useful features from the Korn shell \
(ksh) and C shell (csh). It is intended to conform to the IEEE POSIX \
P1003.2/ISO 9945.2 Shell and Tools standard. It offers functional \
improvements over sh for both programming and interactive use. In addition, \
most sh scripts can be run by Bash without modification.\
"
pkg_upstream_url="http://www.gnu.org/software/bash/bash.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="cc012bc860406dcf42f64431bcd3d2fa7560c02915a601aba9cd597a39329baa"
pkg_dirname="${program}-${pkg_version}"
pkg_interpreters=(
	bin/sh
	bin/bash
)
pkg_build_deps=(
	core/glibc-base
	core/gcc-stage1
	core/ncurses-stage1
	core/readline-stage1
)
pkg_bin_dirs=(bin)

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
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--without-bash-malloc \
		--enable-static-link
	make
}

do_install() {
	make install
	ln -sv bash "$pkg_prefix/bin/sh"

	# Remove unnecessary binaries
	rm -v "${pkg_prefix}/bin/bashbug"
}
