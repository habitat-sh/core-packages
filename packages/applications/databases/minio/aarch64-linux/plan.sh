pkg_name="minio"
pkg_origin="core"
pkg_version="2023-11-01T01-57-10Z"
pkg_description="Minio is a high performance distributed object storage server, designed for large-scale private cloud infrastructure."
pkg_upstream_url="https://minio.io"
pkg_source="https://dl.minio.io/server/minio/release/linux-arm64/archive/minio.RELEASE.${pkg_version}"
pkg_shasum="8d564d3ca533c49cd360e87c932bd8ded3d10af10eda85df0cc92e3b956415d4"
pkg_license=('Apache-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_bin_dirs=(bin)

do_unpack() {
	return 0
}

do_build() {
	return 0
}

do_install() {
	mkdir -p "${pkg_prefix}/bin"
	cp "../minio.RELEASE.${pkg_version}" "${pkg_prefix}/bin/minio"
	chmod +x "${pkg_prefix}/bin/minio"
}

do_strip() {
	return 0
}
