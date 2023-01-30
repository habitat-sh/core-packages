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
	core/grep
	core/make
	core/pkg-config
	core/util-linux
	core/sed
)

pkg_bin_dirs=(bin sbin libexec)

pkg_svc_user="root"
pkg_svc_group="root"

do_build() {
	# Create folders required at runtime to suppress configuration warnings
	mkdir -p "${pkg_svc_path}"/var/empty
	mkdir -p "${pkg_svc_path}"/run

	./configure --prefix="${pkg_prefix}" \
		--sysconfdir="${pkg_svc_path}/config" \
		--localstatedir="${pkg_svc_path}/var" \
		--with-pid-dir="${pkg_svc_path}/run" \
		--datadir="${pkg_svc_data_path}" \
		--with-privsep-user=hab \
		--with-privsep-path="${pkg_svc_path}/var/empty"
	make
}

do_check() {
	# Create symlinks to binaries used by tests
	ln -s "$(pwd)"/scp /bin/scp
	for prog in "$(pkg_path_for coreutils)"/bin/*; do
		ln -s "$prog" /bin/"$(basename "$prog")"
	done
	for prog in "$(pkg_path_for grep)"/bin/*; do
		ln -s "$prog" /bin/"$(basename "$prog")"
	done
	make -j1 tests
}

do_install() {
	make install-nosysconf
}