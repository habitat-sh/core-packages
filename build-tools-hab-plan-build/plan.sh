# shellcheck disable=2034
commit_hash="f2ca2334fb2d3f93b3f50162164ec647beaff4c5"

pkg_name="build-tools-hab-plan-build"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.zip"
pkg_shasum="1399eaf920845f62a0cd149d9c0b306f3bb148b9a5fe0d76e568be6d7f51e4a2"
pkg_dirname="habitat-${commit_hash}"

pkg_bin_dirs=(bin)

pkg_deps=(
    core/build-tools-bash
    core/build-tools-coreutils
    core/build-tools-file
    core/build-tools-findutils
    core/build-tools-gawk
    core/build-tools-grep
    core/build-tools-gzip
    core/build-tools-hab
    core/build-tools-sed
    core/build-tools-tar
    core/build-tools-xz
    core/build-tools-wget
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
}
