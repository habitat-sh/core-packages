pkg_name="linux-headers-musl"
pkg_origin="core"
pkg_version="3.12.6-6"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Linux kernel headers (sanitized for use with musl).
"
pkg_upstream_url="https://github.com/sabotage-linux/kernel-headers"
pkg_license=('MIT')
pkg_source="https://github.com/sabotage-linux/kernel-headers/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="e173fc8db34660a368c1692b3cea2b8a3b2affb3c193ae7195aa251bc1497d57"
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
