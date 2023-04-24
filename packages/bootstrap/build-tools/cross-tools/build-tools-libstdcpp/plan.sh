program="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-libstdcpp"
pkg_origin="core"
pkg_version="12.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/build-tools-glibc
	core/build-tools-linux-headers
)
pkg_build_deps=(
	core/native-cross-binutils
	core/native-cross-gcc-base
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	PATH="$(pkg_path_for native-cross-binutils)/$native_target/bin:$(pkg_path_for native-cross-gcc-base)/bin:${PATH}"
	build_line "Updated PATH=${PATH}"

	case $pkg_target in
	aarch64-linux)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-linux)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-aarch64.so.1"
		;;
	esac

	# Specify the dynamic linker and to point to our glibc
	LDFLAGS="${LDFLAGS} -Wl,--dynamic-linker=$dynamic_linker"
	build_line "Setting LDFLAGS=$LDFLAGS"
	# Ensure that the cross linker 'ld' finds the crt{i,n,1}.o files in our glibc package
	CFLAGS="${CFLAGS} -B$(pkg_path_for build-tools-glibc)/lib"
	CXXFLAGS="${CXXFLAGS} -B$(pkg_path_for build-tools-glibc)/lib"

	build_line "Setting CFLAGS=$CFLAGS"
}

do_build() {
	mkdir -v build
	pushd build || exit 1
	../libstdc++-v3/configure \
		--prefix="$pkg_prefix" \
		--build="$(../config.guess)" \
		--host="$native_target" \
		--disable-multilib \
		--disable-nls \
		--disable-libstdcxx-pch \
		--with-gxx-include-dir="${pkg_prefix}/include/c++/${pkg_version}"
	make -j"$(nproc)"
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	make install
	rm -v "${pkg_prefix:?}"/lib64/lib{stdc++,stdc++fs,supc++}.la
	# Symlink lib64 to lib
	rm -rfv "${pkg_prefix:?}/lib"
	ln -sv ./lib64 "$pkg_prefix/lib"
	popd || exit 1
}
