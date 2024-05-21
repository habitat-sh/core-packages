# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="d7fd9155f8a692743ee208a783c1308389340c03"
pkg_shasum="dd181b2306d2720848c8584d09b9799c89e4365fc2d58fe6682e995bc24ceb1a"

pkg_name="hab-studio"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_dirname="habitat-${commit_hash}"

pkg_deps=(
	core/hab-backline
	core/bash
)
pkg_build_deps=(
	core/hab
	core/coreutils
	core/sed
)
pkg_bin_dirs=(bin)

pkg_version() {
	cat "$SRC_PATH/VERSION"
}

do_unpack() {
	do_default_unpack
	update_pkg_version
}

do_prepare() {
	set_runtime_env "HAB_STUDIO_BACKLINE_PKG" "$(<"$(pkg_path_for hab-backline)"/IDENT)"
}

do_build() {
	return 0
}

do_install() {
	# shellcheck disable=2154
	install -v -D "$SRC_PATH"/components/studio/bin/hab-studio-"${pkg_target#*-}".sh "$pkg_prefix"/bin/hab-studio
	install -v -D "$SRC_PATH"/components/studio/libexec/darwin-sandbox.sb "$pkg_prefix"/libexec/darwin-sandbox.sb
	install -v -D "$SRC_PATH"/components/studio/libexec/hab-studio-darwin-profile.sh "$pkg_prefix"/libexec/hab-studio-darwin-profile.sh
	for f in "$SRC_PATH"/components/studio/libexec/hab-studio-type-*.sh; do
		[[ -e $f ]] || break # see http://mywiki.wooledge.org/BashPitfalls#pf1
		install -v -D "$f" "$pkg_prefix"/libexec/"$(basename "$f")"
	done
	sed \
		-e "s,@author@,$pkg_maintainer,g" \
		-e "s,@version@,$pkg_version/$pkg_release,g" \
		-i "$pkg_prefix"/bin/hab-studio

	# Install a copy of a hab under `libexec/`
	install -v -D "$(pkg_path_for hab)"/bin/hab "$pkg_prefix/libexec/hab"

	cp -rv "${SRC_PATH}/components/studio/defaults" "${pkg_prefix}"

	fix_interpreter "${pkg_prefix}/bin/*" core/bash bin/sh
}
