program="uuid"

pkg_name="libossp-uuid"
pkg_origin="core"
pkg_description="OSSP uuid is a ISO-C:1999 application programming interface (API) and corresponding command line interface (CLI) for the generation of DCE 1.1"
pkg_upstream_url="http://www.ossp.org/pkg/lib/uuid/"
pkg_version="1.6.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_source="https://www.mirrorservice.org/sites/ftp.ossp.org/pkg/lib/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="11a615225baa5f8bb686824423f50e4427acd3f70d394765bdff32801f0fd5b0"
pkg_dirname="${program}-${pkg_version}"
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
)
do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="${TARGET_ARCH:-${pkg_target%%-*}}-unknown-linux-gnu"

	make
}
