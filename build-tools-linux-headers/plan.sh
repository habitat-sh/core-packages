pkg_name="build-tools-linux-headers"
pkg_origin="core"
pkg_version="5.19.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The Linux kernel headers"
pkg_upstream_url="https://kernel.org"
pkg_license=('GPL-2.0-or-later')
pkg_source="https://www.kernel.org/pub/linux/kernel/v5.x/linux-${pkg_version}.tar.xz"
pkg_shasum="48e40a1f5501ec6c40e3c86d3d5319200b688f2d9360f72833084d74801fe63d"
pkg_dirname="linux-$pkg_version"

pkg_include_dirs=(include)

do_build() {
    make headers
}

do_install() {
    find usr/include -name '.*' -delete
    rm usr/include/Makefile
    cp -rv usr/include "$pkg_prefix"
}
