program="shadow"

pkg_name="shadow"
pkg_origin="core"
pkg_version="4.12.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Password and account management tool suite.
"
pkg_upstream_url="https://github.com/shadow-maint/shadow"
pkg_license=('Artistic-1.0')
pkg_source="https://github.com/shadow-maint/${pkg_name}/releases/download/${pkg_version}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="3d3ec447cfdd11ab5f0486ebc47d15718349d13fea41fc8584568bc118083ccd"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/attr
	core/acl
)

pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_prepare() {
	# Disable the installation of the `groups` program as Coreutils provides a
	# better version.
	#
	# Thanks to:
	# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/shadow.html
	# shellcheck disable=SC201
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

	# Instead of using the default crypt method, use the more secure SHA-512
	# method of password encryption, which also allows passwords longer than 8
	# characters.
	#
	# Thanks to:
	# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/shadow.html
	sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
		-e 's:/var/spool/mail:/var/mail:' \
		-e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
		-i etc/login.defs

}

do_build() {
	./configure --sysconfdir="${pkg_prefix}/etc" \
		--with-group-name-max-length=32

	make
}

do_install() {
	make exec_prefix="${pkg_prefix}" install

	# Move all binaries in `sbin/` into `bin/` as this isn't handled by
	# `./configure`.
	mv "$pkg_prefix/sbin"/* "$pkg_prefix/bin/"
	rm -rf "$pkg_prefix/sbin"
}
