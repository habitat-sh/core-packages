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
	core/binutils
	core/cacerts
	core/glibc
	core/gcc-base
	core/iana-etc
	core/tzdata
)
pkg_build_deps=(
	core/build-tools-patchelf
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_prepare() {
	# Set gcc to use the correct binutils
	set_runtime_env "HAB_GCC_LD_BIN" "$(pkg_path_for binutils-base)/bin"
}

do_build() {
	return 0
}

do_strip() {
	return 0
}

do_install() {
	local libc
	local gcc_base
	local dynamic_linker

	libc="$(pkg_path_for glibc)"
	gcc_base="$(pkg_path_for gcc-base)"
	dynamic_linker="${libc}/lib/ld-linux-aarch64.so.1"

	./install.sh --prefix="$pkg_prefix" --disable-ldconfig

	# Update the dynamic linker & set `RUNPATH` for all ELF binaries under `bin/`
	for binary in "$pkg_prefix"/bin/* "$pkg_prefix"/lib/rustlib/*/bin/* "$pkg_prefix"/lib/rustlib/*/bin/gcc-ld/* "$pkg_prefix"/libexec/*; do
		case "$(file -bi "$binary")" in
		*application/x-executable* | *application/x-pie-executable* | *application/x-sharedlib*)
			patchelf \
				--set-interpreter "${dynamic_linker}" \
				--set-rpath "${pkg_prefix}/lib:${gcc_base}/lib64:${libc}/lib" \
				"$binary"
			patchelf --shrink-rpath "$binary"
			;;
		*) continue ;;
		esac
	done

	# Set `RUNPATH` for all shared libraries under `lib/`
	find "$pkg_prefix/lib" -name "*.so" -print0 |
		xargs -0 -I '%' patchelf \
			--set-rpath "${pkg_prefix}/lib:${gcc_base}/lib64:${libc}/lib" \
			%
	find "$pkg_prefix/lib" -name "*.so" -print0 |
		xargs -0 -I '%' patchelf \
			--shrink-rpath \
			%

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
	local gcc_base
	local wrapper_binary
	local actual_binary

	binary="rustc"
	gcc_base="$(pkg_path_for gcc-base)"
	wrapper_binary="$pkg_prefix/bin/$binary"
	actual_binary="$pkg_prefix/bin/$binary.real"

	build_line "Adding wrapper for $binary"
	mv -v "$wrapper_binary" "$actual_binary"

	sed "$PLAN_CONTEXT/rustc-wrapper.sh" \
		-e "s^@gcc_libs@^${gcc_base}/lib64^g" \
		-e "s^@program@^${actual_binary}^g" \
		>"$wrapper_binary"

	chmod 755 "$wrapper_binary"
}
