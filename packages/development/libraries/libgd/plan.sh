pkg_name=libgd
pkg_origin=core
pkg_version="2.3.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('LicenseRef-libgd')
pkg_source="https://github.com/$pkg_name/$pkg_name/releases/download/gd-$pkg_version/$pkg_name-$pkg_version.tar.xz"
pkg_shasum=3fe822ece20796060af63b7c60acb151e5844204d289da0ce08f8fdf131e5a61
pkg_deps=(
  core/fontconfig
  core/freetype
  core/libjpeg-turbo
  core/libpng
  core/libtiff
  core/zlib
  core/perl
)
pkg_build_deps=(
  core/diffutils
  core/file
  core/gcc
  core/make
  core/pkg-config
  core/bzip2
  core/jbigkit
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_pconfig_dirs=(lib/pkgconfig)
pkg_description="GD is an open source code library for the dynamic creation of images by programmers."
pkg_upstream_url="https://libgd.github.io"

do_prepare() {
  if [ ! -e /usr/bin/file ]
  then
    ln -sv "$(pkg_path_for core/file)/bin/file" /usr/bin/file
  fi
}

do_check() {
  LD_LIBRARY_PATH="${LD_RUN_PATH}:$(pkg_path_for bzip2)/lib:$(pkg_path_for jbigkit)/lib"
  export LD_LIBRARY_PATH
  # Failure: https://github.com/libgd/libgd/issues/367
  make check
}

do_install() {
  make install
  fix_interpreter "${pkg_prefix}/bin/bdftogd" core/perl bin/perl
}

do_end() {
  if [ -e /usr/bin/file ]
  then
    rm /usr/bin/file
  fi
}
