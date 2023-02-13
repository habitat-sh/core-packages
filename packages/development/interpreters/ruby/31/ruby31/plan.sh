pkg_name=ruby31
pkg_origin=core
pkg_major=3.1
pkg_version=3.1.3
pkg_description="A dynamic, open source programming language with a focus on \
  simplicity and productivity. It has an elegant syntax that is natural to \
  read and easy to write."
pkg_license=("Ruby")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://cache.ruby-lang.org/pub/ruby/${pkg_major}/ruby-${pkg_version}.tar.gz
pkg_upstream_url=https://www.ruby-lang.org/en/
pkg_shasum=5ea498a35f4cd15875200a52dde42b6eb179e1264e17d78732c3a57cd1c6ab9e
pkg_deps=(
    core/glibc 
    core/ncurses 
	  core/zlib 
	  core/openssl 
    core/libyaml 
    core/libffi 
	  core/readline 
	  core/nss-myhostname
)
pkg_build_deps=(
    core/coreutils 
    core/diffutils
	  core/patch 
    core/make 
    core/gcc  
	  core/sed
  )
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/ruby)
pkg_dirname="ruby-$pkg_version"

git update-index --chmod=+x ./tests/test.sh

do_prepare() {
  export CFLAGS="${CFLAGS} -O3 -g -pipe"
  build_line "Setting CFLAGS='$CFLAGS'"

  # Replace all host system env interpreters with our packaged env
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
}

do_build() {
  ./configure \
    --prefix="$pkg_prefix" \
    --enable-shared \
    --disable-install-doc \
    --with-openssl-dir="$(pkg_path_for core/openssl)" \
    --with-libyaml-dir="$(pkg_path_for core/libyaml)"
  
  make
}

do_check() {
  make test
}

do_install() {
  do_default_install
  gem install rb-readline --no-document
}
