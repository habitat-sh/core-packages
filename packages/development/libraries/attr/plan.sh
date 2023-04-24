program="attr"

pkg_name="attr"
pkg_origin="core"
pkg_version="2.5.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Commands for Manipulating Filesystem Extended Attributes.
"
pkg_upstream_url="https://savannah.nongnu.org/projects/attr/"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://download.savannah.gnu.org/releases/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="bae1c6949b258a0d68001367ce0c741cebdacdd3b62965d17e5eb23cd78adaf8"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)

pkg_build_deps=(
	core/gcc
	core/coreutils-stage1
	core/build-tools-make
	core/build-tools-perl
	core/build-tools-sed
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--sysconfdir="$pkg_prefix/etc" \
		--docdir="$pkg_prefix/share/doc/attr-2.5.1"
	make
}

do_check() {
	sed -e "s^#\!.*bin/perl^#\!$(pkg_path_for build-tools-perl)/bin/perl^" -i "${SRC_PATH}/test/run"
	sed -e "s^#\!.*bin/perl^#\!$(pkg_path_for build-tools-perl)/bin/perl^" -i "${SRC_PATH}/test/sort-getfattr-output"
	make check
}

do_install() {
	make install
}
