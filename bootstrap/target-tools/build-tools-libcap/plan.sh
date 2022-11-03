program="libcap"
pkg_name="build-tools-libcap"
pkg_origin="core"
pkg_version="2.66"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Libcap implements the user-space interfaces to the POSIX 1003.1e capabilities available in Linux kernels. These capabilities are a partitioning of the all powerful root privilege into a set of distinct privileges."
pkg_upstream_url="http://sites.google.com/site/fullycapable/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/${program}-${pkg_version}.tar.xz"
pkg_shasum="15c40ededb3003d70a283fe587a36b7d19c8b3b554e33f86129c059a4bb466b2"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    make prefix="$pkg_prefix" lib=lib
}

do_check() {
	make test
}

do_install() {
    make prefix="$pkg_prefix" lib=lib install
}
