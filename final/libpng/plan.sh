pkg_name="libpng"
pkg_version="1.6.37"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("libpng-2.0")
pkg_description="An Open, Extensible Image Format with Lossless Compression"
pkg_upstream_url=http://www.libpng.org/pub/png/
pkg_source="http://download.sourceforge.net/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz"
pkg_filename="${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4"
pkg_deps=(
	core/glibc
	core/zlib
)
pkg_build_deps=(
	core/coreutils
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="${pkg_prefix}"
	make
}

do_check() {
	make test
}
