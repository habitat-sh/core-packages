# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
_version="1.6.1108"
pkg_shasum="5145d59c2ec86290c8c5329171ece2b1289e795a3524c3db97b533679dc668b9"

pkg_name="hab-plan-build"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/refs/tags/${_version}.tar.gz"
pkg_dirname="habitat-${_version}"

pkg_bin_dirs=(bin)

pkg_deps=(
	core/bash
	core/binutils
	core/cacerts
	core/coreutils
	core/file
	core/findutils
	core/gawk
	core/grep
	core/gzip
	core/hab
	core/toml-cli
	core/sed
	core/tar
	core/unzip
	core/wget
	core/xz
)
pkg_build_deps=(
	core/bats
)

program="hab-plan-build"

pkg_version() {
	cat "$SRC_PATH/VERSION"
}

do_unpack() {
	do_default_unpack
	update_pkg_version
}

do_build() {
	cp -v "$SRC_PATH"/components/plan-build/bin/${program}.sh "$CACHE_PATH/$program"

	# Use the bash from our dependency list as the shebang. Also, embed the
	# release version of the program.
	# shellcheck disable=2154
	sed \
		-e "s,^HAB_PLAN_BUILD=0\.0\.1\$,HAB_PLAN_BUILD=$pkg_version/$pkg_release," \
		-e "s,^pkg_target='@@pkg_target@@'\$,pkg_target='$pkg_target'," \
		-i "$CACHE_PATH/$program"
}

do_check() {
	bats test
}

do_install() {
	# shellcheck disable=2154
	install -D "$CACHE_PATH/$program" "$pkg_prefix"/bin/$program
	install -D "$SRC_PATH"/components/plan-build/bin/shared.bash "$pkg_prefix"/bin/
	install -D "$SRC_PATH"/components/plan-build/bin/public.bash "$pkg_prefix"/bin/
	install -D "$SRC_PATH"/components/plan-build/bin/environment.bash "$pkg_prefix"/bin/

	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/bash bin/bash
}
