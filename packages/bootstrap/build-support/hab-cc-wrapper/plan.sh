# shellcheck disable=2154
commit_hash="994473fe845744d3113b58d34d86722af1b008a8"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="hab-cc-wrapper"
pkg_origin="core"
pkg_version="1.0.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/hab-pkg-wrappers/archive/${commit_hash}.tar.gz"
pkg_shasum="46f1766b06a79a6a3a2b5e6f6f91b4bf5985d8bf070c90c3a4e133add0e3cde6"
pkg_dirname="hab-pkg-wrappers-${commit_hash}"
pkg_build_deps=(
	core/native-rust
)

# We don't specify 'pkg_bin_dirs' as we always use the wrapper via it's full path
bin="hab-cc-wrapper"

do_prepare() {
	build_type="--release"
	export CARGO_HOME="$HAB_CACHE_SRC_PATH/$pkg_dirname/.cargo"
	export CARGO_TARGET_DIR="$HAB_CACHE_SRC_PATH/$pkg_dirname/target"
	export rustc_target="${TARGET_ARCH:-${pkg_target%%-*}}-apple-darwin"

    build_line "Building artifacts with \`${build_type#--}' mode"
	build_line "Setting CARGO_HOME=$CARGO_HOME"
	build_line "Setting CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
	build_line "Setting rustc_target=$rustc_target"
}

do_build() {
	pushd "$SRC_PATH" >/dev/null || exit
	cargo build "${build_type}" --target="$rustc_target" --locked --verbose --bin $bin
	popd >/dev/null || exit
}

do_install() {
	install -d "$pkg_prefix"/bin
	install -v "$CARGO_TARGET_DIR"/"$rustc_target"/"${build_type#--}"/$bin "$pkg_prefix"/bin/$bin
}

do_strip() {
	# No need to strip as we generate stripped binaries
	return 0
}
