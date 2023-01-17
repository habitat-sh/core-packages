pkg_name="linux-headers-musl"
pkg_origin="core"
pkg_version="4.19.88-1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Linux kernel headers (sanitized for use with musl).
"
pkg_upstream_url="https://github.com/sabotage-linux/kernel-headers"
pkg_license=('MIT')
pkg_source="https://github.com/sabotage-linux/kernel-headers/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="2806e2d689c6affb45ff8761a1011e6ab8a39369a617421fbff9c29f6dbefec6"
pkg_dirname="kernel-headers-${pkg_version}"

pkg_build_deps=(
	core/gcc
)

pkg_include_dirs=(include)

do_build() {
	make ARCH=aarch64 prefix="${pkg_prefix}"
}

do_install() {
	make ARCH=aarch64 prefix="${pkg_prefix}" install
}
