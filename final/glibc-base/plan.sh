program="glibc"

pkg_name="glibc-base"
pkg_origin="core"
pkg_version="2.36"
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
pkg_shasum="1c959fea240906226062cb4b1e7ebce71a9f0e3c0836c09e7e3423d434fcfe75"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/linux-headers
	core/gcc-stage1
	core/m4-stage0
	core/build-tools-bison
	core/build-tools-python
	core/build-tools-gettext
	core/build-tools-sed
	core/build-tools-perl
	core/build-tools-diffutils
	core/build-tools-patch
	core/build-tools-coreutils
	core/build-tools-gawk
	core/build-tools-texinfo
	core/build-tools-grep
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
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

	# Look for /etc/services and /etc/protocol files in the locations specified by
	# the HAB_ETC_SERVICES and HAB_ETC_PROTOCOLS environment variables breaking the
	# hardcoded dependency and allowing us to update the `iana-etc` package independently
	# of glibc. Thanks to https://github.com/NixOS/nixpkgs/pull/137601 for the solution.
	patch -p1 <"$PLAN_CONTEXT/hab-nss-open-files.patch"

	# We cannot have RPATH set in the glibc binaries
	unset LD_RUN_PATH
	unset LDFLAGS
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
	build_line "Unset CFLAGS, CXXFLAGS, CPPFLAGS, LDFLAGS and LD_RUN_PATH"
}

do_build() {
	mkdir -v build
	pushd build || exit 1

	"../configure" \
		--prefix="$pkg_prefix" \
		--with-headers="$(pkg_path_for linux-headers)/include" \
		--sysconfdir="$pkg_prefix/etc" \
		--enable-kernel=5.4 \
		--enable-stack-protector=strong \
		--disable-werror \
		libc_cv_slibdir="$pkg_prefix"/lib \
		libc_cv_rootsbindir="$pkg_prefix"/bin

	make -j"$(nproc)"

	popd >/dev/null || exit 1
}

do_install() {
	pushd build || exit 1

	# Prevent a `make install` warning of a missing `ld.so.conf`.
	mkdir -p "$pkg_prefix/etc"
	touch "$pkg_prefix/etc/ld.so.conf"

	make install

	mkdir -pv "$pkg_prefix/lib/locale"
	localedef -i POSIX -f UTF-8 C.UTF-8 2>/dev/null || true
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
	localedef -i de_DE -f ISO-8859-1 de_DE
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
	localedef -i de_DE -f UTF-8 de_DE.UTF-8
	localedef -i el_GR -f ISO-8859-7 el_GR
	localedef -i en_GB -f ISO-8859-1 en_GB
	localedef -i en_GB -f UTF-8 en_GB.UTF-8
	localedef -i en_HK -f ISO-8859-1 en_HK
	localedef -i en_PH -f ISO-8859-1 en_PH
	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	localedef -i es_ES -f ISO-8859-15 es_ES@euro
	localedef -i es_MX -f ISO-8859-1 es_MX
	localedef -i fa_IR -f UTF-8 fa_IR
	localedef -i fr_FR -f ISO-8859-1 fr_FR
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
	localedef -i is_IS -f ISO-8859-1 is_IS
	localedef -i is_IS -f UTF-8 is_IS.UTF-8
	localedef -i it_IT -f ISO-8859-1 it_IT
	localedef -i it_IT -f ISO-8859-15 it_IT@euro
	localedef -i it_IT -f UTF-8 it_IT.UTF-8
	localedef -i ja_JP -f EUC-JP ja_JP
	localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2>/dev/null || true
	localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
	localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
	localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
	localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
	localedef -i se_NO -f UTF-8 se_NO.UTF-8
	localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
	localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
	localedef -i zh_CN -f GB18030 zh_CN.GB18030
	localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
	localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

	# Install the configuration file for nscd
	cp -v "../nscd/nscd.conf" "$pkg_prefix/etc/"

	# The /etc/nsswitch.conf tells glibc where to obtain name service
	# information. More information can be found at https://man7.org/linux/man-pages/man5/nsswitch.conf.5.html
	cat >"$pkg_prefix/etc/nsswitch.conf" <<"EOF"
# Begin nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End nsswitch.conf
EOF

	popd || exit 1
}
