program="rust"
pkg_name="build-tools-rust"
pkg_origin="core"
pkg_version="1.79.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Rust is a systems programming language that runs blazingly fast, prevents \
segfaults, and guarantees thread safety.\
"
pkg_upstream_url="https://www.rust-lang.org/"
pkg_license=('Apache-2.0' 'MIT')
pkg_source="https://static.rust-lang.org/dist/${program}-${pkg_version}-x86_64-unknown-linux-gnu.tar.gz"
pkg_shasum="628efa8ef0658a7c4199883ee132281f19931448d3cfee4ecfd768898fe74c18"
pkg_dirname="${program}-${pkg_version}-x86_64-unknown-linux-gnu"
pkg_deps=(
	core/build-tools-binutils
	core/build-tools-cacerts
	core/build-tools-glibc
	core/build-tools-gcc
	core/build-tools-zlib
)
pkg_build_deps=(
	core/build-tools-patchelf
	core/build-tools-coreutils
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_prepare() {
	# Set gcc to use the correct binutils
	set_runtime_env "HAB_GCC_LD_BIN" "$(pkg_path_for build-tools-binutils)/bin"

    # The `/usr/bin/env` path is hardcoded, so we'll add a symlink if needed.
	if [[ ! -r /usr/bin/env ]]; then
		ln -sv "$(pkg_path_for build-tools-coreutils)/bin/env" /usr/bin/env
		_clean_env=true
	fi
}

do_build() {
	return 0
}

do_install() {
	local libc
	local gcc_base
	local zlib
	local dynamic_linker

	libc="$(pkg_path_for build-tools-glibc)"
	gcc_base="$(pkg_path_for build-tools-gcc)"
	zlib="$(pkg_path_for build-tools-zlib)"
	dynamic_linker="${libc}/lib/ld-linux-x86-64.so.2"

	./install.sh --prefix="$pkg_prefix" --disable-ldconfig

	# Update the dynamic linker & set `RUNPATH` for all ELF binaries under `bin/`
	for binary in "$pkg_prefix"/bin/* "$pkg_prefix"/lib/rustlib/*/bin/* "$pkg_prefix"/lib/rustlib/*/bin/self-contained/* "$pkg_prefix"/lib/rustlib/*/bin/gcc-ld/* "$pkg_prefix"/libexec/*; do
		case "$(file -bi "$binary")" in
		*application/x-executable* | *application/x-pie-executable* | *application/x-sharedlib*)
			patchelf \
				--set-interpreter "${dynamic_linker}" \
				--set-rpath "${pkg_prefix}/lib:${gcc_base}/lib64:${libc}/lib:${zlib}/lib" \
				"$binary"
			patchelf --shrink-rpath "$binary"
			;;
		*) continue ;;
		esac
	done

	# Set `RUNPATH` for all shared libraries under `lib/`
	# Find all .so files and process them
	find "$pkg_prefix/lib" -name "*.so*" -print0 |
	while IFS= read -r -d '' file; do
		# Check if the file is an ELF file
		if file "$file" | grep -q 'ELF'; then
			# Apply patchelf and handle errors
			if ! patchelf --set-rpath "${pkg_prefix}/lib:${gcc_base}/lib64:${libc}/lib:${zlib}/lib" "$file" 2>&1; then
				echo "Error applying patchelf to $file" >&2
			fi
		else
			echo "Skipping non-ELF file: $file" >&2
		fi
	done

	find "$pkg_prefix/lib" -name "*.so*" -print0 |
	while IFS= read -r -d '' file; do
		# Check if the file is an ELF file
		if file "$file" | grep -q 'ELF'; then
			# Apply patchelf and handle errors
			if ! patchelf --shrink-rpath "$file" 2>&1; then
				echo "Error shrinking rpath for $file" >&2
			fi
		else
			echo "Skipping non-ELF file: $file" >&2
		fi
	done

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
	gcc_base="$(pkg_path_for build-tools-gcc)"
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

do_strip() {
	return 0
}

