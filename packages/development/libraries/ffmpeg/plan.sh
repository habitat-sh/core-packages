pkg_name=ffmpeg
pkg_origin=core
pkg_version="7.0.2"
pkg_description="A complete, cross-platform solution to record, convert and stream audio and video."
pkg_upstream_url=https://ffmpeg.org/
pkg_license=('GPL-2.0-only' 'GPL-3.0-only' 'LGPL-2.1-only')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://ffmpeg.org/releases/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="1233b3a93dd7517cc3c56b72a67f64041c044848d981e3deff4bebffa25f1054"

pkg_deps=(
  core/fontconfig
  core/glibc
  core/libdrm
  core/libwebp
  core/openjpeg
  core/zlib
  core/gnutls
  core/libxml2
  core/gmp
  core/freetype
)
pkg_build_deps=(
  core/libidn2
  core/gcc
  core/libtasn1
  core/make
  core/nettle
  core/p11-kit
  core/pkg-config
  core/nasm
  core/patchelf
  core/avisynthplus
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
  ./configure --prefix="${pkg_prefix}" \
    --disable-debug \
    --disable-doc \
    --disable-static \
    --enable-avisynth \
    --disable-stripping \
    --enable-fontconfig \
    --enable-gmp \
    --enable-gnutls \
    --enable-gpl \
    --enable-version3 \
    --enable-libdrm \
    --enable-libfreetype \
    --enable-libopenjpeg \
    --enable-libwebp \
    --enable-libxml2 \
    --enable-shared

  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":"$(pkg_path_for gnutls)/lib"
    
  make -j"$(nproc)"
}

do_check() {
  # ffmpeg links against itself and due to the nature of the Habitat build process, expects those libraries
  # to be present at /hab/pkgs/<pkg_ident>. Since do_check is called before do_install, those libraries are
  # not yet present, causing the tests to fail. We use LD_LIBRARY_PATH here to work around this chicken/egg
  # scenario, to provide the build paths of the libraries _only_ in the context of the do_check.
  local ffmpeg_path="$HAB_CACHE_SRC_PATH/${pkg_dirname}"

  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":"${ffmpeg_path}/libavutil":"${ffmpeg_path}/libavcodec":"${ffmpeg_path}/libswresample"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":"${ffmpeg_path}/libavdevice":"${ffmpeg_path}/libavfilter":"${ffmpeg_path}/libavformat"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":"${ffmpeg_path}/libavresample":"${ffmpeg_path}/libpostproc":"${ffmpeg_path}/libswscale"

  make check

  unset LD_LIBRARY_PATH
}

do_install() {
  make install

  for file in ffmpeg ffprobe; do
    patchelf --set-rpath "$LD_RUN_PATH:${pkg_prefix}/lib" ${pkg_prefix}/bin/$file
    patchelf --shrink-rpath ${pkg_prefix}/bin/$file
  done
}