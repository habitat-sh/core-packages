pkg_name="rust"
pkg_origin="core"
pkg_version="1.62.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Rust is a systems programming language that runs blazingly fast, prevents \
segfaults, and guarantees thread safety.\
"
pkg_upstream_url="https://www.rust-lang.org/"
pkg_license=('Apache-2.0' 'MIT')
pkg_source="https://static.rust-lang.org/dist/${pkg_name}-${pkg_version}-aarch64-unknown-linux-gnu.tar.gz"
pkg_shasum="1311fa8204f895d054c23a3481de3b158a5cd3b3a6338761fee9cdf4dbf075a5"
pkg_dirname="${pkg_name}-${pkg_version}-aarch64-unknown-linux-gnu"
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/bash-static
	core/cacerts
)
pkg_build_deps=(
	core/build-tools-patchelf
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_build() {
	return 0
}

do_strip() {
	return 0
}

do_install() {
	./install.sh --prefix="$pkg_prefix" --disable-ldconfig

	# Update the dynamic linker & set `RUNPATH` for all ELF binaries under `bin/`
	for b in cargo cargo-fmt rls rustc rustdoc rustfmt; do
		patchelf \
			--interpreter "$(pkg_path_for glibc)/lib/ld-linux-aarch64.so.1" \
			--set-rpath "${pkg_prefix}/lib:$(pkg_path_for gcc-libs)/lib:$(pkg_path_for glibc)/lib" \
			"$pkg_prefix/bin/$b"

		patchelf --shrink-rpath "$pkg_prefix/bin/$b"
	done
	unset b

	# Set `RUNPATH` for all shared libraries under `lib/`
	find "$pkg_prefix/lib" -name "*.so" -print0 |
		xargs -0 -I '%' patchelf \
			--set-rpath "${pkg_prefix}/lib:$(pkg_path_for gcc-libs)/lib:$(pkg_path_for glibc)/lib" \
			%

	# Add a wrapper for cargo to properly set SSL certificates. We're wrapping
	# this to set an OpenSSL environment variable. Normally this would not be
	# required as the Habitat OpenSSL pacakge is compiled with the correct path
	# to certificates, however in this case we are not source-compiling Rust,
	# so we can't influence the certificate path after the fact.
	#
	# This is largely a reminder for @fnichol, as he keeps trying to remove this
	# only to remember why it's important in this one instance. Cheers!
	local bin="$pkg_prefix/bin/cargo"
	build_line "Adding wrapper $bin to ${bin}.real"
	mv -v "$bin" "${bin}.real"
	# TODO could core/bash-static be used instead of core/busybox-musl
	cat <<EOF >"$bin"
#!$(pkg_path_for bash-static)/bin/sh
set -e
export SSL_CERT_FILE="$HAB_SSL_CERT_FILE"
exec ${bin}.real \$@
EOF
	chmod -v 755 "$bin"
}