program="isl"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-isl"
pkg_origin="core"
pkg_version="0.25"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
isl is a library for manipulating sets and relations of integer points bounded by linear constraints.
"
pkg_upstream_url="http://www.multiprecision.org/"
pkg_license=('MIT')
pkg_source="https://libisl.sourceforge.io/${program}-${pkg_version}.tar.xz"
pkg_shasum="be7b210647ccadf90a2f0b000fca11a4d40546374a850db67adb32fad4b230d9"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/build-tools-gmp
	core/build-tools-glibc
)
pkg_build_deps=(
	core/native-cross-gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# We have to add extra -rpath-link flags to ensure the compiler finds libgmp in
	# certain build steps. This seems like a bug in the ISL makefile that we are fixing for.
	export LDFLAGS="${LDFLAGS} -Wl,-rpath-link=${LD_RUN_PATH}"

	# To prevent the build compiler/linker from being affected by LD_RUN_PATH,
	# we transfer its value to HAB_LD_RUN_PATH and unset LD_RUN_PATH.
	# This allows the native-cross-binutils linker to utilize HAB_LD_RUN_PATH instead.
	export HAB_LD_RUN_PATH="${LD_RUN_PATH}"
	unset LD_RUN_PATH

	# By default LDFLAGS, CFLAGS, CPPFLAGS and CXXFLAGS get used by the
	# build compiler. To prevent this we set *FLAGS_FOR_BUILD="" to
	# prevent any interference with the build compiler and linker.
	export LDFLAGS_FOR_BUILD=""
	export CFLAGS_FOR_BUILD=""
	export CPPFLAGS_FOR_BUILD=""
	export CXXFLAGS_FOR_BUILD=""
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(./config.guess)" \
		--host="$native_target" \
		--disable-static
	make V=1
}

do_check() {
	make check
}
