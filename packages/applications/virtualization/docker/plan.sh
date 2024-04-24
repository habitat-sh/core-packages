pkg_name="docker"
pkg_description="The Docker Engine"
pkg_origin="core"
pkg_version="26.0.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://download.docker.com/linux/static/stable/${pkg_target%%-*}/${pkg_name}-${pkg_version}.tgz"
pkg_upstream_url="https://docs.docker.com/engine/installation/binaries/"
pkg_shasum="f01642695115d8ceca64772ea65336ef7210ddc36096f1e533145f443bc718b3"
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
