program="grep"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-grep"
pkg_origin="core"
pkg_version="3.7"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Grep searches one or more input files for lines containing a match to a \
specified pattern. By default, Grep outputs the matching lines.\
"
pkg_upstream_url="https://www.gnu.org/software/grep/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="5c10da312460aec721984d5d83246d24520ec438dd48d7ab5a05dbc0d6d6823c"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/build-tools-glibc
)
pkg_build_deps=(
	core/native-cross-gcc
)
pkg_bin_dirs=(bin)

do_prepare() {
	sed -i "s/echo/#echo/" src/egrep.sh
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--host="$native_target"
	make
}

do_check() {
	make check
}

do_install() {
	make install
}
