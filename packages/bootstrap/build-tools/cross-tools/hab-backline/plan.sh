commit_hash="d7fd9155f8a692743ee208a783c1308389340c03"

pkg_name="build-tools-hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_shasum="dd181b2306d2720848c8584d09b9799c89e4365fc2d58fe6682e995bc24ceb1a"
pkg_dirname="habitat-${commit_hash}"

pkg_build_deps=()

pkg_deps=(
	core/build-tools-hab-plan-build
	core/build-tools-diffutils
	core/build-tools-make
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
