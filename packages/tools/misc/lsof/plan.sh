program=lsof
pkg_name="lsof"
pkg_origin="core"
pkg_version="4.99.3"
pkg_license=('lsof')
pkg_source=https://github.com/lsof-org/lsof/releases/download/${pkg_version}/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum="86428a8881b0d1147a52058e853c775b83d794f0da685d549b2bfd07063ed1cd"
pkg_upstream_url="https://people.freebsd.org/~abe/"
pkg_description="lsof - list open files"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_deps=(core/glibc)
pkg_bin_dirs=(bin)
pkg_build_deps=(
  core/coreutils
  core/make 
  core/gcc 
  core/busybox-static 
  core/groff
)
pkg_dirname="lsof-${pkg_version}"

do_build() {
  export DESTDIR="$PREFIX"
  export LSOF_CFLAGS_OVERRIDE=1
  LSOF_INCLUDE="$(pkg_path_for glibc)/include/"
  export LSOF_INCLUDE
  pushd "$SRC_PATH" > /dev/null
  ./configure
  make 
  popd
}

do_install() {
  install -m 0755 "${SRC_PATH}/${pkg_name}" "${PREFIX}/bin"
}

