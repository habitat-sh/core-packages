pkg_name="vim"
pkg_origin="core"
pkg_version="8.2.2825"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Vim is a highly configurable text editor built to make creating and changing \
any kind of text very efficient. It is included as "vi" with most UNIX \
systems and with Apple OS X.\
"
pkg_upstream_url="http://www.vim.org/"
pkg_license=("Vim")
pkg_source="http://github.com/${pkg_name}/${pkg_name}/archive/v${pkg_version}.tar.gz"
pkg_shasum="c75acdac8b80e664666663d3429efe1eb25be7f13db0bd3697a2d2a78dd1bb66"
pkg_deps=(
	core/acl
	core/glibc
	core/ncurses
	core/coreutils
	core/perl
	core/python
	core/gawk
)
pkg_build_deps=(
	core/autoconf
	core/gcc
	core/shadow
)
pkg_bin_dirs=(bin)

do_prepare() {
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
	# fix_interpreter "$pkg_prefix/share/vim/vim90/**/*" core/coreutils bin/env
	# sed -e "s,/usr/bin/python,$(pkg_path_for core/coreutils)/bin/env python3,g" -i "$pkg_prefix/share/vim/vim90/tools/demoserver.py"
}
