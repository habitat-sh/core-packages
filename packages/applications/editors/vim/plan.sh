pkg_name="vim"
pkg_origin="core"
pkg_version="9.0.0984"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Vim is a highly configurable text editor built to make creating and changing \
any kind of text very efficient. It is included as "vi" with most UNIX \
systems and with Apple OS X.\
"
pkg_upstream_url="http://www.vim.org/"
pkg_license=("Vim")
pkg_source="http://github.com/${pkg_name}/${pkg_name}/archive/v${pkg_version}.tar.gz"
pkg_shasum="bbfc59e1862db862e3f641b0871cd1162dc1d2a58330588c6e517dbdf54b133c"
pkg_deps=(
	core/acl
	core/attr
	core/glibc
	core/ncurses
)
pkg_build_deps=(
	core/autoconf
	core/coreutils
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
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
