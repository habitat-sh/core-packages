program="iana-etc"
pkg_name="build-tools-iana-etc"
pkg_origin="core"
pkg_version="20220922"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The iana-etc package provides the Unix/Linux /etc/services and /etc/protocols files."
pkg_upstream_url="https://github.com/Mic92/iana-etc"
pkg_license=('MIT License')
pkg_source="https://github.com/Mic92/iana-etc/releases/download/${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="fde3d069b904e5b13435deff6ad55252e35c321c59f6ada771fed9178d2da435"
pkg_dirname="${program}-${pkg_version}"

do_build() {
	return 0
}

do_install() {
	#pushd ${HAB_CACHE_SRC_PATH}/${pkg_dirname} || exit 1
	pushd ${CACHE_PATH} || exit 1
	cp services protocols ${pkg_prefix}
	popd >/dev/null || exit 1
}
