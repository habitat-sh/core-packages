pkg_name="nettle"
pkg_origin="core"
pkg_version="3.8.1"
pkg_description="A low-level cryptographic library"
pkg_upstream_url="https://www.lysator.liu.se/~nisse/nettle/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('LGPL-3.0-only' 'GPL-2.0-only' 'GPL-3.0-only')
pkg_source="https://ftp.gnu.org/gnu/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="364f3e2b77cd7dcde83fd7c45219c834e54b0c75e428b6f894a23d12dd41cbfe"
pkg_deps=(
	core/glibc
	core/gmp
)
pkg_build_deps=(
	core/m4
	core/gcc
	core/pkg-config
	core/valgrind
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_check() {
	make check
}
