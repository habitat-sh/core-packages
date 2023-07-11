pkg_name="libidn"
pkg_origin="core"
pkg_version="1.38"
pkg_description="Implementation of IDNA2008, Punycode and TR46 (Internationalized domain names)"
pkg_upstream_url="https://www.gnu.org/software/libidn/#libidn2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
# The installed libraries are licensed under 'GPL-2.0-or-later OR LGPL-3.0-or-later'
# https://gitlab.com/libidn/libidn/-/blob/v1.38/COPYING?ref_type=tags
pkg_license=('GPL-2.0-or-later OR LGPL-3.0-or-later' 'Unicode-TOU' 'Unicode-DFS-2016')
pkg_source="http://ftp.gnu.org/gnu/$pkg_name/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="de00b840f757cd3bb14dd9a20d5936473235ddcba06d4bc2da804654b8bbf0f6"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/gettext
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_check() {
	make check
}
