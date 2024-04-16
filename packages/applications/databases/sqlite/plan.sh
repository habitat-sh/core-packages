pkg_name="sqlite"
pkg_version="3.45.3"
pkg_dist_version="3450300"
pkg_origin="core"
pkg_license=('LicenseRef-Public-Domain')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="A software library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine."
pkg_upstream_url=https://www.sqlite.org/
pkg_source="https://www.sqlite.org/2024/${pkg_name}-autoconf-${pkg_dist_version}.tar.gz"
pkg_filename="${pkg_name}-autoconf-${pkg_dist_version}.tar.gz"
pkg_dirname="${pkg_name}-autoconf-${pkg_dist_version}"
pkg_shasum="b2809ca53124c19c60f42bf627736eae011afdcc205bb48270a5ee9a38191531"
pkg_deps=(
	core/glibc
	core/readline
	core/zlib
)
pkg_build_deps=(
	core/coreutils
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)