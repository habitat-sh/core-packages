program="bzip2"
pkg_name="build-tools-bzip2"
pkg_origin="core"
pkg_version="1.0.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="bzip2 is a free and open-source file compression program that uses the Burrows–Wheeler algorithm. It only compresses single files and is not a file archiver."
pkg_upstream_url="https://www.sourceware.org/bzip2"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://fossies.org/linux/misc/${program}-${pkg_version}.tar.gz"
pkg_shasum="ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	make -f Makefile-libbz2_so PREFIX="$pkg_prefix"
	make
}

do_check() {
	make test
}

do_install() {
	make install PREFIX="$pkg_prefix"
	# copy shared library
	cp -av libbz2.so.1.0.8 "$pkg_prefix/lib"
	ln -sv libbz2.so.1.0.8 "$pkg_prefix/lib/libbz2.so"
	ln -sv libbz2.so.1.0.8 "$pkg_prefix/lib/libbz2.so.1.0"
	# copy shared binary
	cp -av bzip2-shared "$pkg_prefix/bin/bzip2"
	ln -sfv bzip2 "$pkg_prefix/bin/bzcat"
	ln -sfv bzip2 "$pkg_prefix/bin/bunzip2"
	# remove static library
	rm -fv "$pkg_prefix/lib/libbz2.a"
}
