program="renderproto"
pkg_name="renderproto"
pkg_origin=core
pkg_version=0.11.1
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X11 Render extension wire protocol"
pkg_upstream_url="https://www.x.org/"
pkg_license=('HPND-sell-variant')
pkg_source="https://www.x.org/releases/individual/proto/${pkg_name}-${pkg_version}.tar.bz2"
pkg_shasum="06735a5b92b20759204e4751ecd6064a2ad8a6246bb65b3078b862a00def2537"
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