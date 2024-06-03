commit_hash="1516fb74f51df96c68231f4886c96de029e3ceb0"

pkg_name="build-tools-hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_shasum="bb85a1804a47168c3f07cdd7f7dcf00708f1ecf040e9826e7c1be9f9bdea0e04"
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
