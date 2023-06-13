pkg_name="minio"
pkg_origin="core"
pkg_version="2021-11-03T03-36-36Z"
pkg_description="Minio is a high performance distributed object storage server, designed for large-scale private cloud infrastructure."
pkg_upstream_url="https://minio.io"
pkg_source="https://dl.minio.io/server/minio/release/linux-arm64/archive/minio.RELEASE.${pkg_version}"
pkg_shasum="016f8b5ba0f9843e3f745a7b4b32663407d01e89f5b27aa1979af69bd3844df5"
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
