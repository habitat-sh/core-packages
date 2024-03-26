program="rust"
arch=${pkg_target%%-*}
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
pkg_source="https://static.rust-lang.org/dist/${program}-${pkg_version}-${arch}-unknown-linux-gnu.tar.gz"
pkg_shasum="df7c7466ef35556e855c0d35af7ff08e133040400452eb3427c53202b6731926"
pkg_dirname="${program}-${pkg_version}-${arch}-unknown-linux-gnu"

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
