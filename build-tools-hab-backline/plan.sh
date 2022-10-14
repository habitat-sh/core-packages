commit_hash="f2ca2334fb2d3f93b3f50162164ec647beaff4c5"

pkg_name="build-tools-hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.zip"
pkg_shasum="1399eaf920845f62a0cd149d9c0b306f3bb148b9a5fe0d76e568be6d7f51e4a2"
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
