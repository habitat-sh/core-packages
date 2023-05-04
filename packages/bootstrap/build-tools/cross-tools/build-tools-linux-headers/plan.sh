pkg_name="build-tools-linux-headers"
pkg_origin="core"
pkg_version="4.20.17"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The Linux kernel headers"
pkg_upstream_url="https://kernel.org"
pkg_license=('GPL-2.0-or-later')
pkg_source="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${pkg_version}.tar.xz"
pkg_shasum="d011245629b980d4c15febf080b54804aaf215167b514a3577feddb2495f8a3e"
pkg_dirname="linux-$pkg_version"

pkg_include_dirs=(include)

do_build() {
  arch=$(uname -m)
  case ${arch} in
    x86_64)
      arch="x86";;
    aarch64)
      arch="arm64"
  esac
  make headers_install ARCH=${arch} INSTALL_HDR_PATH="${pkg_prefix}"
}

do_install() {
  find $pkg_prefix/include -type f ! -name '*.h' -delete
}
