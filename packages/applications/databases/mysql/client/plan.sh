pkg_name=mysql-client
pkg_origin=core
pkg_version="8.4.0"
pkg_description="MySQL Client Tools"
pkg_upstream_url=https://www.mysql.com/
pkg_license=('GPL-2.0')
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_source="https://downloads.mysql.com/archives/get/p/23/file/mysql-${pkg_version}.tar.gz"
pkg_shasum="47a5433fcdd639db836b99e1b5459c2b813cbdad23ff2b5dd4ad27f792ba918e"
pkg_dirname="mysql-${pkg_version}"

pkg_deps=(
	core/gcc-libs
	core/glibc
	core/ncurses
	core/openssl
)
pkg_build_deps=(
	core/boost
	core/cmake
	core/gcc
	core/make
	core/patchelf
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	mkdir builddir
	pushd builddir || exit 1

	cmake ../ \
		-DLOCAL_BOOST_DIR="$(pkg_path_for core/boost)" \
		-DBOOST_INCLUDE_DIR="$(pkg_path_for core/boost)"/include \
		-DWITH_BOOST="$(pkg_path_for core/boost)" \
		-DCURSES_LIBRARY="$(pkg_path_for core/ncurses)/lib/libcurses.so" \
		-DCURSES_INCLUDE_PATH="$(pkg_path_for core/ncurses)/include" \
		-DWITH_SSL=yes \
		-DOPENSSL_ROOT_DIR="$(pkg_path_for core/openssl)" \
		-DOPENSSL_INCLUDE_DIR="$(pkg_path_for core/openssl)/include" \
		-DOPENSSL_LIBRARY="$(pkg_path_for core/openssl)/lib/libssl.so" \
		-DCRYPTO_LIBRARY="$(pkg_path_for core/openssl)/lib/libcrypto.so" \
		-DRESOLV_LIBRARY="$(pkg_path_for core/glibc)/lib/libresolv.so" \
		-DWITHOUT_SERVER:BOOL=ON \
		-DCMAKE_INSTALL_PREFIX="$pkg_prefix"
	make --jobs="$(nproc)"

	popd || exit 1
}

do_install() {
	pushd builddir || exit 1

	make install

	find "$pkg_prefix"/bin -type f -executable -exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;
	find "$pkg_prefix"/bin -type f -executable -exec patchelf --shrink-rpath {} \;
	patchelf --shrink-rpath ${pkg_prefix}/lib/libmysqlclient.so.24.0.0

	popd || exit 1
}

do_check() {
	ctest
}
