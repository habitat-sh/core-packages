program="rust"
pkg_name="native-rust"
pkg_origin="core"
pkg_version="1.68.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Rust is a systems programming language that runs blazingly fast, prevents \
segfaults, and guarantees thread safety.\
"
pkg_upstream_url="https://www.rust-lang.org/"
pkg_license=('Apache-2.0' 'MIT')
pkg_source="https://static.rust-lang.org/dist/${program}-${pkg_version}-aarch64-unknown-linux-gnu.tar.gz"
pkg_shasum="b24d0df852490d80791a228f18c2b75f24b1e6437e6e745f85364edab245f7fa"
pkg_dirname="${program}-${pkg_version}-aarch64-unknown-linux-gnu"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_build() {
	return 0
}

do_install() {
	./install.sh --prefix="$pkg_prefix" --disable-ldconfig
	# Delete the uninstaller script as it is not required
	rm "${pkg_prefix}"/lib/rustlib/uninstall.sh
}
