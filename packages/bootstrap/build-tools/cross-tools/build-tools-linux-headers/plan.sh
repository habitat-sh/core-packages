pkg_name="build-tools-linux-headers"
pkg_origin="core"
pkg_version="4.20.17"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The Linux kernel headers"
pkg_upstream_url="https://kernel.org"
pkg_license=("GPL-2.0-only WITH Linux-syscall-note")
pkg_source="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${pkg_version}.tar.xz"
pkg_shasum="d011245629b980d4c15febf080b54804aaf215167b514a3577feddb2495f8a3e"
pkg_dirname="linux-$pkg_version"

pkg_include_dirs=(include)

do_build() {
	ARCH=`uname -m`
	case $ARCH in 
		x86_x64)
			make headers_install ARCH=x86 INSTALL_HDR_PATH="$pkg_prefix"
			;;
		aarch64)
			make headers_install ARCH=arm64 INSTALL_HDR_PATH="$pkg_prefix"
			;;

	esac
}

do_install() {
	find "$pkg_prefix/include" \
    	\( -name ..install.cmd -o -name .install \) \
    	-print0 \
  	| xargs -0 rm -v
}
