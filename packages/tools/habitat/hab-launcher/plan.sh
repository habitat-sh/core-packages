# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="94d6d50138d1fe005e59f4a7117974ce1b977ae2"
pkg_shasum="ba63a6638fb181c6a7f24d8efb5f5750a648d85fa9456a4a3a9be71471f098f1"

pkg_name="hab-launcher"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_dirname="habitat-${commit_hash}"

pkg_deps=(
	core/glibc
#	core/gcc-libs
	core/gcc-base
)
pkg_build_deps=(
	core/coreutils
	core/gawk
	core/gcc
	core/git
	core/grep
	core/make
	core/protobuf
	core/rust/1.62.1
	core/sed
)
pkg_bin_dirs=(bin)

# Use the number of commits from the start of this repository
# to the current HEAD as the version for our pkg_version
pkg_version() {
	git clone --bare $git_url "$HAB_CACHE_SRC_PATH/$pkg_dirname-git"
	git \
		--git-dir="$HAB_CACHE_SRC_PATH/$pkg_dirname-git" \
		rev-list "$(git \
			--git-dir="$HAB_CACHE_SRC_PATH/$pkg_dirname-git" \
			rev-parse $commit_hash)" \
		--count
}

do_unpack() {
	do_default_unpack
	update_pkg_version
}

# shellcheck disable=2155
do_prepare() {
	# Used by the `build.rs` program to set the version of the binaries
	export PLAN_VERSION="${pkg_version}/${pkg_release}"
	build_line "Setting PLAN_VERSION=$PLAN_VERSION"

	# Used to set the active package target for the binaries at build time
	export PLAN_PACKAGE_TARGET="$pkg_target"
	build_line "Setting PLAN_PACKAGE_TARGET=$PLAN_PACKAGE_TARGET"

	if [ -z "$HAB_CARGO_TARGET_DIR" ]; then
		# Used by Cargo to use a pristine, isolated directory for all compilation
		export CARGO_TARGET_DIR="$HAB_CACHE_SRC_PATH/$pkg_dirname"
	else
		export CARGO_TARGET_DIR="$HAB_CARGO_TARGET_DIR"
	fi
	build_line "Setting CARGO_TARGET_DIR=$CARGO_TARGET_DIR"

	export rustc_target="${pkg_target%%-*}-unknown-linux-gnu"
	build_line "Setting rustc_target=$rustc_target"

	# Prost (our Rust protobuf library) embeds a `protoc` binary, but
	# it's dynamically linked, which means it won't work in a
	# Studio. Prost does allow us to override that, though, so we can
	# just use our Habitat package by setting these two environment
	# variables.
	export PROTOC="$(pkg_path_for protobuf)/bin/protoc"
	export PROTOC_INCLUDE="$(pkg_path_for protobuf)/include"
}

do_build() {
	pushd "$SRC_PATH" >/dev/null || exit
	cargo build --release --target="$rustc_target" --verbose --bin hab-launch
	popd >/dev/null || exit
}

do_install() {
	install -v -D "$CARGO_TARGET_DIR"/"$rustc_target"/release/hab-launch "$pkg_prefix"/bin/hab-launch
}
