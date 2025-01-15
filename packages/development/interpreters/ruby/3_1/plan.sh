pkg_name=ruby3_1
pkg_origin=core
pkg_major=3.1
pkg_version=3.1.6
pkg_description="A dynamic, open source programming language with a focus on \
  simplicity and productivity. It has an elegant syntax that is natural to \
  read and easy to write."
pkg_license=("Ruby")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://cache.ruby-lang.org/pub/ruby/${pkg_major}/ruby-${pkg_version}.tar.gz
pkg_upstream_url=https://www.ruby-lang.org/en/
pkg_shasum=0d0dafb859e76763432571a3109d1537d976266be3083445651dc68deed25c22
pkg_deps=(
	core/bash
	core/coreutils
	core/gcc
	core/glibc
	core/gmp
	core/libyaml
	core/libffi
	core/readline
	core/nss-myhostname
	core/openssl
	core/zlib
        core/libarchive
)
pkg_build_deps=(
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
        --with-openssl-lib="$(pkg_path_for core/openssl)/lib64" \
        --with-openssl-include="$(pkg_path_for core/openssl)/include" \
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
        
        # Below gems are required for Infra-client.
        gem install ffi -v "1.16.3" --no-document
        gem install ffi-libarchive -v "1.1.14" --no-document
}
