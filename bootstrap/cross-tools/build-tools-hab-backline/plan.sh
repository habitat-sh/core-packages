commit_hash="7019864f710013f1806ba2aea0febb0c3b50fb44"

pkg_name="build-tools-hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_shasum="5b09edc7054f2d0e5e1382882b3f8d8af31159f9c71719d167165088aaf0dabf"
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
