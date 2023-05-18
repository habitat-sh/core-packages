pkg_name="linux-headers"
pkg_origin="core"
pkg_version="5.19.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The Linux kernel headers"
pkg_upstream_url="https://kernel.org"
pkg_license=('GPL-2.0-only')
pkg_source="https://www.kernel.org/pub/linux/kernel/v5.x/linux-${pkg_version}.tar.xz"
pkg_shasum="616308795a952a6a39b4c74807c33916850eb7166d8ed7c9a87a1ba55d7487ce"
pkg_dirname="linux-$pkg_version"

pkg_include_dirs=(include)
pkg_build_deps=(
	core/build-tools-gcc
)

do_build() {
	make headers
}

do_install() {
	find usr/include -type f ! -name '*.h' -delete
	cp -rv usr/include "$pkg_prefix"
}
