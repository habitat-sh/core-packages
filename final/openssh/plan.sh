pkg_name="openssh"
pkg_origin="core"
pkg_version="9.1p1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Provides OpenSSH client and server."
pkg_upstream_url="https://www.openssh.com/"
pkg_license=('bsd')
pkg_source="http://mirror.wdc1.us.leaseweb.net/openbsd/OpenSSH/portable/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="19f85009c7e3e23787f0236fbb1578392ab4d4bf9f8ec5fe6bc1cd7e8bfdd288"

pkg_deps=(
	core/glibc
	core/openssl
	core/zlib
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/make
)

pkg_bin_dirs=(bin sbin libexec)

pkg_svc_user="root"
pkg_svc_group="root"

do_build() {
	./configure --prefix="${pkg_prefix}" \
		--sysconfdir="${pkg_svc_path}/config" \
		--localstatedir="${pkg_svc_path}/var" \
		--datadir="${pkg_svc_data_path}" \
		--with-privsep-user=hab \
		--with-privsep-path="${pkg_prefix}/var/empty"
	make
}

do_install() {
	make install-nosysconf
}
