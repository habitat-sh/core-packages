pkg_name="libbsd"
pkg_origin="core"
pkg_version="0.11.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
This library provides useful functions commonly found on BSD systems, and \
lacking on others like GNU systems\
"
pkg_upstream_url="https://libbsd.freedesktop.org/wiki/"
# https://cgit.freedesktop.org/libbsd/tree/COPYING
pkg_license=('BSD-3-Clause' 'BSD-4-Clause' 'BSD-2-Clause-NetBSD' 'ISC' 'Beerware' 'LicenseRef-Public-Domain')
pkg_source="https://libbsd.freedesktop.org/releases/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="ff95cf8184151dacae4247832f8d4ea8800fa127dbd15033ecfe839f285b42a1"

pkg_deps=(
	core/glibc
	core/libmd
)
pkg_build_deps=(
	core/gcc
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
			-e "s,@libmd_lib@,$(pkg_path_for libmd)/lib,g" \
			-e "s,@libmd_include@,$(pkg_path_for libmd)/include,g" |
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
