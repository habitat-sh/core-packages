pkg_name="minio"
pkg_origin="core"
pkg_version="2023-01-02T09-40-09Z"
pkg_description="Minio is a high performance distributed object storage server, designed for large-scale private cloud infrastructure."
pkg_upstream_url="https://minio.io"
pkg_source="https://dl.minio.io/server/minio/release/linux-arm64/archive/minio.RELEASE.${pkg_version}"
pkg_shasum="0ca0015e8ed4392190c04e21391e9fdcbdbdc5b85622608f120c8e31aa7bdfa5"
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
