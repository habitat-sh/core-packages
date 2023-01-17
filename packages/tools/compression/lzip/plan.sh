pkg_name="lzip"
pkg_origin="core"
pkg_version="1.23"
pkg_description="A lossless data compressor with a user interface similar to the one of gzip or bzip2."
pkg_upstream_url="http://www.nongnu.org/lzip/lzip.html"
pkg_license=('GPL-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://download.savannah.gnu.org/releases/lzip/lzip-${pkg_version}.tar.gz"
pkg_shasum="4792c047ddf15ef29d55ba8e68a1a21e0cb7692d87ecdf7204419864582f280d"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/grep
	core/make
	core/sed
)
pkg_bin_dirs=(bin)

do_check() {
	make check
}
