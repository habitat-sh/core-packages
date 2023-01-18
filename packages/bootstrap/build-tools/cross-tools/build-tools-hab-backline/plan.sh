commit_hash="21914065e338e2ce9fb4880b92326abfa79737aa"

pkg_name="build-tools-hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_shasum="12674359e72fc8a87b5a51dd24119b00abffa1566a9a151637ffe3d9351808ee"
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
