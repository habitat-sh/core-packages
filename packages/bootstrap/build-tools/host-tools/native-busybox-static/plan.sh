pkg_name="native-busybox-static"
pkg_origin="core"
pkg_version="1.36.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0-only' 'bzip2-1.0.6')
pkg_source="https://busybox.net/downloads/busybox-${pkg_version}.tar.bz2"
pkg_shasum="b8cc24c9574d809e7279c3be349795c5d5ceb6fdf19ca709f80cde50e47de314"
pkg_dirname="busybox-${pkg_version}"
pkg_bin_dirs=(bin)
pkg_interpreters=(
	bin/ash
	bin/awk
	bin/env
	bin/sh
	bin/bash
)

do_prepare() {
	export LDFLAGS="--static"
	build_line "Setting LDFLAGS=${LDFLAGS}"
}

do_build() {
	make defconfig
	make -j"$(nproc)"
}

do_install() {
	install -Dm755 busybox "$pkg_prefix/bin/busybox"
	# Check that busybox executable is not failing
	"$pkg_prefix"/bin/busybox >/dev/null

	# Generate the symlinks back to the `busybox` executable
	for l in $(busybox --list); do
		ln -sv busybox "$pkg_prefix/bin/$l"
	done

	# copy license files in package
	install -Dm644 ${CACHE_PATH}/LICENSE ${pkg_prefix}
	#install -Dm644 ${CACHE_PATH}/archival/libarchive/bz/LICENSE ${pkg_prefix}
}