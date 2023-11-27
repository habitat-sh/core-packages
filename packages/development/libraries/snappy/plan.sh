pkg_origin=core
pkg_name=snappy
pkg_version=1.1.9
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-3-Clause')
repo_source=https://github.com/google/snappy
pkg_build_deps=(
  core/cmake
  core/gcc
  core/git
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_upstream_url=https://github.com/google/snappy
pkg_description="A fast compressor/decompressor http://google.github.io/snappy/"

do_download() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  REPO_PATH="$HAB_CACHE_SRC_PATH/$pkg_dirname"
  git clone "$repo_source" "$REPO_PATH"
  pushd "$REPO_PATH" || exit 1
  git checkout "tags/${pkg_version}"
  git submodule update --init
  popd || exit 1
}

do_build() {
  mkdir -p $REPO_PATH/build

  pushd $REPO_PATH/build || exit 1
  cmake \
    -DCMAKE_SKIP_RPATH=TRUE \
    -DCMAKE_INSTALL_PREFIX="${pkg_prefix}" \
    -DCMAKE_BUILD_TYPE=Release \
    ..
  make
  popd || exit 1
}

do_install() {
  pushd $REPO_PATH/build || exit 1
  make install
  popd || exit 1
}
