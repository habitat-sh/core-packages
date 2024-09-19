pkg_name=scaffolding-base
pkg_origin=core
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_upstream_url="https://github.com/habitat-sh/core-packages/tree/LTS-2024/packages/tools/misc/scaffolding-base"

do_download() {
	return 0
}

do_verify() {
	return 0
}

do_unpack() {
	return 0
}

do_build() {
	return 0
}

do_install() {
	install -D -m 0644 "$PLAN_CONTEXT/lib/scaffolding.sh" "$pkg_prefix/lib/scaffolding.sh"
}
