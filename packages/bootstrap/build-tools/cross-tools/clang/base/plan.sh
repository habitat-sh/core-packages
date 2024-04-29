program="clang"
pkg_name="build-tools-clang-base"
pkg_origin="core"
pkg_version="14.0.6"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('Apache-2.0 WITH LLVM-exception')
pkg_source="https://github.com/llvm/llvm-project/releases/download/llvmorg-${pkg_version}/llvm-project-${pkg_version}.src.tar.xz"
pkg_shasum="8b3cfd7bc695bd6cea0f37f53f0981f34f87496e79e2529874fd03a2f9dd3a8a"
pkg_dirname="llvm-project-${pkg_version}.src"
pkg_build_deps=(
    core/build-tools-cmake
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_prepare() {
    # Add package prefix paths to the CMAKE_PREFIX_PATH so that cmake is able
	# to find binaries, libraries and headers
	CMAKE_PREFIX_PATH=$(join_by ";" "${pkg_all_deps_resolved[@]}")
}

do_build() {
    mkdir local-build
    pushd local-build || exit 1
    cmake ../llvm \
        -DLLVM_ENABLE_PROJECTS=clang \
        -DDARWIN_PREFER_PUBLIC_SDK=ON \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DDEFAULT_SYSROOT="$(xcrun --show-sdk-path)" \
        -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
        -DCMAKE_INSTALL_PREFIX="${pkg_prefix}"
    cmake --build . --parallel "$(nproc)"
    popd || exit 1
}

do_install() {
    pushd local-build || exit 1
    cmake --install .
    popd || exit 1
}
