pkg_name="jbigkit"
pkg_origin="core"
pkg_version="2.1"
pkg_description="An implementation of the JBIG1 data compression standard"
pkg_upstream_url="http://www.cl.cam.ac.uk/~mgk25/jbigkit/"
pkg_license=('GPL-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://www.cl.cam.ac.uk/~mgk25/jbigkit/download/jbigkit-${pkg_version}.tar.gz"
pkg_shasum="de7106b6bfaf495d6865c7dd7ac6ca1381bd12e0d81405ea81e7f2167263d932"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_prepare() {
	# Unset these flags as they override the ones inside the make file
	unset CPPFLAGS
	unset CFLAGS
	unset CXXFLAGS
}

do_build() {
	make
}

do_check() {
	make test
}

do_install() {
	install -p -m0644 libjbig/libjbig.a "${pkg_prefix}/lib"
	install -p -m0644 libjbig/libjbig85.a "${pkg_prefix}/lib"
	install -p -m0644 libjbig/jbig.h "${pkg_prefix}/include"
	install -p -m0644 libjbig/jbig85.h "${pkg_prefix}/include"
	install -p -m0644 libjbig/jbig_ar.h "${pkg_prefix}/include"
	install -p -m0755 pbmtools/jbgtopbm "${pkg_prefix}/bin"
	install -p -m0755 pbmtools/jbgtopbm85 "${pkg_prefix}/bin"
	install -p -m0755 pbmtools/pbmtojbg "${pkg_prefix}/bin"
	install -p -m0755 pbmtools/pbmtojbg85 "${pkg_prefix}/bin"
}
