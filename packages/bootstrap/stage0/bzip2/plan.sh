program="bzip2"

pkg_name="bzip2-stage0"
pkg_origin="core"
pkg_version="1.0.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="bzip2 is a free and open-source file compression program that uses the Burrows–Wheeler algorithm. It only compresses single files and is not a file archiver."
pkg_upstream_url="https://www.sourceware.org/bzip2"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://fossies.org/linux/misc/${program}-${pkg_version}.tar.gz"
pkg_shasum="ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc-stage0
)

pkg_build_deps=(
	core/gcc-stage0
	core/build-tools-make
	core/build-tools-coreutils
	core/build-tools-patchelf
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	unset LDFLAGS
	unset LD_RUN_PATH
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
	build_line "Unset CFLAGS, CXXFLAGS, CPPFLAGS, LDFLAGS and LD_RUN_PATH"

	# Makes the symbolic links in installation relative vs. absolute
	# shellcheck disable=SC2016
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

	# Ensure that the man pages are installed under share/man
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
}

do_build() {
	# We add the '-Wl,-rpath' flag to ensure that the bzip-shared binary contains the final location
	# of the libbz2 shared library
	make -f Makefile-libbz2_so CFLAGS="-Wl,-rpath=${pkg_prefix}/lib" PREFIX="$pkg_prefix" CC="gcc"
	make CC="gcc"
}

do_check() {
	make test
}

do_install() {
	make install PREFIX="$pkg_prefix"

	mkdir -p "$pkg_prefix/lib"

	# Copy shared library
	cp -av libbz2.so.1.0.8 "$pkg_prefix/lib"
	ln -sv libbz2.so.1.0.8 "$pkg_prefix/lib/libbz2.so"
	ln -sv libbz2.so.1.0.8 "$pkg_prefix/lib/libbz2.so.1.0"

	# Copy shared binary to final location
	cp -av bzip2-shared "$pkg_prefix/bin/bzip2"
	ln -sfv bzip2 "$pkg_prefix/bin/bzcat"
	ln -sfv bzip2 "$pkg_prefix/bin/bunzip2"

	# Removes unnecesary rpath entry to build-tools-gcc/lib64
	patchelf --shrink-rpath "${pkg_prefix}/bin/bzip2"
	patchelf --shrink-rpath "${pkg_prefix}/bin/bzip2recover"
	patchelf --shrink-rpath "${pkg_prefix}/lib/libbz2.so.${pkg_version}"

}
