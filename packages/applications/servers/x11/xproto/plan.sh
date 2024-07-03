program="xproto"
pkg_name="xproto"
pkg_origin=core
pkg_version=7.0.31
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X11 wire protocol and auxillary headers"
pkg_upstream_url="https://www.x.org/"
pkg_license=('MIT' 'MIT-open-group' 'SMLNJ')
pkg_source="https://www.x.org/releases/individual/proto/${pkg_name}-${pkg_version}.tar.bz2"
pkg_shasum="c6f9747da0bd3a95f86b17fb8dd5e717c8f3ab7f0ece3ba1b247899ec1ef7747"
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
