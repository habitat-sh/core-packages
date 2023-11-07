pkg_name=atk
pkg_origin=core
pkg_version=2.28.1
pkg_description="Library for a set of interfaces providing accessibility."
pkg_upstream_url=https://developer.gnome.org/atk/
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("LGPL-2.0-or-later")
pkg_source="https://download.gnome.org/sources/${pkg_name}/${pkg_version%.*}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum=cd3a1ea6ecc268a2497f0cd018e970860de24a6d42086919d6bf6c8e8d53f4fc
pkg_deps=(
	core/glib
	core/glibc
)
pkg_build_deps=(
	core/libffi
	core/libiconv
	core/pcre
	core/file
	core/diffutils
	core/gcc
	core/gettext
	core/make
	core/perl
	core/pkg-config
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
    if [[ ! -r /usr/bin/file ]]; then
        ln -sv "$(pkg_path_for file)/bin/file" /usr/bin/file
        _clean_file=true
    fi
}

do_end() {
    if [[ -n "$_clean_file" ]]; then
        rm -fv /usr/bin/file
    fi
}