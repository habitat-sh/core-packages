program=nspr
pkg_name=nspr
pkg_origin=core
pkg_version=4.35
pkg_license=("MPL-2.0")
pkg_description="Netscape Portable Runtime"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url=https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSPR
pkg_source=https://ftp.mozilla.org/pub/nspr/releases/v${pkg_version}/src/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=7ea3297ea5969b5d25a5dd8d47f2443cda88e9ee746301f6e1e1426f8a6abc8f
pkg_deps=(core/glibc)
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include/nspr)
pkg_lib_dirs=(lib)

do_build() {
  ./nspr/configure --prefix="${pkg_prefix}" \
                   --enable-optimize \
                   --disable-debug \
                   --enable-64bit
  make
}

