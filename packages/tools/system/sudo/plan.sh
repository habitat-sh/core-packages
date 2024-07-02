pkg_name="sudo"
pkg_origin=core
pkg_version="1.9.15p5"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Execute a command as another user"
pkg_upstream_url=https://www.sudo.ws/
pkg_license=('BSD-2-Clause' 'BSD-3-Clause' 'BSD-Source-Code' 'Zlib' 'ISC')
pkg_source="https://www.sudo.ws/dist/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="558d10b9a1991fb3b9fa7fa7b07ec4405b7aefb5b3cb0b0871dbc81e3a88e558"
pkg_build_deps=(
  core/diffutils
  core/file
  core/gcc
  core/make
)
pkg_deps=(
  core/glibc
	core/coreutils
	core/vim
)
pkg_bin_dirs=(
  bin
  sbin
)
pkg_include_dirs=(include)

do_prepare() {
  if [[ ! -r /usr/bin/file ]]; then
    ln -sv "$(pkg_path_for file)/bin/file" /usr/bin/file
    _clean_file=true
  fi

  # Export variables to the direct path of executables
  MVPROG="$(pkg_path_for coreutils)/bin/mv"
  export MVPROG
  VIPROG="$(pkg_path_for vim)/bin/vi"
  export VIPROG
}

do_build() {
  ./configure --prefix="${pkg_prefix}" --with-editor="${VIPROG}" --with-env-editor
  make
}

do_check() {
  # Due to how file permissions are preserved during packaging, we must
  # set a particular file to be owned by root for the `testsudoers/test3`
  # regression test, which compares sudo permissions against a file with
  # root ownership.
  chown root:root plugins/sudoers/regress/testsudoers/test3.d/root
  make check
}

do_end() {
  if [[ -n "$_clean_file" ]]; then
    rm -fv /usr/bin/file
  fi
}
