# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="94d6d50138d1fe005e59f4a7117974ce1b977ae2"
pkg_shasum="ba63a6638fb181c6a7f24d8efb5f5750a648d85fa9456a4a3a9be71471f098f1"

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
