program=libatomic_ops
pkg_name=libatomic_ops
pkg_origin=core
pkg_version=7.8.2
pkg_description="Atomic memory update operations"
pkg_upstream_url="https://github.com/ivmai/libatomic_ops"
pkg_license=('GPL-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://www.ivmaisoft.com/_bin/atomic_ops/libatomic_ops-${pkg_version}.tar.gz"
pkg_shasum=d305207fe207f2b3fb5cb4c019da12b44ce3fcbc593dfd5080d867b1a2419b51
pkg_deps=(core/glibc)
pkg_build_deps=(
  core/gcc 
  core/make 
  core/diffutils
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_check() {
  make check
}
