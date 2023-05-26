program="rust"
arch=${pkg_target%%-*}
pkg_name="native-rust"
pkg_origin="core"
pkg_version="1.62.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Rust is a systems programming language that runs blazingly fast, prevents \
segfaults, and guarantees thread safety.\
"
pkg_upstream_url="https://www.rust-lang.org/"
pkg_license=('Apache-2.0' 'MIT')
pkg_source="https://static.rust-lang.org/dist/${program}-${pkg_version}-${arch}-unknown-linux-gnu.tar.gz"
pkg_shasum="dd7d82b8fa8eae59729e1c31fe59a9de6ee61d08ab40ce016185653beebe04d2"
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
