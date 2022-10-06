app_name="build-tools"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools"
pkg_origin="core"
pkg_version="0.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="This package is a meta package that pull all the\
dependencies required to create a minimal build environment"

pkg_deps=(
    core/build-tools-m4
    core/build-tools-ncurses
    core/build-tools-bash
    core/build-tools-coreutils
    core/build-tools-diffutils
    core/build-tools-file
    core/build-tools-findutils
    core/build-tools-gawk
    core/build-tools-grep
    core/build-tools-gzip
    core/build-tools-make
    core/build-tools-patch
    core/build-tools-sed
    core/build-tools-tar
    core/build-tools-xz
    core/build-tools-wget
    core/build-tools-gcc
)

do_build() {
    return 0
}

do_install() {
    return 0
}