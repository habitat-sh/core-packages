pkg_name="libb2"
pkg_origin="core"
pkg_version="0.98.1"
pkg_license=('CC0-1.0')
pkg_source="https://github.com/BLAKE2/libb2/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_upstream_url="https://www.blake2.net/"
pkg_description="The BLAKE2 family of cryptographic hash functions"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_shasum="10053dbc2fa342516b780a6bbf6e7b2a2360b8d49c5ac426936bf3df82526732"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/automake
	core/gcc
	core/libtool
	core/pkg-config
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${pkg_prefix}/lib/pkgconfig"
	build_line "Updating PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
	export ACLOCAL_PATH="$(pkg_path_for gettext)/share/aclocal:$(pkg_path_for libtool)/share/aclocal:$(pkg_path_for pkg-config)/share/aclocal"
}

do_build() {
	./autogen.sh
	./configure --prefix="${pkg_prefix}"
	make -j"$(nproc)"
}

do_check() {
	make check
}
