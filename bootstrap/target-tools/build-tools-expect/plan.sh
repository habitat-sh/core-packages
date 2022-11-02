program="expect"
pkg_name="build-tools-expect"
pkg_origin="core"
pkg_version="5.45.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Expect is a tool for automating interactive applications such as telnet, ftp, passwd, fsck, rlogin, tip, etc. Expect really makes this stuff trivial. Expect is also useful for testing these same applications."
pkg_upstream_url="https://core.tcl-lang.org/expect/index"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://downloads.sourceforge.net/project/${program}/Expect/${pkg_version}/${program}${pkg_version}.tar.gz"
pkg_shasum="49a7da83b0bdd9f46d04a04deec19c7767bb9a323e40c4781f89caf760b92c34"
pkg_dirname="${program}${pkg_version}"
pkg_deps=(
)

pkg_build_deps=(
	core/build-tools-gcc
	core/build-tools-tcl
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-tcl="$(pkg_path_for build-tools-tcl)/lib" \
		--enable-shared \
		--mandir="$pkg_prefix"/share/man \
		--with-tclinclude="$(pkg_path_for build-tools-tcl)/include" \
		--build=$(uname -m)-unknown-linux-gnu
	make
}

do_check() {
	make test
}

do_install() {
    make PREFIX="${pkg_prefix}" install 
}
