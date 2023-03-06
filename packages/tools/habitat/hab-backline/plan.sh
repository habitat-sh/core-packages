# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="d27edcf40c8061388151965b2372b15a2517c286"
pkg_shasum="d01fb40e39d5a9a5ab62a53d7186b4c4134f02c0d33ea8316e8f691da3eba7d3"

pkg_name="hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_dirname="habitat-${commit_hash}"

pkg_build_deps=()

pkg_deps=(
	core/hab-plan-build
	core/diffutils
	core/less
	core/make
	core/mg
	core/ncurses
	core/patch
	core/util-linux
	core/vim
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
