program="shadow"
pkg_name="build-tools-shadow"
pkg_origin="core"
pkg_version="4.12.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Password and account management tool suite."
pkg_upstream_url="https://github.com/shadow-maint/shadow"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://github.com/shadow-maint/${program}/releases/download/${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="3d3ec447cfdd11ab5f0486ebc47d15718349d13fea41fc8584568bc118083ccd"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_prepare(){
	#Disable the installation of the groups program and its man pages, as Coreutils provides a better version
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

	#Instead of using the default crypt method, use the more secure SHA-512
	#change obsolete /var/spool/mail location by default to the /var/mail location 
	sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
		-e 's:/var/spool/mail:/var/mail:' \
		-e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
		-i etc/login.defs
}

do_build() {
	#touch "${pkg_prefix}"/bin/passwd

	./configure --sysconfdir="${pkg_prefix}"/etc \
		--disable-static \
		--with-group-name-max-length=32

    make
}

do_install() {
	make exec_prefix="${pkg_prefix}" install

	#Move all binaries from sbin/ into bin/
	mv "$pkg_prefix/sbin"/* "$pkg_prefix/bin/"
	rm -rf "$pkg_prefix/sbin"
}
