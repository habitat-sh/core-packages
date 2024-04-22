pkg_name="vim"
pkg_origin="core"
pkg_version="9.1.0318"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Vim is a highly configurable text editor built to make creating and changing \
any kind of text very efficient. It is included as "vi" with most UNIX \
systems and with Apple OS X.\
"
pkg_upstream_url="http://www.vim.org/"
pkg_license=('Vim' 'BSD-2-Clause' 'LGPL-2.1-or-later' 'MIT' 'PSF-2.0' 'X11')
pkg_source="http://github.com/${pkg_name}/${pkg_name}/archive/v${pkg_version}.tar.gz"
pkg_shasum="ce650f829458af93a9e4e8cebea9d59e3d59132ade63c38decd6a10ecf3b5f97"
pkg_deps=(
	core/acl
	core/glibc
	core/ncurses
	core/gawk
)
pkg_build_deps=(
	core/autoconf
	core/gcc
	core/shadow
)
pkg_bin_dirs=(bin)

do_prepare() {
	pushd src >/dev/null
	autoconf
	popd >/dev/null

	export CFLAGS="${CFLAGS} -O2"
	build_line "Setting CFLAGS=${CFLAGS}"
}

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--with-compiledby="Habitat, vim release ${pkg_version}" \
		--with-features=huge \
		--enable-acl \
		--with-x=no \
		--disable-gui \
		--enable-multibyte
	make
}

do_check() {
	chown -R hab .
	su hab -c "PATH=$PATH LANG=en_US.UTF-8 make -j1 test &>vim-test.log"
}

do_install() {
	make install

	# Add a `vi` which symlinks to `vim`
	ln -sv vim "${pkg_prefix}/bin/vi"

	# Install license file
	install -Dm644 runtime/doc/uganda.txt "${pkg_prefix}/share/licenses/license.txt"
}
