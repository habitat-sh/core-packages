# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
_version="1.6.1108"
pkg_shasum="5145d59c2ec86290c8c5329171ece2b1289e795a3524c3db97b533679dc668b9"

pkg_name="hab-backline"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/refs/tags/${_version}.tar.gz"
pkg_dirname="habitat-${_version}"

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
