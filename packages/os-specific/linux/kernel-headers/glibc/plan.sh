pkg_name="linux-headers"
pkg_origin="core"
pkg_version="6.4.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The Linux kernel headers"
pkg_upstream_url="https://kernel.org"
pkg_license=('GPL-2.0-only')
pkg_source="https://www.kernel.org/pub/linux/kernel/v5.x/linux-${pkg_version}.tar.xz"
pkg_shasum="cca91be956fe081f8f6da72034cded96fe35a50be4bfb7e103e354aa2159a674"
pkg_dirname="linux-$pkg_version"

pkg_include_dirs=(include)
pkg_build_deps=(
	core/build-tools-gcc
)

do_build() {
	local arch
	arch="$(uname -m)"
	case ${arch} in
	x86_64)
		arch="x86"
		;;
	aarch64)
		arch="arm64"
		;;
	esac
	make headers
}

do_install() {
	find usr/include -type f ! -name '*.h' -delete
	cp -rv usr/include "$pkg_prefix"
}
