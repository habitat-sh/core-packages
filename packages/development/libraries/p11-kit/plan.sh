pkg_name=p11-kit
pkg_origin=core
pkg_version="0.25.5"
pkg_description="Provides a way to load and enumerate PKCS#11 modules."
pkg_upstream_url="https://p11-glue.github.io/p11-glue/p11-kit.html"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-3-Clause')
pkg_source="https://github.com/p11-glue/p11-kit/archive/refs/tags/${pkg_version}.tar.gz"
pkg_shasum="69a54cf01b1603f4721f3c576c5a6bf1ac14477ea0da0cf41e1b7cb5c3884065"

pkg_deps=(
    core/glibc
    core/libtasn1
)
pkg_build_deps=(
  core/gcc
  core/pkg-config
  core/meson
  core/cmake
  core/gettext
  core/git
  core/ninja
  core/patchelf
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
    # download subproject
    git clone https://github.com/p11-glue/pkcs11-json ${CACHE_PATH}/subprojects/pkcs11-json

    export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/

    meson setup builddir -Dsystemd=disabled -Dbash_completion=disabled --prefix="${pkg_prefix}" --buildtype=release
    meson compile -C builddir
}

do_install() {
    meson install -C builddir

    for file in p11-kit trust; do
        patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/bin/$file
    done
}

do_check() {
    meson test -C builddir
}