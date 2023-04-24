program="file"

pkg_name="file"
pkg_origin="core"
pkg_version="5.42"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
file is a standard Unix program for recognizing the type of data contained in \
a computer file.\
"
pkg_upstream_url="https://www.darwinsys.com/file/"
pkg_license=("LicenseRef-file")
pkg_source="ftp://ftp.astron.com/pub/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="c076fb4d029c74073f15c43361ef572cfb868407d347190ba834af3b1639b0e4"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/bzip2
	core/xz
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

do_check() {
	make check
}

do_install() {
	make install

	# As per the copyright, we must include the copyright statement in binary
	# distributions
	#
	# Source: https://github.com/file/file/blob/master/COPYING
	install -v -Dm644 COPYING "$pkg_prefix/share/COPYING"
}
