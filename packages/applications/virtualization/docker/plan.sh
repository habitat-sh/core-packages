pkg_name="docker"
pkg_description="The Docker Engine"
pkg_origin="core"
pkg_version="19.03.15"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://download.docker.com/linux/static/stable/${pkg_target%%-*}/${pkg_name}-${pkg_version}.tgz"
pkg_upstream_url="https://docs.docker.com/engine/installation/binaries/"
pkg_shasum="264f3396630507606a8646fda6a28a98d3ced8927df84be8ee9a74ab73cc1566"
pkg_dirname="docker"
pkg_bin_dirs=(bin)

do_build() {
	return 0
}

do_install() {
	for bin in *; do
		install -v -D "${bin}" "${pkg_prefix}/bin/${bin}"
	done
}

# Skip stripping down the Go binaries
do_strip() {
	return 0
}
