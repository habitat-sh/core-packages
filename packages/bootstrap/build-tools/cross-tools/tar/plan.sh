program="tar"

pkg_name="build-tools-tar"
pkg_origin="core"
pkg_version="1.34"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Tar provides the ability to create tar archives, as well as various other \
kinds of manipulation.\
"
pkg_upstream_url="https://www.gnu.org/software/tar/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="03d908cf5768cfe6b7ad588c921c6ed21acabfb2b79b788d1330453507647aed"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-clang
)
pkg_bin_dirs=(bin)

do_prepare() {
	# Fix ownership of the source folder so that config works
	chown -R "$SUDO_USER:$SUDO_GID" .
}

do_build() {
	build_line "Running configure as $SUDO_USER"
	sudo -u "$SUDO_USER" ./configure \
		--prefix="$pkg_prefix"
	make
}

do_check() {
	make check
}
