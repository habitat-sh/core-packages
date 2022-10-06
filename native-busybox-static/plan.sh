pkg_name="native-busybox-static"
pkg_origin="core"
pkg_version="1.35.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_source="https://busybox.net/downloads/busybox-1.35.0.tar.bz2"
pkg_shasum="faeeb244c35a348a334f4a59e44626ee870fb07b6884d68c10ae8bc19f83a694"
pkg_dirname="busybox-1.35.0"
pkg_bin_dirs=(bin)

do_prepare() {
    export LDFLAGS="--static";
}

do_build() {
    make defconfig
    make
}

do_install() {
    install -Dm755 busybox "$pkg_prefix/bin/busybox"
    # Check that busybox executable is not failing
    "$pkg_prefix"/bin/busybox >/dev/null

    # Generate the symlinks back to the `busybox` executable
    for l in $(busybox --list); do
        ln -sv busybox "$pkg_prefix/bin/$l"
    done
}