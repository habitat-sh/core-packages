pkg_name="mongodb"
pkg_origin=core
pkg_version="7.0.14"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="High-performance, schema-free, document-oriented database"
pkg_license=('SSPL-1.0' 'MPL-2.0')
pkg_upstream_url="https://www.mongodb.com/"
pkg_source="https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian12-${pkg_version}.tgz"
pkg_shasum="62c4bcf5e2fa7a6154ef9cbd170cc0fa480c29752dab3e3059458170c19e47ef"
pkg_dirname="mongodb-linux-x86_64-debian12-${pkg_version}"

pkg_deps=(
	core/coreutils
	core/gcc-libs
	core/glibc
	core/openssl
	core/python
	core/curl
)
pkg_build_deps=(
	core/patchelf
)

pkg_bin_dirs=(bin)

pkg_svc_run="mongod --config ${pkg_svc_config_path}/mongod.conf"
pkg_exports=(
	[port]=mongod.net.port
)
pkg_exposes=(port)

do_build() {
	return 0
}

do_install() {
	cp -r ${CACHE_PATH}/* ${pkg_prefix}

	patchelf --set-rpath "${LD_RUN_PATH}" --set-interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" "${pkg_prefix}/bin/mongod"
	patchelf --set-rpath "${LD_RUN_PATH}" --set-interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" "${pkg_prefix}/bin/mongos"

	fix_interpreter "${pkg_prefix}/bin/install_compass" core/coreutils bin/env
}

do_strip() {
	return 0
}
