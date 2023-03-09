program="icu"
pkg_origin="core"
pkg_name="icu"
pkg_version="72.1"
pkg_description="ICU is a mature, widely used set of C/C++ and Java libraries providing \
  Unicode and Globalization support for software applications. ICU is widely \
  portable and gives applications the same results on all platforms and \
  between C/C++ and Java software."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Unicode-TOU")
# shellcheck disable=SC2059
pkg_upstream_url="http://site.icu-project.org/"
pkg_source="https://github.com/unicode-org/icu/releases/download/release-${pkg_version//./-}/icu4c-${pkg_version//./_}-src.tgz"
pkg_shasum="a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68"
pkg_dirname="icu/source"
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/grep
	core/make
	core/sed
	core/build-tools-python
)

do_prepare() {
	# Add the lib folder to the rpath because several libraries
	# look for deps in the same folder
	LDFLAGS="${LDFLAGS} -Wl,-rpath=${pkg_prefix}/lib"
	build_line "Updating LDFLAGS=${LDFLAGS}"
}

do_build() {
	./configure --prefix="${pkg_prefix}"
	make -j"$(nproc)"
}

do_check() {
	make check
}
