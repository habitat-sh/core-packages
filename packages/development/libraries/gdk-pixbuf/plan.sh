pkg_name=gdk-pixbuf
pkg_origin=core
pkg_version="2.42.6"
pkg_description="An image loading library."
pkg_upstream_url="https://developer.gnome.org/gdk-pixbuf/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0')
pkg_source="https://download.gnome.org/sources/${pkg_name}/${pkg_version%.*}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum=c4a6b75b7ed8f58ca48da830b9fa00ed96d668d3ab4b1f723dcf902f78bde77f
pkg_deps=(
	core/coreutils
	core/glib
	core/glibc
	core/jbigkit
	core/libffi
	core/libiconv
	core/libjpeg-turbo
	core/libpng
	core/libtiff
	core/pcre
	core/shared-mime-info
	core/util-linux
	core/xz
	core/zlib
)
pkg_build_deps=(
	core/gcc
	core/make
	core/perl
	core/pkg-config
	core/meson
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
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
	local meson_opts=(
		"--prefix=${pkg_prefix}"
		"-Dbuildtype=release"
		"-Dbuiltin_loaders=none"
		"-Dgio_sniffing=false"
	)
	meson setup _build . "${meson_opts[@]}"
	meson compile -C _build
}

do_install() {
	meson install -C _build
}
