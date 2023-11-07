pkg_name="glib"
pkg_origin="core"
pkg_version="2.70.2"
pkg_description="$(
	cat <<EOF
  GLib is a general-purpose utility library, which provides many useful data
  types, macros, type conversions, string utilities, file utilities, a
  mainloop abstraction, and so on. It works on many UNIX-like platforms, as
  well as Windows and OS X.
EOF
)"
pkg_source="https://download.gnome.org/sources/${pkg_name}/${pkg_version%.*}/${pkg_name}-${pkg_version}.tar.xz"
pkg_license=('LGPL-2.0')
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_upstream_url="https://developer.gnome.org/glib/"
pkg_shasum="0551459c85cd3da3d58ddc9016fd28be5af503f5e1615a71ba5b512ac945806f"
pkg_deps=(
	core/coreutils
	core/elfutils
	core/glibc
	core/libffi
	core/libiconv
	core/pcre
	core/python
	core/util-linux
	core/zlib
)
pkg_build_deps=(
	core/dbus
	core/diffutils
	core/file
	core/gcc
	core/gettext
	core/libxslt
	core/meson
	core/perl
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# This is needed to prevent meson and ninja from stripping the rpath entries
	# when installing compiled binaries to the final location
	export LDFLAGS="${LDFLAGS} -Wl,-rpath=${LD_RUN_PATH}"
	# Fix all interpreters in the source code
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
}

do_build() {
	meson _build --prefix="$pkg_prefix" \
		-Diconv=external \
		-Dgtk_doc=false \
		--buildtype release
	ninja -C _build
}

do_install() {
	ninja -C _build install
}

do_after() {
	fix_interpreter "$pkg_prefix/bin/*" core/coreutils bin/env
}
