program="ncurses"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-ncurses"
pkg_origin="core"
pkg_version="6.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('LicenseRef-ncurses')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/build-tools-libstdcxx
	core/build-tools-glibc
)
pkg_build_deps=(
	core/native-cross-gcc
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(
	include
	include/ncursesw
)
pkg_lib_dirs=(lib)

do_prepare() {
	# During ncurses cross-building, the host system's compiler is used to compile
	# intermediate tools. To avoid linking issues caused by the LD_RUN_PATH variable,
	# it is unset before the build process, ensuring the correct glibc version is
	# used and the tools run properly.  To make sure the native-cross-binutil's linker
	# uses LD_RUN_PATH for the correct rpath, LD_RUN_PATH is assigned to HAB_LD_RUN_PATH.
	export HAB_LD_RUN_PATH="${LD_RUN_PATH}"
	unset LD_RUN_PATH
	build_line "Setting HAB_LD_RUN_PATH=${HAB_LD_RUN_PATH}"
	build_line "Unsetting LD_RUN_PATH"
}

do_build() {
	sed -i s/mawk// configure

	# We run this in a sub shell so we can preserve the original build environment
	(
		mkdir build
		pushd build || exit 1

		# We clear out all environment variables that interfere with the native compiler
		unset PREFIX
		unset PKG_CONFIG_PATH
		unset LD_RUN_PATH
		unset LDFLAGS
		unset CFLAGS
		unset CPPFLAGS
		unset CXXFLAGS

		../configure \
			--build="$(../config.guess)" \
			--host="$(../config.guess)" \
			--target="$(../config.guess)" \
			--with-build-cflags="" \
			--with-build-cppflags="" \
			--with-build-ldflags=""
		make -C include
		make -C progs tic
		popd || exit 1
	)

	./configure \
		--prefix="$pkg_prefix" \
		--build="$(./config.guess)" \
		--host="$native_target" \
		--with-shared \
		--with-cxx-shared \
		--without-debug \
		--without-ada \
		--disable-stripping \
		--with-build-cflags="" \
		--with-build-cppflags="" \
		--with-build-ldflags="" \
		--enable-widec
	make
}

do_install() {
	make TIC_PATH="$(pwd)"/build/progs/tic install

	for x in ncurses ncurses++ form panel menu tinfo; do
		echo "INPUT(-l${x}w)" >"$pkg_prefix/lib/lib${x}.so"
	done
	echo "INPUT(-lncursesw)" >"$pkg_prefix/lib/libcurses.so"
	echo "INPUT(-lncursesw)" >"$pkg_prefix/lib/libcurses.a"

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
