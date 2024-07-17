pkg_name=linux-headers-musl
pkg_origin=core
pkg_version=4.19.88-2
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Linux kernel headers (sanitized for use with musl)."
pkg_upstream_url="https://github.com/sabotage-linux/kernel-headers"
pkg_license=('MIT')
pkg_source="https://github.com/sabotage-linux/kernel-headers/archive/v${pkg_version}.tar.gz"
pkg_shasum="16161844e56944d39794ad74c2dfd6faad12bda79b5dc00595f4178d28a92e2d"
pkg_dirname="kernel-headers-${pkg_version}"
pkg_deps=()
pkg_build_deps=(
  core/coreutils
  core/diffutils
  core/gcc
  core/make
  core/patch
)
pkg_include_dirs=(include)

do_build() {
	make ARCH=x86_64 prefix="${pkg_prefix}"
}

do_install() {
	make ARCH=x86_64 prefix="${pkg_prefix}" install
}
