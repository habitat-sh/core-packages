program="rust"
pkg_name="rust"
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
pkg_deps=(
	core/git
	core/iana-etc
	core/ld64
	core/clang
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

runtime_sandbox() {
	echo '(version 1)
;; Allow cargo to read the openssl files from the host system
;; This is required since the cargo is a pre-compiled binary
(allow file-read-metadata (literal "/etc"))
(allow file-read*
	(literal "/private/etc/ssl/openssl.cnf")
	(literal "/private/etc/ssl/cert.pem"))
'
}

do_prepare() {
	set_runtime_env "CARGO_NET_GIT_FETCH_WITH_CLI" "true"
}

do_build() {
	return 0
}

do_strip() {
	return 0
}

do_install() {
	./install.sh --prefix="$pkg_prefix" --disable-ldconfig

	# We wrap the rustc binary to include the core/gcc-base lib64 directory consistently in
	# the LD_RUN_PATH. This guarantees its addition to the runpath of any auxiliary binaries
	# produced by the rust compiler, irrespective of whether it's a `pkg_dep` on the currently
	# executed plan. Additionally, we guarantee the integration of a -L linker flag in the
	# RUSTFLAGS to ensure the library's detection during the linking process.
	wrap_rustc_binary

	# Delete the uninstaller script as it is not required
	rm "${pkg_prefix}"/lib/rustlib/uninstall.sh
}

wrap_rustc_binary() {
	local binary
	local wrapper_binary
	local actual_binary

	binary="rustc"
	wrapper_binary="$pkg_prefix/bin/$binary"
	actual_binary="$pkg_prefix/bin/$binary.real"

	build_line "Adding wrapper for $binary"
	mv -v "$wrapper_binary" "$actual_binary"

	sed "$PLAN_CONTEXT/rustc-wrapper.sh" \
		-e "s^@program@^${actual_binary}^g" \
		>"$wrapper_binary"

	chmod 755 "$wrapper_binary"
}
