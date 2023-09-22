pkg_name="redis"
pkg_origin="core"
pkg_version="4.0.14"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Persistent key-value database, with built-in net interface.
"
pkg_upstream_url="http://redis.io/"
pkg_license=("BSD-3-Clause")
pkg_source="http://download.redis.io/releases/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="1e1e18420a86cfb285933123b04a82e1ebda20bfb0a289472745a087587e93a7"
pkg_dirname="${pkg_name}-${pkg_version}"

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
