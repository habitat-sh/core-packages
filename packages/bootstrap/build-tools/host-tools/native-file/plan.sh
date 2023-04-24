program="file"

pkg_name="native-file"
pkg_origin="core"
pkg_version="5.42"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
file is a standard Unix program for recognizing the type of data contained in \
a computer file.\
"
pkg_upstream_url="https://www.darwinsys.com/file/"
pkg_license=('LicenseRef-file')
pkg_source="ftp://ftp.astron.com/pub/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="c076fb4d029c74073f15c43361ef572cfb868407d347190ba834af3b1639b0e4"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=()
pkg_build_deps=()
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--disable-bzlib \
		--disable-libseccomp \
		--disable-xzlib \
		--disable-zlib
	make
}

do_install() {
	make install
}
