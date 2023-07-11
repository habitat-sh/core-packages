pkg_name="libxslt"
pkg_origin="core"
pkg_version="1.1.34"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Libxslt is the XSLT C library developed for the GNOME project"
pkg_upstream_url="http://xmlsoft.org/XSLT/"
pkg_license=('MIT')
pkg_source="http://xmlsoft.org/sources/libxslt-${pkg_version}.tar.gz"
pkg_shasum="98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f"

pkg_deps=(
	core/glibc
	core/libxml2
	core/zlib
)
pkg_build_deps=(
	core/gcc
	core/pkg-config
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_check() {
	make check
}
