program="recordproto"
pkg_name="recordproto"
pkg_origin=core
pkg_version=1.14.2
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X.Org Protocol Headers: recordproto"
pkg_upstream_url="https://www.x.org/"
pkg_license=('')
pkg_source="https://www.x.org/releases/individual/proto/${pkg_name}-${pkg_version}.tar.bz2"
pkg_shasum="a777548d2e92aa259f1528de3c4a36d15e07a4650d0976573a8e2ff5437e7370"
pkg_build_deps=(
  core/gcc
  core/make
  core/pkg-config
  core/util-macros
)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)
do_prepare() {
  #old config.guess doesn't guess system type. New config file is downloaded from the link given in the build log
  # http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD 
  ARCH=`uname -m`
  if [ $ARCH = "aarch64" ]; then
    cp "$PLAN_CONTEXT/config.guess" "$CACHE_PATH"/
  fi
}
