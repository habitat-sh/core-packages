program="zeromq"
pkg_name="zeromq"
pkg_origin="core"
pkg_version="4.3.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="ZeroMQ core engine in C++, implements ZMTP/3.1"
pkg_upstream_url="http://zeromq.org"
pkg_license=('LGPL-3.0-or-later')
pkg_source="https://github.com/zeromq/libzmq/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="c593001a89f5a85dd2ddf564805deb860e02471171b3f204944857336295c3e5"

pkg_deps=(
	core/libsodium
)

pkg_build_deps=(
	core/pkg-config
	core/cmake
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	patch -p1 <"$PLAN_CONTEXT"/patch-cxx11.release.diff
	patch -p1 <"$PLAN_CONTEXT"/patch-c11.release.diff
	patch -p1 <"$PLAN_CONTEXT"/patch-fix-docs-dir.release.diff
	patch -p1 <"$PLAN_CONTEXT"/patch-fix-no-librt-APPLE.release.diff
	patch -p1 <"$PLAN_CONTEXT"/patch-clock.hpp.diff
	patch -p1 <"$PLAN_CONTEXT"/patch-tests.diff

	CMAKE_PREFIX_PATH=$(join_by ";" "${pkg_all_deps_resolved[@]}")
}

do_build() {
    mkdir local-build
    pushd local-build || exit 1
    cmake ../ \
		-DWITH_PERF_TOOL=OFF \
		-DZMQ_BUILD_TESTS=OFF \
		-DENABLE_CPACK=OFF \
		-DWITH_LIBBSD=OFF \
		-DWITH_LIBSODIUM=ON \
		-DENABLE_LIBSODIUM_RANDOMBYTES_CLOSE=ON \
		-DWITH_LIBSODIUM_STATIC=OFF \
		-DWITH_NSS=OFF \
		-DWITH_TLS=OFF \
		-DENABLE_INTRINSICS=OFF \
		-DZMQ_BUILD_FRAMEWORK=OFF \
		-DC_STANDARD=11 \
		-DCXX_STANDARD=11 \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
        -DCMAKE_INSTALL_PREFIX="${pkg_prefix}"
    cmake --build . --parallel "$(nproc)"
    popd || exit 1
}

do_install() {
    pushd local-build || exit 1
    cmake --install .
	install_name_tool -id "$pkg_prefix/lib/libzmq.5.2.4.dylib" "$pkg_prefix/lib/libzmq.5.2.4.dylib"
    popd || exit 1
}
