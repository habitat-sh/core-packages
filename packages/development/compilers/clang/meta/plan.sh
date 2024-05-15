program="clang"
pkg_name="clang"
pkg_origin="core"
pkg_version="14.0.6"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('Apache-2.0 WITH LLVM-exception')
pkg_deps=(
    core/hab-cc-wrapper
    core/ld64
)
pkg_bin_dirs=(bin)

do_prepare() {
    set_runtime_env "CC" "${pkg_prefix}/bin/clang"
    set_runtime_env "CXX" "${pkg_prefix}/bin/clang++"
    return 0
}

do_build() {
    return 0
}

do_install() {
    wrap_binary "clang-14"
    wrap_binary "clang"
    wrap_binary "clang++"
    ln -s clang "$pkg_prefix"/bin/cc
    ln -s clang++ "$pkg_prefix"/bin/c++
}

wrap_binary() {
    local binary
    local env_prefix
    local hab_cc_wrapper
    local ld64
    local system_dirs

    binary="$1"
    env_prefix="CLANG"
    hab_cc_wrapper="$(pkg_path_for hab-cc-wrapper)"
    ld64="$(pkg_path_for ld64)"
    system_dirs="/System/Library/Frameworks/:/Library/Frameworks/:/Applications/Xcode.app/"
    

    local wrapper_binary="$pkg_prefix/bin/$binary"
    local actual_binary="/usr/bin/$binary"

    build_line "Adding wrapper for $binary"

    sed -e "s^@env_prefix@^${env_prefix}^g" \
        -e "s^@allowed_impure_paths@^${system_dirs}^g" \
        -e "s^@executable_name@^${binary}^g" \
        -e "s^@wrapper@^${hab_cc_wrapper}/bin/hab-cc-wrapper^g" \
        -e "s^@program@^${actual_binary}^g" \
        -e "s^@ld_bin@^${ld64}/bin^g" \
        "$PLAN_CONTEXT/cc-wrapper.sh" \
        >"$wrapper_binary"

    chmod 755 "$wrapper_binary"
}
