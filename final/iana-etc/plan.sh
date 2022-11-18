pkg_name="iana-etc"
pkg_origin="core"
pkg_version="20220922"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The iana-etc package provides the Unix/Linux /etc/services and /etc/protocols \
files.\
"
pkg_upstream_url="http://sethwklein.net/iana-etc"
pkg_license=('GPL-3.0-or-later')
pkg_source="https://github.com/Mic92/${pkg_name}/releases/download/${pkg_version}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="fde3d069b904e5b13435deff6ad55252e35c321c59f6ada771fed9178d2da435"
pkg_deps=()
pkg_build_deps=(
	core/build-tools-coreutils
)

do_prepare() {
	set_runtime_env "HAB_ETC_SERVICES" "${pkg_prefix}/etc/services"
	set_runtime_env "HAB_ETC_PROTOCOLS" "${pkg_prefix}/etc/protocols"
}

do_build() {
	return 0
}

do_install() {
	mkdir -v "${pkg_prefix}"/etc
	cp services protocols "${pkg_prefix}"/etc
}
