program="file"
pkg_name="build-tools-file"
pkg_origin="core"
pkg_version="5.43"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="file is a standard Unix program for recognizing the type of data contained in a computer file."
pkg_upstream_url="https://www.darwinsys.com/file/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="ftp://ftp.astron.com/pub/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="8c8015e91ae0e8d0321d94c78239892ef9dbc70c4ade0008c0e95894abfb1991"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix"
	make
}

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
