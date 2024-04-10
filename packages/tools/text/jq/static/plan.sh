program=jq

pkg_name=jq-static
pkg_origin=core
pkg_version="1.7.1"
pkg_license=('MIT' 'BSD-2-Clause' ' ICU')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/jqlang/jq/archive/refs/tags/${program}-${pkg_version}.tar.gz"
pkg_upstream_url="https://github.com/jqlang/jq"
pkg_description="jq is a lightweight and flexible command-line JSON processor."
pkg_shasum="fc75b1824aba7a954ef0886371d951c3bf4b6e0a921d1aefc553f309702d6ed1"
pkg_dirname=${program}-${pkg_version}

pkg_build_deps=(
	core/wget
	core/gcc
	core/oniguruma
	core/autoconf
	core/automake
	core/libtool
)
pkg_bin_dirs=(bin)

do_unpack() {
	do_default_unpack

	mv jq-${pkg_dirname} ${pkg_dirname}
}

do_prepare() {
	export ACLOCAL_PATH="$(pkg_path_for libtool)/share/aclocal"
	#LDFLAGS="-all-static"
}

do_build() {
	autoreconf -i
	./configure --prefix="${pkg_prefix}" --disable-maintainer-mode "--with-oniguruma=$(pkg_path_for core/oniguruma)"
	make -j"$(nproc)"
}

do_install() {
	install -D "$HAB_CACHE_SRC_PATH"/"$pkg_dirname"/"$program" "$pkg_prefix"/bin/
}