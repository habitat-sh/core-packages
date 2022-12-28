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
	core/coreutils
	core/file
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# The libbsd headers make use of the #include_next directive in some header
	# files. These kind of headers must be included in a specific order so that
	# they behave correctly. In this case the libbsd headers must be included
	# before the libmd headers. To ensure this we must explicitly add the libmd
	# include directories via extra -isystem flags. This patch does takes care of
	# this for us.

	# shellcheck disable=SC2002
	cat "$PLAN_CONTEXT/libmd-pkg.patch" |
		sed \
			-e "s,@LIBMD_LIB@,$(pkg_path_for libmd)/lib,g" \
			-e "s,@LIBMD_INCLUDE@,$(pkg_path_for libmd)/include,g" |
		patch -p1
}

do_check() {
	make check
}

do_install() {
	do_default_install

	# Install license file from README
	install -Dm644 COPYING "${pkg_prefix}/share/licenses/LICENSE"
}
