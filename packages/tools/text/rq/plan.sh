pkg_name="rq"
pkg_origin="core"
pkg_version="0.10.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Record Query is a tool for doing record analysis and transformation. It's \
used for performing queries on streams of records in various formats.\
"
pkg_upstream_url="https://github.com/dflemstr/rq"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/dflemstr/rq/releases/download/v${pkg_version}/${pkg_name}-v${pkg_version}-aarch64-unknown-linux-gnu.tar.gz"
pkg_shasum="1b9abedd7acca1269ac1c4765d93bab73777feca9a04358ea4f9c9659bf51e62"

pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/patchelf
)

pkg_bin_dirs=(bin)

do_build() {
	return 0
}

do_install() {
	install -v "$HAB_CACHE_SRC_PATH/rq" "$pkg_prefix/bin/$pkg_name"
	return 0
}

do_strip() {
	do_default_strip

	# Patching the binary after stripping unneeded symbols because strip does not
	# like the modifications patchelf makes
	patchelf \
		--interpreter "$(pkg_path_for core/glibc)/lib/ld-linux-aarch64.so.1" \
		--set-rpath "${LD_RUN_PATH}" \
		"${pkg_prefix}/bin/rq"
}
