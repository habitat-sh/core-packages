pkg_name="protobuf"
pkg_origin="core"
pkg_version="21.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Protocol buffers are a language-neutral, platform-neutral extensible mechanism \
for serializing structured data. \
"
pkg_upstream_url="https://developers.google.com/protocol-buffers/"
pkg_license=('BSD-3-Clause')
pkg_source="https://github.com/google/${pkg_name}/releases/download/v${pkg_version}/${pkg_name}-all-${pkg_version}.tar.gz"
pkg_shasum="2c6a36c7b5a55accae063667ef3c55f2642e67476d96d355ff0acb13dbb47f09"

pkg_deps=(
	core/glibc
	core/gcc-libs
	core/zlib
)
pkg_build_deps=(
	core/gcc
	core/python
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="${pkg_prefix}"

	make -j"$(nproc)"
}

do_check() {
	make check
}

do_install() {
	make install

	# Install license file
	install -Dm644 LICENSE "${pkg_prefix}/share/licenses/LICENSE"
}
