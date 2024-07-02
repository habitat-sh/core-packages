program=boost
pkg_name=boost
pkg_origin=core
pkg_description='Boost provides free peer-reviewed portable C++ source libraries.'
pkg_upstream_url='http://www.boost.org/'
pkg_version=1.85.0
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('')
pkg_source=http://downloads.sourceforge.net/project/boost/boost/${pkg_version}/boost_1_85_0.tar.gz
pkg_shasum=be0d91732d5b0cc6fbb275c7939974457e79b54d6f07ce2e3dfdd68bef883b0b
pkg_dirname=boost_1_85_0

pkg_deps=(
  core/glibc
  core/gcc-base
  core/zlib
)

pkg_build_deps=(
  core/coreutils
  core/diffutils
  core/patch
  core/make
  core/gcc
  core/python
  core/libxml2
  core/libxslt
  core/openssl
  core/which
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_before() {
  ln -fs "$(pkg_path_for core/coreutils)/bin/env" "/usr/bin/env"
}

do_build() {
  ./bootstrap.sh --prefix="$pkg_prefix"
}

do_install() {
  export NO_BZIP2=1
  export ZLIB_LIBPATH
  ZLIB_LIBPATH="$(pkg_path_for core/zlib)/lib"
  export ZLIB_INCLUDE
  ZLIB_INCLUDE="$(pkg_path_for core/zlib)/include"
  ./b2 install --prefix="$pkg_prefix" -q --debug-configuration
}

