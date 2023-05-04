program="glibc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-glibc"
pkg_origin="core"
pkg_version="2.34"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU C Library project provides the core libraries for the GNU system and \
GNU/Linux systems, as well as many other systems that use Linux as the \
kernel. These libraries provide critical APIs including ISO C11, \
POSIX.1-2008, BSD, OS-specific APIs and more. These APIs include such \
foundational facilities as open, read, write, malloc, printf, getaddrinfo, \
dlopen, pthread_create, crypt, login, exit and more.\
"
pkg_upstream_url="https://www.gnu.org/software/libc"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="44d26a1fe20b8853a48f470ead01e4279e869ac149b195dda4e44a195d981ab2"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/build-tools-linux-headers
)

pkg_build_deps=(
	core/native-cross-binutils
	core/native-cross-gcc-base
)

pkg_bin_dirs=(bin sbin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# We put the native-cross-binutils and native-cross-gcc-base bin directories first on our path to ensure
	# that our wrapped linker gets picked up by the cross compiler as 'ld'. At this stage we cannot wrap the compiler
	# as our cc-wrapper.sh script requires glibc's final path.
	PATH="$(pkg_path_for native-cross-binutils)/$native_target/bin:$(pkg_path_for native-cross-gcc-base)/bin:${PATH}"
	build_line "Updated PATH=${PATH}"

	# Don't use the system's `/etc/ld.so.cache` and `/etc/ld.so.preload`, but
	# rather the version under `$pkg_prefix/etc`.
	#
	# Thanks to https://github.com/NixOS/nixpkgs/blob/54fc2db/pkgs/development/libraries/glibc/dont-use-system-ld-so-cache.patch
	# and to https://github.com/NixOS/nixpkgs/blob/dac591a/pkgs/development/libraries/glibc/dont-use-system-ld-so-preload.patch
	# shellcheck disable=SC2002
	cat "$PLAN_CONTEXT/dont-use-system-ld-so-preload.patch" |
		sed "s,@PREFIX@,$pkg_prefix,g" |
		patch -p1

	patch -p1 <"$PLAN_CONTEXT/dont-use-system-ld-so-cache.patch"

	# Add flags to ensure we pick up the partial limits.h created in the core/native-cross-gcc-base package
	CPPFLAGS="${CPPFLAGS} -isystem $(pkg_path_for native-cross-gcc-base)/bootstrap-include"
}

do_build() {
	mkdir -v build
	pushd build || exit 1

	"../configure" \
		--prefix="$pkg_prefix" \
		--build="$(../scripts/config.guess)" \
		--host="$native_target" \
		--with-headers="$(pkg_path_for build-tools-linux-headers)/include" \
		--sysconfdir="$pkg_prefix/etc" \
		--enable-kernel=3.2 \
		libc_cv_slibdir="$pkg_prefix"/lib \
		libc_cv_rootsbindir="$pkg_prefix"/bin

	make -j"$(nproc)"

	popd >/dev/null || exit 1
}

do_install() {
	pushd build || exit 1
	make install

	# Remove unneccessary binaries
	rm -v "${pkg_prefix}"/bin/{mtrace,sotruss,xtrace,sln}

	mkdir -pv "$pkg_prefix/lib/locale"
	# Ensure we use the correct localedef as there may be multiple
	# glibcs in the path at this point
	local localedef_bin="${pkg_prefix}/bin/localedef"
	$localedef_bin -i POSIX -f UTF-8 C.UTF-8 2>/dev/null || true
	$localedef_bin -i cs_CZ -f UTF-8 cs_CZ.UTF-8
	$localedef_bin -i de_DE -f ISO-8859-1 de_DE
	$localedef_bin -i de_DE@euro -f ISO-8859-15 de_DE@euro
	$localedef_bin -i de_DE -f UTF-8 de_DE.UTF-8
	$localedef_bin -i el_GR -f ISO-8859-7 el_GR
	$localedef_bin -i en_GB -f ISO-8859-1 en_GB
	$localedef_bin -i en_GB -f UTF-8 en_GB.UTF-8
	$localedef_bin -i en_HK -f ISO-8859-1 en_HK
	$localedef_bin -i en_PH -f ISO-8859-1 en_PH
	$localedef_bin -i en_US -f ISO-8859-1 en_US
	$localedef_bin -i en_US -f UTF-8 en_US.UTF-8
	$localedef_bin -i es_ES -f ISO-8859-15 es_ES@euro
	$localedef_bin -i es_MX -f ISO-8859-1 es_MX
	$localedef_bin -i fa_IR -f UTF-8 fa_IR
	$localedef_bin -i fr_FR -f ISO-8859-1 fr_FR
	$localedef_bin -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	$localedef_bin -i fr_FR -f UTF-8 fr_FR.UTF-8
	$localedef_bin -i is_IS -f ISO-8859-1 is_IS
	$localedef_bin -i is_IS -f UTF-8 is_IS.UTF-8
	$localedef_bin -i it_IT -f ISO-8859-1 it_IT
	$localedef_bin -i it_IT -f ISO-8859-15 it_IT@euro
	$localedef_bin -i it_IT -f UTF-8 it_IT.UTF-8
	$localedef_bin -i ja_JP -f EUC-JP ja_JP
	$localedef_bin -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2>/dev/null || true
	$localedef_bin -i ja_JP -f UTF-8 ja_JP.UTF-8
	$localedef_bin -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
	$localedef_bin -i ru_RU -f KOI8-R ru_RU.KOI8-R
	$localedef_bin -i ru_RU -f UTF-8 ru_RU.UTF-8
	$localedef_bin -i se_NO -f UTF-8 se_NO.UTF-8
	$localedef_bin -i ta_IN -f UTF-8 ta_IN.UTF-8
	$localedef_bin -i tr_TR -f UTF-8 tr_TR.UTF-8
	$localedef_bin -i zh_CN -f GB18030 zh_CN.GB18030
	$localedef_bin -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
	$localedef_bin -i zh_TW -f UTF-8 zh_TW.UTF-8

	popd || exit 1

}

do_strip() {
	return 0
}
