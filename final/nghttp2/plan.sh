pkg_name=nghttp2
pkg_origin=core
pkg_version=1.51.0
pkg_description="nghttp2 is an open source HTTP/2 C Library."
pkg_upstream_url=https://nghttp2.org/
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_source="https://github.com/${pkg_name}/${pkg_name}/releases/download/v${pkg_version}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum=2a0bef286f65b35c24250432e7ec042441a8157a5b93519412d9055169d9ce54
pkg_build_deps=(
  core/make
  core/gcc
  core/python
)
pkg_deps=(
    core/glibc
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
