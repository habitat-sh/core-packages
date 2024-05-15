# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="a2eaafed101a505eb2c201cd43a8f5ed0eb8144a"
pkg_shasum="a42199d8fbe4096068d68c89dac9784ef8a0a99d84d83ee65838603101fb9514"

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
	core/patch
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
