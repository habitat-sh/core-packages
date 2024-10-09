pkg_name=ghc-stage1
pkg_origin=core
pkg_version=9.6.3
pkg_license=('BSD-3-Clause')
pkg_upstream_url="https://www.haskell.org/ghc/"
pkg_description="The Glasgow Haskell Compiler - Binary Bootstrap"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://downloads.haskell.org/~ghc/${pkg_version}/ghc-${pkg_version}-x86_64-deb11-linux.tar.xz"
pkg_shasum="c4c0124857265926f1cf22a09d950d7ba989ff94053a4ddf3dcdab5359f4cab7"
pkg_dirname="ghc-${pkg_version}"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/runhaskell bin/runghc)

pkg_deps=(
  core/glibc
  core/gmp
  core/libffi
  core/ncurses
)

pkg_build_deps=(
  core/gcc-base
  core/make
  core/build-tools-patchelf
)

do_unpack() {
  do_default_unpack

  mv ghc-${pkg_version}-x86_64-unknown-linux ${pkg_dirname}
}

do_build() {
   export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":"$(pkg_path_for gmp)/lib"
  ./configure \
    --prefix="${pkg_prefix}" \
    CC="$(pkg_path_for gcc-base)/bin/gcc" \
    CXX="$(pkg_path_for gcc-base)/bin/g++" \
    --disable-ld-override
}

do_install() {
  make lib/settings
  cp -r bin include lib wrappers "${pkg_prefix}"

  # The ghc binary (ghc-${pkg_version}) requires libtinfo.so.6, which is not available
  # in the current ncurses build because it was built with the --enable-widec option.
  ln -sfv "$(pkg_path_for ncurses)/lib/libtinfow.so" "${pkg_prefix}/lib/x86_64-linux-ghc-${pkg_version}/libtinfo.so.6"

  # export LD_RUN_PATH="${LD_RUN_PATH}:${pkg_prefix}/lib"
  export LD_RUN_PATH="${LD_RUN_PATH}:${pkg_prefix}/lib/x86_64-linux-ghc-${pkg_version}"

  build_line "Setting rpath for all binaries to '${LD_RUN_PATH}'"
  find "${pkg_prefix}/bin" "${pkg_prefix}/lib/bin" -type f -executable \
    -exec patchelf --set-interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" \
    --set-rpath "${LD_RUN_PATH}" {} \;

  build_line "Setting rpath for all libraries to '${LD_RUN_PATH}'"
  find "${pkg_prefix}/lib" -type f -name "*.so" \
    -exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;

    patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/lib/x86_64-linux-ghc-${pkg_version}/libffi.so.8.1.2
    patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/lib/x86_64-linux-ghc-${pkg_version}/libffi.so.8
}

 do_strip() {
   return 0
 }
