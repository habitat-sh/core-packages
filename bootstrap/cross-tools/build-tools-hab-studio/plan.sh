# shellcheck disable=2034
commit_hash="7019864f710013f1806ba2aea0febb0c3b50fb44"

pkg_name="build-tools-hab-studio"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_shasum="5b09edc7054f2d0e5e1382882b3f8d8af31159f9c71719d167165088aaf0dabf"
pkg_dirname="habitat-${commit_hash}"

pkg_deps=(
    core/build-tools-hab-backline
    core/build-tools-bash
)
pkg_build_deps=(
    core/native-busybox-static
    core/build-tools-hab
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
    set_runtime_env "HAB_STUDIO_BACKLINE_PKG" "$(<"$(pkg_path_for build-tools-hab-backline)"/IDENT)"
}

do_build() {
    return 0
}

do_install() {
    # shellcheck disable=2154
    install -v -D "$SRC_PATH"/components/studio/bin/hab-studio.sh "$pkg_prefix"/bin/hab-studio
    install -v -D "$SRC_PATH"/components/studio/libexec/hab-studio-profile.sh "$pkg_prefix"/libexec/hab-studio-profile.sh
    for f in "$SRC_PATH"/components/studio/libexec/hab-studio-type-*.sh; do
        [[ -e $f ]] || break # see http://mywiki.wooledge.org/BashPitfalls#pf1
        install -v -D "$f" "$pkg_prefix"/libexec/"$(basename "$f")"
    done
    sed \
        -e "s,@author@,$pkg_maintainer,g" \
        -e "s,@version@,$pkg_version/$pkg_release,g" \
        -i "$pkg_prefix"/bin/hab-studio

    # Install a copy of a statically built busybox under `libexec/`
    install -v -D "$(pkg_path_for native-busybox-static)"/bin/busybox "$pkg_prefix/libexec/busybox"

    # Install a copy of a hab under `libexec/`
    install -v -D "$(pkg_path_for build-tools-hab)"/bin/hab "$pkg_prefix/libexec/hab"

    cp -rv "${SRC_PATH}/components/studio/defaults" "${pkg_prefix}"

    # Fix scripts
    fix_interpreter "${pkg_prefix}/bin/*" core/build-tools-bash bin/sh
}
