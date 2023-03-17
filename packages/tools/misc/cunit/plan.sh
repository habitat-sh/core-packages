program="cunit"

pkg_name="cunit"
pkg_description="CUnit is a lightweight system for writing, administering, and running \
unit tests in C. It provides C programmers a basic testing functionality \
with a flexible variety of user interfaces."
pkg_origin="core"
pkg_version="3.2.7"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("LGPL-2.0")
pkg_upstream_url="https://gitlab.com/cunity/cunit"
pkg_source="https://gitlab.com/cunity/cunit/-/archive/${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="9fcbf439249ff3afd4c028dbfb798ec87757aec6680f11ca38e9f52b50ec9c82"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)

pkg_build_deps=(
	core/coreutils
	core/gcc
	core/sed
	core/cmake-stage1
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	mkdir local-build
	pushd local-build || exit 1
	cmake .. --install-prefix="${pkg_prefix}"
	cmake --build .
	popd || exit 1
}

do_check() {
	pushd local-build || exit 1
	make test
	popd || exit 1
}

do_install() {
	pushd local-build || exit 1
	cmake --install .
	popd || exit 1

	# Write pkgconfig files because the newer CMake
	# build system does not generate them by default
	sed cunit.pc.in \
		-e "s^@prefix@^${pkg_prefix}^g" \
		-e 's^@exec_prefix@^${prefix}^g' \
		-e 's^@libdir@^${exec_prefix}/lib^g' \
		-e 's^@includedir@^${prefix}/include^g' \
		-e "s^@VERSION@-@RELEASE@^${pkg_version}^g" \
		>"${pkg_prefix}/lib/pkgconfig/cunit.pc"
}
