program="ncurses"

pkg_name="ncurses"
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

pkg_deps=(
	core/glibc
	core/gcc-libs
	core/bash-static
)

pkg_build_deps=(
	core/coreutils
	core/gcc
	core/grep
	core/make
	core/pcre2
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include include/ncursesw)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# Add the ncurses's lib folder to the rpath because several
	# binaries look for ncurses's own libraries.
	LDFLAGS="${LDFLAGS} -Wl,-rpath=${pkg_prefix}/lib"
	build_line "Updating LDFLAGS=${LDFLAGS}"
	PKG_CONFIG_LIBDIR="${pkg_prefix}/lib/pkgconfig"
	export PKG_CONFIG_LIBDIR
	build_line "Setting PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR}"
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-shared \
		--with-normal \
		--with-pcre2 \
		--with-cxx-shared \
		--without-debug \
		--enable-pc-files \
		--with-pkg-config-libdir="${pkg_prefix}/lib/pkgconfig" \
		--enable-symlinks \
		--enable-ext-colors \
		--enable-ext-mouse \
		--enable-sigwinch \
		--enable-widec

	# Replace pcre2 linking flag with -l:libpcre2-posix.a in all the
	# generate makefiles which will force the linker to statically link in pcre2.
	# We do not want to have pcre2 as a runtime dep as it brings in a lot of extra
	# runtime dependencies of it's own.
	# We have to do this here at this point, because the configure script gets
	# the linking flags from pkg-config which will always return '-lpcre2-posix' no
	# matter what. Also since we are static linking we have to mention all additional
	# dependencies our static library refers to, in this case we add '-l:libpcre2-8.a'.
	find ./ -name Makefile -exec sed -i -e 's|-lpcre2-posix|-l:libpcre2-posix.a -l:libpcre2-8.a|' {} +

	make
}

do_install() {
	make install

	# Many packages that use Ncurses will compile just fine against the widechar
	# libraries, but won't know to look for them. Create linker scripts and
	# symbolic links to allow older and non-widec compatible programs to build
	# properly
	for lib in ncurses form panel menu; do
		rm -vf "${pkg_prefix}/lib/lib${lib}.so"
		echo "INPUT(-l${lib}w)" >"${pkg_prefix}/lib/lib${lib}.a"
		echo "INPUT(-l${lib}w)" >"${pkg_prefix}/lib/lib${lib}.so"
		ln -sfv ${lib}w.pc "${pkg_prefix}/lib/pkgconfig/${lib}.pc"
	done

	# Add additional linker scripts so that any programs looking for curses
	# will find ncurses
	echo "INPUT(-lncursesw)" >"${pkg_prefix}/lib/libcurses.so"
	echo "INPUT(-lncursesw)" >"${pkg_prefix}/lib/libcurses.a"

	# Packages depending on curses or ncurses may include headers
	# in multiple ways:
	# * #include <curses.h>
	# * #include <ncurses/curses.h>
	# * #include <ncursesw/curses.h>
	# By adding a symlink from 'ncurses' to 'ncursesw' and including
	# both the 'include' and 'include/ncursesw' folder to the include dirs
	# we can satisfy all these cases correctly
	ln -sv ncursesw "${pkg_prefix}/include/ncurses"

	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/ncursesw6-config" core/bash-static bin/sh
}

do_check() {
	make check
}
