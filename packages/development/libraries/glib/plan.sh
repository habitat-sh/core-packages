pkg_name=glib
pkg_origin=core
pkg_version="2.81.0"
pkg_description="$(cat << EOF
  GLib is a general-purpose utility library, which provides many useful data
  types, macros, type conversions, string utilities, file utilities, a
  mainloop abstraction, and so on. It works on many UNIX-like platforms, as
  well as Windows and OS X.
EOF
)"
pkg_source="https://download.gnome.org/sources/${pkg_name}/${pkg_version%.*}/${pkg_name}-${pkg_version}.tar.xz"
pkg_license=('Apache-2.0 WITH LLVM-exception' 'CC0-1.0' 'GPL-2.0-or-later' 'LGPL-2.1-or-later' 'MIT' 'MPL-1.1')
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_upstream_url="https://developer.gnome.org/glib/"
pkg_shasum="1665188ed9cc941c0a189dc6295e6859872523d1bfc84a5a84732a7ae87b02e4"

pkg_deps=(
  core/coreutils
  core/glibc
  core/libffi
  core/libiconv
  core/pcre2
  core/util-linux
  core/zlib
  core/python
)
pkg_build_deps=(
  core/file
  core/gcc
  core/gettext
  core/libxslt
  core/meson
  core/ninja
  core/pkg-config
  core/patchelf
  core/git
  core/cmake
  core/dbus
  core/libunwind
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(
  include
  include/glib-2.0
  lib/glib-2.0/include
)
pkg_pconfig_dirs=(lib/pkgconfig)
pkg_interpreters=(core/coreutils)

do_build() {
  export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/

  # un-documented requirement of libraries
  python -m pip install -U packaging

  meson setup builddir --prefix="$pkg_prefix" \
    -Ddocumentation=false \
    --buildtype release

  fix_interpreter "${CACHE_PATH}/tools/gen-visibility-macros.py" core/coreutils bin/env

  meson compile -C builddir
}

do_install() {
  meson install -C builddir

  find "$pkg_prefix"/bin -type f -executable \
    -exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {}  \; \
    -exec patchelf --force-rpath --set-rpath "${LD_RUN_PATH}" {} \;

  for lib in "${pkg_lib_dirs[@]}"; do
    find "${pkg_prefix}/${lib}" -type f -executable \
      -exec sh -c 'file -i "$1" | grep -q "x-sharedlib; charset=binary"' _ {} \; \
      -exec patchelf --force-rpath --set-rpath "${LD_RUN_PATH}" {} \;
  done

  find "${pkg_prefix}/bin" -type f -executable -exec patchelf --shrink-rpath {} \;
  patchelf --shrink-rpath "${pkg_prefix}/libexec/gio-launch-desktop"
  patchelf --set-rpath "$(pkg_path_for libffi)/lib:${pkg_prefix}/lib" "${pkg_prefix}/bin/gi-compile-repository"
}