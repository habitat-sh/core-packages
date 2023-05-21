pkg_name=ruby31
pkg_origin=core
pkg_major="3.1"
pkg_version="3.1.2"
pkg_description="A dynamic, open source programming language with a focus on \
  simplicity and productivity. It has an elegant syntax that is natural to \
  read and easy to write."
pkg_license=("Ruby")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://cache.ruby-lang.org/pub/ruby/${pkg_major}/ruby-${pkg_version}.tar.gz
pkg_upstream_url=https://www.ruby-lang.org/en/
pkg_shasum="61843112389f02b735428b53bb64cf988ad9fb81858b8248e22e57336f24a83e"
pkg_deps=(
	core/bash
	core/coreutils
	core/glibc
	core/gmp
	core/libyaml
	core/libffi
	core/readline
	core/ncurses
	core/nss-myhostname
	core/openssl
	core/zlib
)
pkg_build_deps=(
	core/gcc
	core/git
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/ruby)
pkg_dirname="ruby-$pkg_version"

do_prepare() {
	export CFLAGS="${CFLAGS} -O3 -g -pipe"

	# Replace all host system env interpreters with our packaged env
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done

	build_line "Setting CFLAGS='$CFLAGS'"
}

do_build() {
	mkdir build
	pushd build || exit 1
	../configure \
		--prefix="$pkg_prefix" \
		--enable-shared \
		--disable-install-doc \
		--with-openssl-dir="$(pkg_path_for core/openssl)" \
		--with-libyaml-dir="$(pkg_path_for core/libyaml)" \
		--without-baseruby

	make -j"$(nproc)"
	popd || exit 1
}

do_check() {
	pushd build || exit 1
	make test
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	make install

	local gem_makefiles
	# Remove unnecessary external intermediate files created by gems
	gem_makefiles=$(find "$pkg_prefix"/lib/ruby/gems -name Makefile)
	for makefile in $gem_makefiles; do
		make -C "$(dirname "$makefile")" distclean
	done
	# Delete gem build logs
	find "$pkg_prefix"/lib/ruby/gems \( -name gem_make.out -o -name mkmf.log \) -delete
	popd || exit 1
}
