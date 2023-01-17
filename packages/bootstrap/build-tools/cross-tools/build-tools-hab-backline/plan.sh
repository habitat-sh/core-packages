commit_hash="707b086fec72a59aa439fedbc9bf032597d59afc"

pkg_name="build-tools-hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_shasum="5a8766662c0ea0d3932451c520dd31eadf7deda0b6652020ff61ba3f8c3f3773"
pkg_dirname="habitat-${commit_hash}"

pkg_build_deps=()

pkg_deps=(
	core/build-tools-hab-plan-build
	core/build-tools-diffutils
	core/build-tools-make
	core/build-tools-ncurses
	core/build-tools-patch
)

pkg_version() {
	cat "$SRC_PATH/VERSION"
}

do_unpack() {
	do_default_unpack
	update_pkg_version
}

do_build() {
	return 0
}

do_install() {
	return 0
}
