pkg_name=sqlite
pkg_version=3.40.0
pkg_dist_version=3400000
pkg_origin=core
pkg_license=('Public Domain')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="A software library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine."
pkg_upstream_url=https://www.sqlite.org/
pkg_source="https://www.sqlite.org/2022/${pkg_name}-autoconf-${pkg_dist_version}.tar.gz"
pkg_filename="${pkg_name}-autoconf-${pkg_dist_version}.tar.gz"
pkg_dirname="${pkg_name}-autoconf-${pkg_dist_version}"
pkg_shasum=0333552076d2700c75352256e91c78bf5cd62491589ba0c69aed0a81868980e7
pkg_deps=(
  core/glibc
  core/readline
)
pkg_build_deps=(
  core/gcc
  core/make
  core/coreutils
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
