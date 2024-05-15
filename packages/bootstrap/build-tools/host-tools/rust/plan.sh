program="rust"
pkg_name="native-rust"
pkg_origin="core"
pkg_version="1.75.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Rust is a systems programming language that runs blazingly fast, prevents \
segfaults, and guarantees thread safety.\
"
pkg_upstream_url="https://www.rust-lang.org/"
pkg_license=('Apache-2.0' 'MIT')
pkg_source="https://static.rust-lang.org/dist/${program}-${pkg_version}-aarch64-apple-darwin.tar.gz"
pkg_shasum="878ecf81e059507dd2ab256f59629a4fb00171035d2a2f5638cb582d999373b1"
pkg_dirname="${program}-${pkg_version}-aarch64-apple-darwin"

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
