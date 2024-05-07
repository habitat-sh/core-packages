program="glibc"

pkg_name="glibc"
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

pkg_deps=(
	core/linux-headers
)

pkg_build_deps=(
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

pkg_bin_dirs=(bin)
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
	patch -p1 <"$PLAN_CONTEXT/CVE-2022-39046.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2023-0687.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2023-4911.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2023-6246.patch"

	# 'HAB_LD_LINK_MODE' is used to control the way the habitat linker wrapper adds rpath entries.
	# By setting it to '', we instruct the linker wrapper to add an rpath entry only if a library
	# is going to be linked into the resulting binary or library.
	# This setting is crucial when dealing with certain glibc ELF binaries/libraries. These are expected
	# not to have a DT_RUNPATH entry, and using the '' mode ensures this expectation is met.
	export HAB_LD_LINK_MODE="minimal"

	# We cannot have RPATH set in the glibc binaries
	# unset LD_RUN_PATH
	unset LDFLAGS
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS

	build_line "Unsetting LDFLAGS"
	build_line "Unsetting CFLAGS"
	build_line "Unsetting CXXFLAGS"
	build_line "Unsetting CPPFLAGS"
	build_line "Setting HAB_LD_LINK_MODE=${HAB_LD_LINK_MODE}"
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
		--enable-static-pie \
		--disable-werror \
		libc_cv_slibdir="$pkg_prefix"/lib \
		libc_cv_rootsbindir="$pkg_prefix"/bin

	make -j "$(nproc)" --output-sync

	popd >/dev/null || exit 1
}

do_install() {
	pushd build || exit 1

	# Prevent a `make install` warning of a missing `ld.so.conf`.
	mkdir -p "$pkg_prefix/etc"
	touch "$pkg_prefix/etc/ld.so.conf"
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

do_strip() {
	return 0
}
