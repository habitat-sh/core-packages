pkg_name="redis"
pkg_origin="core"
pkg_version="7.0.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Persistent key-value database, with built-in net interface.
"
pkg_upstream_url="http://redis.io/"
pkg_license=("BSD-3-Clause")
pkg_source="http://download.redis.io/releases/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="06a339e491306783dcf55b97f15a5dbcbdc01ccbde6dc23027c475cab735e914"
pkg_dirname="${pkg_name}-${pkg_version}"

pkg_build_deps=(
	core/coreutils
	core/make
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
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

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

pkg_svc_run="redis-server ${pkg_svc_config_path}/redis.config"
pkg_exports=(
	[port]=port
)
pkg_exposes=(port)
