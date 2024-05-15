program="bzip2"

pkg_name="bzip2"
pkg_origin="core"
pkg_version="1.0.8"
pkg_major_version="1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="bzip2 is a free and open-source file compression program that uses the Burrows–Wheeler algorithm. It only compresses single files and is not a file archiver."
pkg_upstream_url="https://www.sourceware.org/bzip2"
pkg_license=('bzip2-1.0.6')
pkg_source="https://sourceware.org/pub/bzip2/bzip2-${pkg_version}.tar.gz"
pkg_shasum="ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/clang
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	patch -p0 <"$PLAN_CONTEXT/Makefile-man.patch"
	patch -p0 <"$PLAN_CONTEXT/Makefile-links.patch"
	cat "$PLAN_CONTEXT/Makefile-dylib.patch" |
		sed "s,@VERSION@,$pkg_version,g" |
		sed "s,@MAJOR_VERSION@,$pkg_major_version,g" |
		patch -p0
	
}

do_build() {
	export HAB_DEBUG=1
	make PREFIX="$pkg_prefix" CC="clang"
}

do_check() {
	make test
}

do_install() {
	make install PREFIX="$pkg_prefix"

	mkdir -p "$pkg_prefix/lib"

	# Copy shared library
	ln -sv libbz2.1.0.8.dylib "$pkg_prefix/lib/libbz2.dylib"
	ln -sv libbz2.1.0.8.dylib "$pkg_prefix/lib/libbz2.1.dylib"
	ln -sv libbz2.1.0.8.dylib "$pkg_prefix/lib/libbz2.1.0.dylib"

	# Copy shared binary to final location
	ln -sfv bzip2 "$pkg_prefix/bin/bzcat"
	ln -sfv bzip2 "$pkg_prefix/bin/bunzip2"
}
