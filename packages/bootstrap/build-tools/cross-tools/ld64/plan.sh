program="ld64"
pkg_name="build-tools-ld64"
pkg_origin="core"
pkg_version="xcode"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('APSL-2.0')

pkg_deps=(core/hab-ld-wrapper)
pkg_bin_dirs=(bin)

do_build() {
    return 0
}

do_install() {
    local binary
    local env_prefix
    local wrapper_binary
    local hab_ld_wrapper

    binary="ld"
    env_prefix="BUILD_TOOLS_LD64"
    wrapper_binary="$pkg_prefix/bin/$binary"
    hab_ld_wrapper="$(pkg_path_for hab-ld-wrapper)"

    build_line "Adding wrapper for $binary"
    sed -e "s^@env_prefix@^${env_prefix}^g" \
        -e "s^@wrapper@^${hab_ld_wrapper}/bin/hab-ld-wrapper^g" \
        "$PLAN_CONTEXT/ld-wrapper.sh" \
        >"$wrapper_binary"

    chmod 755 "$wrapper_binary"
}
