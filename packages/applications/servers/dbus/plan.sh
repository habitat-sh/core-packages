pkg_name=dbus
pkg_origin=core
pkg_version="1.14.10"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0-only' 'BSD-3-Clause' 'AFL-2.1')
pkg_description="D-Bus is a message bus system, a simple way for applications to talk to one another."
pkg_upstream_url="https://www.freedesktop.org/wiki/Software/dbus/"
pkg_source="https://dbus.freedesktop.org/releases/dbus/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="ba1f21d2bd9d339da2d4aa8780c09df32fea87998b73da24f49ab9df1e36a50f"

pkg_deps=(
    core/glibc
    core/expat
)
pkg_build_deps=(
  core/autoconf
  core/automake
  core/make
  core/patchelf
  core/gcc
  core/pkg-config
  core/gettext
)

pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_build() {
    ./configure --prefix=${pkg_prefix}
    make
}

do_install() {
    make install
    find "${pkg_prefix}/libexec" -type f -name "*.so*" -exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;
    for file in dbus-monitor dbus-daemon dbus-run-session dbus-send; do
        patchelf --set-rpath "${LD_RUN_PATH}" "${pkg_prefix}/bin/$file"
    done

    find "${pkg_prefix}/bin" -type f -executable -exec patchelf --shrink-rpath {} \;
}

do_check() {
    make check
}