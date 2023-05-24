program="toml-cli"

pkg_name="build-tools-toml-cli"
pkg_origin="core"
pkg_version="0.2.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="A simple CLI for editing and querying TOML files."
pkg_upstream_url="https://github.com/gnprice/toml-cli"
pkg_license=('MIT')
pkg_source="https://github.com/gnprice/toml-cli/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="913f104612b0e549090e1cf77a7a49a12fa286af7e720dd46265bcc554b8f73a"
pkg_dirname="${program}-${pkg_version}"
pkg_bin_dirs=(bin)

pkg_build_deps=(
	core/native-rust
)

do_prepare() {
	export CARGO_HOME="$HAB_CACHE_SRC_PATH/$pkg_dirname/.cargo"
	export CARGO_TARGET_DIR="$HAB_CACHE_SRC_PATH/$pkg_dirname/target"
	# Add flags to build a static binary with the C runtime linked in
	export RUSTFLAGS='-C target-feature=+crt-static'

	build_line "Setting CARGO_HOME=$CARGO_HOME"
	build_line "Setting CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
	build_line "Setting RUSTFLAGS=${RUSTFLAGS}"
}

do_build() {
	return 0
}

do_install() {
	cargo install \
		--path . \
		--root "${pkg_prefix}" \
		--target="${TARGET_ARCH:-${pkg_target%%-*}}-unknown-linux-gnu"
}
