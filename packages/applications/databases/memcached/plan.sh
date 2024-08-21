pkg_name=memcached
pkg_origin=core
pkg_version="1.6.29"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Distributed memory object caching system"
pkg_upstream_url=https://memcached.org/
pkg_license=('BSD-3-Clause')
pkg_source="http://www.memcached.org/files/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum=269643d518b7ba2033c7a1f66fdfc560d72725a2822194d90c8235408c443a49
pkg_deps=(
	core/glibc
	core/cyrus-sasl
	core/libevent
)
pkg_build_deps=(
	core/git
	core/gcc
	core/make
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)

pkg_svc_run="memcached"
pkg_exports=(
	[port]=port
)
pkg_exposes=(port)

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--enable-sasl
	make
}

do_check() {
	make test
}
