pkg_name="util-linux"
pkg_origin="core"
pkg_version="2.38.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Miscellaneous system utilities for Linux"
pkg_upstream_url="https://www.kernel.org/pub/linux/utils/util-linux"
# https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/tree/README.licensing
pkg_license=("GPL-2.0-only" "GPL-2.0-or-later" "LGPL-2.1-or-later" "GPL-3.0-or-later" "BSD-2-Clause" "BSD-3-Clause" "BSD-4-Clause-UC")
pkg_source="https://www.kernel.org/pub/linux/utils/${pkg_name}/v${pkg_version%.?}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="60492a19b44e6cf9a3ddff68325b333b8b52b6c59ce3ebd6a0ecaa4c5117e84f"
pkg_deps=(
	core/glibc
	core/zlib
	core/ncurses
	core/readline
	core/file
)
pkg_build_deps=(
	core/bison
	core/gettext
	core/gcc
	core/pkg-config
	core/build-tools-python
	core/shadow
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--sbindir="$pkg_prefix/bin" \
		--localstatedir="$pkg_svc_var_path/run" \
		--enable-nls \
		--enable-write \
		--disable-use-tty-group \
		--without-slang \
		--without-systemd \
		--without-systemdsystemunitdir \
		--disable-chfn-chsh \
		--disable-login \
		--disable-nologin \
		--disable-su \
		--disable-setpriv \
		--disable-runuser
	make
}

do_check() {
	# Change ownership of the folder to the hab user so that tests can compile
	chown -R hab .

	# Compile and run the expensive tests as the hab user
	su hab -c "PATH=$PATH make -k check"
}

do_install() {
	make install usrsbin_execdir="$pkg_prefix/bin"
}
