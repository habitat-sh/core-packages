pkg_name=fontconfig
pkg_origin=core
pkg_version="2.15.0"
pkg_license=('MIT' 'MIT-Modern-Variant' 'HPND-sell-variant')
pkg_description="Fontconfig is a library for configuring and customizing font access."
pkg_upstream_url=https://www.freedesktop.org/wiki/Software/fontconfig/
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://www.freedesktop.org/software/fontconfig/release/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="f5f359d6332861bd497570848fcb42520964a9e83d5e3abe397b6b6db9bcaaf4"

pkg_deps=(
  core/glibc
  core/freetype
  core/zlib
  core/libxml2
  core/icu
  core/xz
  core/bzip2
)
pkg_build_deps=(
  core/gcc
  core/make
  core/automake
  core/autoconf
  core/python
  core/gperf
  core/pkg-config
  core/m4
  core/gettext
  core/libtool
  core/file
  core/coreutils
  core/patchelf
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_prepare() {
  # Set freetype paths
  export FREETYPE_CFLAGS="${CFLAGS}"
  build_line "Setting FREETYPE_CFLAGS=${FREETYPE_CFLAGS}"
  export FREETYPE_LIBS="${LDFLAGS} -L$(pkg_path_for freetype)/lib -lfreetype -lz"
  build_line "Setting /FREETYPE_LIBS=${FREETYPE_LIBS}"

  # Add "freetype2" to include path
  export CFLAGS
  CFLAGS="${CFLAGS} -I$(pkg_path_for freetype)/include/freetype2"
  build_line "Setting CFLAGS=${CFLAGS}"

  # Borrowing this pro tip from ArchLinux!
  # https://projects.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/fontconfig#n34
  # this seems to run libtoolize though...
  autoreconf -fi

  _file_path="$(pkg_path_for file)/bin/file"
  _uname_path="$(pkg_path_for coreutils)/bin/uname"

  sed -e "s#/usr/bin/file#${_file_path}#g" -i configure
  sed -e "s#/usr/bin/uname#${_uname_path}#g" -i configure
}

do_build() {
  ./configure \
    --sysconfdir="${pkg_prefix}/etc" \
    --prefix="${pkg_prefix}" \
    --disable-static \
    --disable-docs \
    --mandir="${pkg_prefix}/man" \
    --enable-libxml2
  make
}

do_install() {
  do_default_install

  OUT=$(ls ${pkg_prefix}/bin)
  for file in $OUT; do
    patchelf --shrink-rpath ${pkg_prefix}/bin/$file
  done
}