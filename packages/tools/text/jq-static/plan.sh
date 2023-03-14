pkg_name=jq-static
pkg_distname=jq
pkg_origin=core
pkg_version=1.6
pkg_license=('MIT', 'BSD-2-Clause')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/stedolan/$pkg_distname/releases/download/${pkg_distname}-${pkg_version}/jq-1.6.tar.gz"
pkg_upstream_url="https://stedolan.github.io/jq/"
pkg_description="jq is a lightweight and flexible command-line JSON processor."
pkg_shasum=5de8c8e29aaa3fb9cc6b47bb27299f271354ebb72514e3accadc7d38b5bbaa72
pkg_dirname=${pkg_name}-${pkg_version}
pkg_deps=()
pkg_build_deps=(
  core/coreutils
  core/wget
  core/gcc
  core/make
  core/oniguruma
 )
pkg_bin_dirs=(bin)

do_unpack() {
   mkdir -p "${HAB_CACHE_SRC_PATH}"/"${pkg_dirname}"
   tar xzf "${HAB_CACHE_SRC_PATH}"/"${pkg_distname}-${pkg_version}.tar.gz" --strip-components=1 --directory "${HAB_CACHE_SRC_PATH}"/"${pkg_dirname}"
}

do_prepare() {
	LDFLAGS="--static"
}
do_build() {
 ./configure --disable-maintainer-mode "--with-oniguruma=$(pkg_path_for core/oniguruma)"
 make
}

do_install() {
  install -D "$HAB_CACHE_SRC_PATH"/"$pkg_dirname"/"$pkg_distname" "$pkg_prefix"/bin/
}

