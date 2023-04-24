program="libcap"

pkg_name="libcap"
pkg_origin="core"
pkg_version="2.66"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The Libcap package implements the user-space interfaces to the POSIX 1003.1e capabilities \
available in Linux kernels. These capabilities are a partitioning of the all powerful \
root privilege into a set of distinct privileges.
"
pkg_upstream_url="http://sites.google.com/site/fullycapable/"
pkg_license=('GPL v2.0')
pkg_source="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/${program}-${pkg_version}.tar.gz"
pkg_shasum="20fbc13a2443881bf13f67eb4ec7f8d6b93843bf1ce7b3015ae1890ddfbd7324"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/attr
)
pkg_build_deps=(
	core/gcc
	core/build-tools-grep
	core/build-tools-make
	core/build-tools-sed
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	LDFLAGS="${LDFLAGS} -L${pkg_prefix}/lib -Wl,-rpath=${pkg_prefix}/lib"
	build_line "Updating LDFLAGS=${LDFLAGS}"
}

do_build() {
	make prefix="$pkg_prefix" lib=lib sbin=bin
}

do_check() {
	make test
}

do_install() {
	make prefix="$pkg_prefix" lib=lib sbin=bin install
}
