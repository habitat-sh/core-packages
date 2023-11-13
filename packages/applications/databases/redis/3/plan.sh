program="redis"
pkg_name=redis3
pkg_origin=core
pkg_version="3.2.13"
pkg_description="Persistent key-value database, with built-in net interface"
pkg_upstream_url="http://redis.io"
pkg_license=("BSD-3-Clause")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://download.redis.io/releases/${program}-${pkg_version}.tar.gz"
pkg_shasum="862979c9853fdb1d275d9eb9077f34621596fec1843e3e7f2e2f09ce09a387ba"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/coreutils
	core/gcc
	core/which
	core/pkg-config
	core/tcl
	core/python
	core/procps-ng
)
pkg_deps=(
	core/glibc
)
pkg_bin_dirs=(bin)
pkg_svc_run="redis-server ${pkg_svc_config_path}/redis.config"
pkg_exports=(
	[port]=port
)
pkg_exposes=(port)

do_build() {
	make distclean
	make MALLOC=libc
}

do_check() {
	for prog in "$(pkg_path_for coreutils)"/bin/*; do
		ln -s "$prog" /usr/bin/"$(basename "$prog")"
	done

	make test
}
