program="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"
glibc_version="2.34"

pkg_name="native-cross-gcc-base"
pkg_origin="core"
pkg_version="9.4.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="c95da32f440378d7751dd95533186f7fc05ceb4fb65eb5b85234e6299eb9838e"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/native-cross-binutils
	core/native-gmp
	core/native-isl
	core/native-mpfr
	core/native-libmpc
)

# We don't specify a bin directory so that the cross compiler
# from the native-cross-gcc is found
pkg_lib_dirs=(lib)

do_prepare() {
	# Tell gcc not to look under the default `/lib/` and `/usr/lib/` directories
	# for libraries
	#
	# Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/no-sys-dirs.patch
	# shellcheck disable=SC2002
	patch -p1 <"$PLAN_CONTEXT/no-sys-dirs.patch"
}

do_build() {
	mkdir -v build
	pushd build || exit 1
	# IMPORATNT: The --enable-initfini-array configuration option is very important for the built
	# cross compiler to behave correctly and will cause build failures later down the line if it
	# is absent: https://unix.stackexchange.com/questions/648979/lfs-gcc-10-2-0-pass-2-fails-with-source-code-error-in-crtstuff-c
	../configure \
		--prefix="$pkg_prefix" \
		--build="$(../config.guess)" \
		--host="$(../config.guess)" \
		--target="$native_target" \
		--with-sysroot="$pkg_prefix" \
		--with-gmp="$(pkg_path_for native-gmp)" \
		--with-isl="$(pkg_path_for native-isl)" \
		--with-mpfr="$(pkg_path_for native-mpfr)" \
		--with-mpc="$(pkg_path_for native-libmpc)" \
		--with-glibc-version="$glibc_version" \
		--with-newlib \
		--without-headers \
		--enable-default-pie \
		--enable-default-ssp \
		--disable-nls \
		--disable-shared \
		--disable-multilib \
		--disable-decimal-float \
		--disable-threads \
		--disable-libatomic \
		--disable-libgomp \
		--disable-libquadmath \
		--disable-libssp \
		--disable-libvtv \
		--disable-libstdcxx \
		--enable-initfini-array \
		--enable-languages=c,c++
	make -j"$(nproc)"
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	make install

	# IMPORTANT: This is some build hackery to make the bootstrapping process work for us
	# The full gcc limits.h file depends on a file of the same name (limits.h) from glibc.
	# Since we haven't built glibc yet we cannot use the final version of gcc's limits.h to build glibc.
	# To work around this we make a copy of the partial limits.h in a new include folder 'bootstrap-include'
	# We then include this folder prior to the standard gcc search path to make gcc use the partial header
	# when building glibc.

	# Create a copy of the partial limits.h file that we use to compile glibc
	# in a non-standard bootstrap-include folder. We will get this picked up
	# when building glibc by adding extra -isystem flags to the CPPFLAGS
	mkdir -v "$pkg_prefix/bootstrap-include"
	cp -v "$pkg_prefix"/lib/gcc/"$native_target"/$pkg_version/include-fixed/* "$pkg_prefix/bootstrap-include"

	# Create the full limits.h file
	cat ../gcc/limitx.h ../gcc/glimits.h ../gcc/limity.h >"$(dirname "$("$pkg_prefix"/bin/"$native_target"-gcc -print-libgcc-file-name)")"/install-tools/include/limits.h

	# Install the full limits.h file
	"$pkg_prefix"/libexec/gcc/"$native_target"/$pkg_version/install-tools/mkheaders

	# Remove unnecesary include folder created by 'make install'
	rm -rf "$pkg_prefix/include"

	popd || exit 1

}
