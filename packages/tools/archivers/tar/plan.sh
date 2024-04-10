program="tar"

pkg_name="tar"
pkg_origin="core"
pkg_version="1.35"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Tar provides the ability to create tar archives, as well as various other \
kinds of manipulation.\
"
pkg_upstream_url="https://www.gnu.org/software/tar/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="14d55e32063ea9526e057fbf35fcabd53378e769787eff7919c3755b02d2b57e"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/acl
	core/attr
	core/bzip2
	core/gzip
	core/lzip
	core/lzop
	core/xz
	core/zstd
)
pkg_build_deps=(
	core/gettext
	core/gcc
	core/shadow
	core/build-tools-util-linux
)
pkg_bin_dirs=(bin)

do_build() {
	FORCE_UNSAFE_CONFIGURE=1 ./configure \
		--prefix="$pkg_prefix"

	make
}

do_check() {
	# make check-full for star tests
	chown -R hab .
	su hab -c "PATH=$PATH FULL_TEST=1 make check"
}
