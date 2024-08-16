# shellcheck disable=2154
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="hab-cc-wrapper"
pkg_origin="core"
pkg_version="1.0.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/hab-pkg-wrappers/archive/v${pkg_version}.tar.gz"
pkg_shasum="4fc7d658f0241bebda8393e48e4ea8a2bbce8c60ca3286cc26d6fec8e782c1c6"
pkg_dirname="hab-pkg-wrappers-${pkg_version}"
pkg_build_deps=(
	core/native-rust
)

# We don't specify 'pkg_bin_dirs' as we always use the wrapper via it's full path
bin="hab-cc-wrapper"

do_prepare() {
	build_type="--release"
	build_line "Building artifacts with \`${build_type#--}' mode"
	export CARGO_HOME="$HAB_CACHE_SRC_PATH/$pkg_dirname/.cargo"
	build_line "Setting CARGO_HOME=$CARGO_HOME"
	export CARGO_TARGET_DIR="$HAB_CACHE_SRC_PATH/$pkg_dirname/target"
	build_line "Setting CARGO_TARGET_DIR=$CARGO_TARGET_DIR"

	export rustc_target="${TARGET_ARCH:-${pkg_target%%-*}}-unknown-linux-gnu"
	build_line "Setting rustc_target=$rustc_target"

	# Create a static binary
	export RUSTFLAGS='-C target-feature=+crt-static'
	build_line "Setting RUSTFLAGS=$RUSTFLAGS"
}

do_build() {
	pushd "$SRC_PATH" >/dev/null || exit
	cargo build "${build_type#--debug}" --locked --target="$rustc_target" --verbose --bin $bin
	popd >/dev/null || exit
}

do_install() {
	install -v -D "$CARGO_TARGET_DIR"/"$rustc_target"/"${build_type#--}"/$bin "$pkg_prefix"/bin/$bin
}

do_strip() {
	# No need to strip as we generate stripped binaries
	return 0
}
