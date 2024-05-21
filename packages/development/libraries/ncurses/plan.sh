program="ncurses"

pkg_name="ncurses"
pkg_origin="core"
pkg_version="6.5"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('X11-distribute-modifications-variant')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/clang
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include include/ncursesw)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# export PKG_CONFIG_LIBDIR="${pkg_prefix}/lib/pkgconfig"
	# build_line "Setting PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR}"
	patch -p0 <"$PLAN_CONTEXT/hex.patch"
	patch -p0 <"$PLAN_CONTEXT/modules.patch"
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--enable-widec \
		--disable-lib-suffixes \
		--enable-overwrite \
		--with-shared \
		--with-cxx-shared \
		--without-debug  \
		--without-ada \
		--with-manpage-format=normal \
		--without-pkg-config \
		--enable-pc-files \
		--with-pkg-config-libdir="${pkg_prefix}/lib/pkgconfig" \
		--disable-mixed-case

	make
}

do_install() {
	make install

	# Many packages that use Ncurses will compile just fine against the widechar
	# libraries, but won't know to look for them. Create symbolic links to
	# allow older and non-widec compatible programs to build properly
	major="6"
	for lib in ncurses ncurses++ form panel menu; do
		# rm -vf "${pkg_prefix}/lib/lib${lib}.dylib"
		ln -sv lib${lib}.${major}.dylib "${pkg_prefix}/lib/lib${lib}w.dylib"
        ln -sv lib${lib}.${major}.dylib "${pkg_prefix}/lib/lib${lib}w.${major}.dylib"
        ln -sv lib${lib}.a "${pkg_prefix}/lib/lib${lib}w.a"
        ln -sv ${lib}.pc "${pkg_prefix}/lib/pkgconfig/${lib}w.pc"
	done

	ln -sv libncurses.${major}.dylib "${pkg_prefix}/lib/libtermcap.dylib"
    ln -sv ncurses6-config "${pkg_prefix}/bin/ncursesw6-config"

	# Packages depending on curses or ncurses may include headers
	# in multiple ways:
	# * #include <curses.h>
	# * #include <ncurses/curses.h>
	# * #include <ncursesw/curses.h>
	# By adding a symlink from 'ncurses' to 'ncursesw' and including
	# both the 'include' and 'include/ncursesw' folder to the include dirs
	# we can satisfy all these cases correctly
	ln -sv ncursesw "${pkg_prefix}/include/ncurses"
}

do_check() {
	make check
}
