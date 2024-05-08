program="xcb-proto"
pkg_name="xcb-proto"
pkg_origin=core
pkg_version=1.14
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="X11 client library"
pkg_upstream_url="https://www.x.org/"
pkg_license=('X11-distribute-modifications-variant')
pkg_source="https://www.x.org/releases/individual/xcb/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="186a3ceb26f9b4a015f5a44dcc814c93033a5fc39684f36f1ecc79834416a605"
pkg_build_deps=(
  core/gcc
  core/libxml2
  core/make
  core/python2-stage1
)
pkg_pconfig_dirs=(lib/pkgconfig)

do_setup_environment() {
  push_runtime_env PYTHONPATH "${pkg_prefix}/lib/python2.7/site-packages"
}
