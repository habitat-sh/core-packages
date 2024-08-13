pkg_name=avisynthplus
pkg_origin=core
pkg_version="3.7.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="AviSynth is a powerful tool for video post-production"
pkg_license="GNU General Public License GPLv2"
pkg_upstream_url="https://github.com/AviSynth/AviSynthPlus.git"

pkg_build_deps=(
  core/git
  core/gcc
  core/cmake
)

pkg_include_dirs=(include)

do_download() {
    repo_path="${HAB_CACHED_SRC_PATH}/${pkg_dirname}"
    rm -Rf "${repo_path}"
    git clone "${pkg_upstream_url}" "${repo_path}"
	( cd "${HAB_CACHED_SRC_PATH}/${pkg_dirname}" || exit
    git checkout tags/"v$pkg_version"
  )
}

do_build() {
 return 0
}

do_check() {
  return 0
}

do_install() {
  cd "${HAB_CACHED_SRC_PATH}/${pkg_dirname}"

  mkdir avisynth-build && cd avisynth-build
  cmake ../ -DHEADERS_ONLY:bool=on -DCMAKE_INSTALL_PREFIX=${pkg_prefix}
  make VersionGen install
}