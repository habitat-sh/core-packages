pkg_name=fd
pkg_origin=core
pkg_version=7.5.0
pkg_license=('MIT' 'Apache-2.0')
pkg_bin_dirs=(bin)
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url="https://github.com/sharkdp/fd"
pkg_source="https://github.com/sharkdp/fd/archive/v${pkg_version}.tar.gz"
pkg_shasum=8a78ca24323c832cf205c1fce8276fc25ae90371531c32e155301937986ea713
pkg_filename="${pkg_name}-${pkg_version}.tar.gz"
pkg_description="fd is a simple, fast and user-friendly alternative to find"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/rust
)

do_prepare() {
	export CARGO_HOME="$HAB_CACHE_SRC_PATH/$pkg_dirname/.cargo"
	export CARGO_TARGET_DIR="$HAB_CACHE_SRC_PATH/$pkg_dirname/target"

	build_line "Setting CARGO_HOME=$CARGO_HOME"
	build_line "Setting CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
}

do_build() {
	return 0
}

do_install() {
	cargo install \
		--path . \
		--root "${pkg_prefix}" \
		--locked \
		--target="${TARGET_ARCH:-${pkg_target%%-*}}-unknown-linux-gnu" \
		--verbose
}
