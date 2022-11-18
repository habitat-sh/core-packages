program="ncurses"

pkg_name="ncurses-stage1"
pkg_origin="core"
pkg_version="6.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('ncurses')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc-stage1
	core/build-tools-make
	core/build-tools-bash-static
	core/build-tools-coreutils
	core/build-tools-patchelf
	core/glibc-stage0
	core/linux-headers
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--without-shared \
		--without-debug \
		--without-ada \
		--disable-stripping \
		--enable-widec
	make
}

do_install() {
	make install
	rm -rf "${pkg_prefix:?}/bin"
	echo "INPUT(-lncursesw)" >"$pkg_prefix/lib/libcurses.a"
}

do_check() {
	make check
}
