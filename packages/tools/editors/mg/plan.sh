pkg_name="mg"
pkg_origin="core"
pkg_version="7.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
mg is Micro GNU/emacs, this is a portable version of the mg maintained by the \
OpenBSD team.\
"
pkg_upstream_url="https://github.com/hboetes/mg"
pkg_license=('LicenseRef-Public-Domain' 'BSD-2-Clause-NetBSD')
pkg_source="https://github.com/ibara/mg/archive/refs/tags/mg-${pkg_version}.tar.gz"
pkg_shasum="60d3de8e989d8827c81aadb6e161e2b8544778e4470149f4e48efef32a18afdc"
pkg_dirname="mg-mg-${pkg_version}"

pkg_deps=(
	core/ncurses
)

pkg_build_deps=(
	core/coreutils
	core/pkg-config
	core/clang
)

pkg_bin_dirs=(bin)


# do_prepare() {
#     # Add package prefix paths to the CMAKE_PREFIX_PATH so that cmake is able
# 	# to find binaries, libraries and headers
# 	CMAKE_PREFIX_PATH=$(join_by ";" "${pkg_all_deps_resolved[@]}")
# }

# do_build() {
#     mkdir local-build
#     pushd local-build || exit 1
#     cmake ../ \
#         -DCMAKE_BUILD_TYPE="Release" \
#         -DCMAKE_VERBOSE_MAKEFILE=ON \
#         -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
#         -DCMAKE_INSTALL_PREFIX="${pkg_prefix}"
#     cmake --build . --parallel "$(nproc)"
#     popd || exit 1
# }

# do_install() {
#     pushd local-build || exit 1
#     cmake --install .
#     popd || exit 1
# 	install -Dm644 README "$pkg_prefix/share/licenses/README"
# }

# do_prepare() {
# 	# shellcheck disable=SC2002
# 	cat "$PLAN_CONTEXT/update-path.patch" |
# 		sed \
# 			-e "s,@prefix@,$pkg_prefix,g" \
# 			-e "s,@pkgconfig@,$(pkg_path_for pkg-config),g" \
# 			-e "s,@coreutils@,$(pkg_path_for coreutils),g" \
# 			-e "s,@binutils@,/usr,g" |
# 		patch -p1
# }

do_build() {
	./configure --prefix="$pkg_prefix"
	make
}

do_install() {
	make install

	# Install license file from README
	install -Dm644 README "$pkg_prefix/share/licenses/README"
}
