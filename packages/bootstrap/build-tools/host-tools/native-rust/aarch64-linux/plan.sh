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
pkg_source="https://static.rust-lang.org/dist/${program}-${pkg_version}-aarch64-unknown-linux-gnu.tar.gz"
pkg_shasum="30828cd904fcfb47f1ac43627c7033c903889ea4aca538f53dcafbb3744a9a73"
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

do_strip() {
	return 0
}
