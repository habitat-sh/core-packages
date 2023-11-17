pkg_name=libyajl2
pkg_origin=core
pkg_version="2.1.0"
pkg_description="Yet Another JSON Library"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("ISC")
pkg_upstream_url="https://github.com/lloyd/yajl"
pkg_source="https://github.com/lloyd/yajl/archive/refs/tags/${pkg_version}.tar.gz"
pkg_dirname="yajl-${pkg_version}"
pkg_filename="${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="3fb73364a5a30efe615046d07e6db9d09fd2b41c763c5f7d3bfb121cd5c5ac5a"
pkg_deps=(core/glibc)
pkg_build_deps=(core/busybox-static core/cmake core/doxygen core/gcc core/make core/patchelf)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(share/pkgconfig)

do_build() {
  mkdir local-build
  pushd local-build || exit 1
  cmake \
    -DCMAKE_INSTALL_PREFIX="${pkg_prefix}" \
    -DCMAKE_SKIP_RPATH="TRUE" \
    ..
  make
  popd || exit 1
}

do_install() {
  pushd local-build || exit 1
  make install
  popd || exit 1
}