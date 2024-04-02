program="libcap"

pkg_name="libcap-stage1"
pkg_origin="core"
pkg_version="2.66"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The Libcap package implements the user-space interfaces to the POSIX 1003.1e capabilities \
available in Linux kernels. These capabilities are a partitioning of the all powerful \
root privilege into a set of distinct privileges.
"
pkg_upstream_url="http://sites.google.com/site/fullycapable/"
pkg_license=('BSD-3-Clause OR GPL-2.0-only')
pkg_source="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/${program}-${pkg_version}.tar.gz"
pkg_shasum="20fbc13a2443881bf13f67eb4ec7f8d6b93843bf1ce7b3015ae1890ddfbd7324"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc
	core/build-tools-perl
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	make prefix="$pkg_prefix" lib=lib sbin=bin
}

do_check() {
	make test
}

do_install() {
	make prefix="$pkg_prefix" lib=lib sbin=bin install

	# Remove unnecessary components not required to build static coreutils
	rm -rfv "${pkg_prefix:?}"/bin
	rm -v "${pkg_prefix:?}"/lib/*.so*
	rm -rfv "${pkg_prefix:?}"/lib/pkgconfig
}
