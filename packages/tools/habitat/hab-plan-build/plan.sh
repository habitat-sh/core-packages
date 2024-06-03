# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="1516fb74f51df96c68231f4886c96de029e3ceb0"
pkg_shasum="bb85a1804a47168c3f07cdd7f7dcf00708f1ecf040e9826e7c1be9f9bdea0e04"

pkg_name="hab-plan-build"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_dirname="habitat-${commit_hash}"

pkg_bin_dirs=(bin)

pkg_deps=(
	core/bash
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
	core/xcode
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

runtime_sandbox() {
	echo '(version 1)
(allow file* process-exec process-fork
	(literal "/usr/bin/strip"))
'
}

do_build() {
	cp -v "$SRC_PATH"/components/plan-build/bin/${program}-"${pkg_target#*-}".sh "$CACHE_PATH/$program"

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
	install -D "$SRC_PATH"/components/plan-build/bin/darwin-sandbox.sb "$pkg_prefix"/bin/
	install -D "$SRC_PATH"/components/plan-build/bin/hab-plan-build-darwin-internal.bash "$pkg_prefix"/bin/

	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/bash bin/bash
}
