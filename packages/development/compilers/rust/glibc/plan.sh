pkg_name="rust"
pkg_origin="core"
pkg_version="1.79.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Rust is a systems programming language that runs blazingly fast, prevents \
segfaults, and guarantees thread safety.\
"
pkg_upstream_url="https://www.rust-lang.org/"
pkg_license=('Apache-2.0' 'MIT')
_url_base="https://static.rust-lang.org/dist"
pkg_source="$_url_base/${pkg_name}-${pkg_version}-x86_64-unknown-linux-gnu.tar.gz"
pkg_shasum="628efa8ef0658a7c4199883ee132281f19931448d3cfee4ecfd768898fe74c18"
pkg_dirname="${pkg_name}-${pkg_version}-x86_64-unknown-linux-gnu"
pkg_deps=(
	core/binutils
	core/cacerts
	core/glibc
	core/gcc-base
	core/iana-etc
	core/tzdata
	core/zlib
)
pkg_build_deps=(
	core/build-tools-patchelf
	core/build-tools-coreutils
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

_target_sources=(
  "${_url_base}/${pkg_name}-std-${pkg_version}-x86_64-unknown-linux-musl.tar.gz"
)

_target_shasums=(
    "8ee9728f1f615ca07aeec963f85cd4ad6941b932fffce6c434dd012b9e094eeb"
)

do_prepare() {
	# Set gcc to use the correct binutils
	set_runtime_env "HAB_GCC_LD_BIN" "$(pkg_path_for binutils)/bin"

		# The `/usr/bin/env` path is hardcoded, so we'll add a symlink if needed.
	if [[ ! -r /usr/bin/env ]]; then
		ln -sv "$(pkg_path_for build-tools-coreutils)/bin/env" /usr/bin/env
		_clean_env=true
	fi
}

do_download() {
  do_default_download

  # Download all target sources, providing the corresponding shasums so we can
  # skip re-downloading if already present and verified
  for i in $(seq 0 $((${#_target_sources[@]} - 1))); do
    p="${_target_sources[$i]}"
    download_file "$p" "$(basename "$p")" "${_target_shasums[$i]}"
  done; unset i p
}

do_verify() {
  do_default_verify

  # Verify all target sources against their shasums
  for i in $(seq 0 $((${#_target_sources[@]} - 1))); do
    verify_file "$(basename "${_target_sources[$i]}")" "${_target_shasums[$i]}"
  done; unset i
}

do_unpack() {
  do_default_unpack

  pushd "$HAB_CACHE_SRC_PATH/$pkg_dirname" > /dev/null
    # Unpack all targets inside the main source directory
    for i in $(seq 0 $((${#_target_sources[@]} - 1))); do
      tar xf "$HAB_CACHE_SRC_PATH/$(basename "${_target_sources[$i]}")"
    done; unset i
  popd > /dev/null
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
	local zlib
	local dynamic_linker

	libc="$(pkg_path_for glibc)"
	gcc_base="$(pkg_path_for gcc-base)"
	zlib="$(pkg_path_for zlib)"
	dynamic_linker="${libc}/lib/ld-linux-x86-64.so.2"

	./install.sh --prefix="$pkg_prefix" --disable-ldconfig

	# Update the dynamic linker & set `RUNPATH` for all ELF binaries under `bin/`
	for binary in "$pkg_prefix"/bin/* "$pkg_prefix"/lib/rustlib/*/bin/* "$pkg_prefix"/lib/rustlib/*/bin/gcc-ld/* "$pkg_prefix"/libexec/*; do
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
	find "$pkg_prefix/lib" -name "*so*" -a -type f -print0 \
		| xargs -0 file \
		| grep "ELF.*shared object" \
		| cut -d: -f1 \
		| xargs -I '%' patchelf \
			--set-rpath "${pkg_prefix}/lib:${gcc_base}/lib64:${libc}/lib:${zlib}/lib" \
			%
	find "$pkg_prefix/lib" -name "*so*" -a -type f -print0 \
		| xargs -0 file \
		| grep "ELF.*shared object" \
		| cut -d: -f1 \
		| xargs -I '%' patchelf \
			--shrink-rpath \
			%

	# Install all targets
	local dir
	for i in $(seq 0 $((${#_target_sources[@]} - 1))); do
		dir="$(basename "${_target_sources[$i]/%.tar.gz/}")"
		pushd "$HAB_CACHE_SRC_PATH/$pkg_dirname/$dir" > /dev/null
		build_line "Installing $dir target for Rust"
		./install.sh --prefix="$("$pkg_prefix/bin/rustc" --print sysroot)"
		popd > /dev/null
	done; unset i

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
