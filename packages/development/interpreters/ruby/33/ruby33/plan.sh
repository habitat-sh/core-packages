pkg_name=ruby33
pkg_origin=core
pkg_major=3.3
pkg_version=3.3.0
pkg_description="A dynamic, open source programming language with a focus on \
  simplicity and productivity. It has an elegant syntax that is natural to \
  read and easy to write."
pkg_license=("Ruby")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://cache.ruby-lang.org/pub/ruby/${pkg_major}/ruby-${pkg_version}.tar.gz
pkg_upstream_url=https://www.ruby-lang.org/en/
pkg_shasum="96518814d9832bece92a85415a819d4893b307db5921ae1f0f751a9a89a56b7d"
pkg_deps=(
	core/bash
	core/coreutils
	core/glibc
	core/gmp
	core/libyaml
	core/libffi
	core/readline
	core/nss-myhostname
	core/openssl
	core/zlib
	
)
pkg_build_deps=(
	core/gcc
	core/git
	core/ruby-stage1
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
	patch -p1 <"$PLAN_CONTEXT/dont-refer-to-build-dir.patch"
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
		--with-baseruby="$(pkg_path_for core/ruby-stage1)/bin/ruby"

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
