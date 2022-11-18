program="gmp"

pkg_name="libgmp-stage1"
pkg_origin="core"
pkg_version="6.2.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GMP is a free library for arbitrary precision arithmetic, operating on signed \
integers, rational numbers, and floating-point numbers.\
"
pkg_upstream_url="https://gmplib.org"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc-stage1
	core/m4-stage0
	core/build-tools-coreutils
	core/build-tools-make
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# default settings of GMP produce libraries optimized for the host processor. \
	# If libraries suitable for processors less capable than the host's CPU are desired, \
	# generic libraries can be created by
	cp -v configfsf.guess config.guess
	cp -v configfsf.sub config.sub
}

do_build() {
	# We disable shared libraries so that when this package is used as a dependency
	# for core/gcc, it will get linked into gcc statically. Thus gcc won't have
	# a runtime dependency back to this library.
	./configure \
		--prefix="$pkg_prefix" \
		--enable-cxx \
		--docdir="$pkg_prefix/share/doc/gmp-6.2.1" \
		--build="aarch64-unknown-linux-gnu" \
		--disable-shared

	make
}

do_check() {
	make check
}

do_install() {
	make install

	# Remove unnecessary files and pkgconfig
	rm -v "${pkg_prefix}/lib/libgmp.la"
	rm -v "${pkg_prefix}/lib/libgmpxx.la"
	rm -rfv "${pkg_prefix}/lib/pkgconfig"
}
