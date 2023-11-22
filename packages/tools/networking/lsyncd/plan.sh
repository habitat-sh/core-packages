pkg_name="lsyncd"
pkg_origin="core"
pkg_version="2.2.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0')
pkg_source="https://github.com/lsyncd/lsyncd/archive/refs/tags/release-$pkg_version.tar.gz"
pkg_dirname="$pkg_name-release-$pkg_version"
pkg_shasum="3f51c6456604b5acce191c3539e7693a63bd395045dfd5ba35fa4222ca76ed79"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/cmake
	core/gcc
	core/lua
	core/make
)
pkg_bin_dirs=(bin)
pkg_description="Lsyncd watches a local directory trees event monitor interface (inotify or fsevents)"
pkg_upstream_url="https://axkibe.github.io/lsyncd/"

do_build() {
	mkdir build
	pushd build || exit 1
	cmake \
		-DLUA_LIBRARIES="lua -ldl -lm" \
		-DLUA_INCLUDE_DIR="$(pkg_path_for lua)/include" \
		-DCMAKE_INSTALL_PREFIX:PATH="$pkg_prefix" \
		..
	make
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	make install
	popd || exit 1
}
