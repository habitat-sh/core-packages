app_name="isl"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-libisl"
pkg_origin="core"
pkg_version="0.25"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
isl is a library for manipulating sets and relations of integer points bounded by linear constraints.
"
pkg_upstream_url="http://www.multiprecision.org/"
pkg_license=('MIT')
pkg_source="https://libisl.sourceforge.io/${app_name}-${pkg_version}.tar.xz"
pkg_shasum="be7b210647ccadf90a2f0b000fca11a4d40546374a850db67adb32fad4b230d9"
pkg_dirname="${app_name}-${pkg_version}"

pkg_deps=(
    core/build-tools-libgmp
    core/build-tools-glibc
    core/build-tools-libstdcpp
)
pkg_build_deps=(
    core/native-cross-gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
    # We move the LD_RUN_PATH into the LDFLAGS and unset LD_RUN_PATH
    # so that the build compiler and linker doesn't pick it up.
    export LDFLAGS="${LDFLAGS} -Wl,-rpath=${LD_RUN_PATH} -Wl,-rpath-link=${LD_RUN_PATH}"
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
    make
}

do_check() {
    make check
}
