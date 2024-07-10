program="ghc"

pkg_name="ghc-stage1"
pkg_origin=core
pkg_version="8.4.4"
pkg_license=('BSD-2-Clause' 'BSD-3-Clause' 'BSD-Source-Code' 'HaskellReport')
pkg_upstream_url="https://www.haskell.org/ghc/"
pkg_description="The Glasgow Haskell Compiler - Binary Bootstrap"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://downloads.haskell.org/~ghc/${pkg_version}/ghc-${pkg_version}-x86_64-deb9-linux.tar.xz"
pkg_shasum="47c80a32d8f02838a2401414c94ba260d1fe82b7d090479994522242c767cc83"
pkg_dirname="ghc-stage1-${pkg_version}"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(lib/ghc-"${pkg_version}"/include)
pkg_interpreters=(bin/runhaskell bin/runghc)

pkg_deps=(
	core/glibc
  core/gmp
  core/ncurses5
)

pkg_build_deps=(
	core/gcc
	core/make
	core/patchelf
	core/numactl
  #core/libffi
  #core/perl
)

ghc_patch_rpath() {
  RELATIVE_TO=$(dirname "$1")
  RELATIVE_PATHS=$( (for LIB_PATH in "${@:2}"; do echo "\$ORIGIN/$(realpath --relative-to="${RELATIVE_TO}" "${LIB_PATH}")"; done) | paste -sd ':' )
  patchelf --set-rpath "${LD_RUN_PATH}:${RELATIVE_PATHS}" "$1"
}
export -f ghc_patch_rpath

do_prepare() {
	# moving content to pkg_dirname
	mv ${HAB_CACHE_SRC_PATH}/ghc-${pkg_version}/* ${CACHE_PATH}

	LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg_path_for gmp)/lib: \
    $(pkg_path_for ncurses5)/lib: \
    $(pkg_path_for libffi)/lib: \
    $(pkg_path_for numactl)/lib: \
    $(pkg_path_for glibc)/lib"
	export LD_LIBRARY_PATH
}

do_build() {
  build_line "Fixing interpreter for binaries:"

  find . -type f -executable \
    -exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
    -print \
    -exec patchelf --interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" {} \;

  

  ./configure --prefix="${pkg_prefix}" \
    --with-gmp-includes="$(pkg_path_for gmp)/include" \
    --with-gmp-libraries="$(pkg_path_for gmp)/lib"
}

do_install() {
  local GHC_LIB_PATHS

  do_default_install

  pushd "${pkg_prefix}"

  #ln -sf $(pkg_path_for ncurses)/lib/libtinfow.so.6.4 ${pkg_prefix}/lib/libtinfo.so.5
  #patchelf --set-rpath "${pkg_prefix}/lib" ${pkg_prefix}/ghc-8.2.2/bin/ghc-pkg

  GHC_LIB_PATHS=$(find . -name '*.so' -printf '%h\n' | uniq)

  build_line "Fixing rpath for binaries:"

  find . -type f -executable \
    -exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
    -print \
    -exec bash -c 'ghc_patch_rpath $1 $2 ' _ "{}" "$GHC_LIB_PATHS" \;

  popd
}

do_strip() {
  return 0
}