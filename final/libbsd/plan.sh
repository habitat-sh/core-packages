pkg_name="libbsd"
pkg_origin="core"
pkg_version="0.11.7"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
This library provides useful functions commonly found on BSD systems, and \
lacking on others like GNU systems\
"
pkg_upstream_url="https://libbsd.freedesktop.org/wiki/"
pkg_license=('custom')
pkg_source="https://libbsd.freedesktop.org/releases/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="9baa186059ebbf25c06308e9f991fda31f7183c0f24931826d83aa6abd8a0261"

pkg_deps=(
	core/glibc
	core/libmd
)
pkg_build_deps=(
	core/file
	core/gcc
	core/make
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	if [[ ! -r /usr/bin/file ]]; then
		ln -sv "$(pkg_path_for "core/file")/bin/file" /usr/bin/file
		_clean_file=true
	fi
}

do_install() {
	do_default_install

	# Install license file from README
	install -Dm644 COPYING "${pkg_prefix}/share/licenses/LICENSE"
}

do_check() {
	make check
}

do_end() {
	if [[ -n "$_clean_file" ]]; then
		rm -fv /usr/bin/file
	fi
}
