pkg_name="rust"
pkg_origin="core"
pkg_version="1.65.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Rust is a systems programming language that runs blazingly fast, prevents \
segfaults, and guarantees thread safety.\
"
pkg_upstream_url="https://www.rust-lang.org/"
pkg_license=('Apache-2.0' 'MIT')
pkg_source="https://static.rust-lang.org/dist/${pkg_name}-${pkg_version}-aarch64-unknown-linux-gnu.tar.gz"
pkg_shasum="f406136010e6a1cdce3fb6573506f00d23858af49dd20a46723c3fa5257b7796"
pkg_dirname="${pkg_name}-${pkg_version}-aarch64-unknown-linux-gnu"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/build-tools-patchelf
	core/build-tools-cacerts
	core/bash-static
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

	# Set `RUNPATH` for all shared libraries under `lib/`
	find "$pkg_prefix/lib" -name "*.so" -print0 \
		| xargs -0 -I '%' patchelf \
		--set-rpath "$LD_RUN_PATH" \
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
	cat <<EOF > "$bin"
#!$(pkg_path_for bash-static)/bin/sh
set -e
export SSL_CERT_FILE="$HAB_SSL_CERT_FILE"
exec ${bin}.real \$@
EOF
	chmod -v 755 "$bin"
}
