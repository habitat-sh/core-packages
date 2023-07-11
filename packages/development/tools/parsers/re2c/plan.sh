pkg_name="re2c"
pkg_origin="core"
pkg_version="1.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('PDDL-1.0')
pkg_upstream_url="http://re2c.org/"
pkg_description="re2c is a lexer generator for C/C++."
pkg_source="https://github.com/skvadrik/${pkg_name}/releases/download/${pkg_version}/${pkg_name}-${pkg_version}.tar.xz"
pkg_filename="${pkg_name}-${pkg_version}.tar.bz2"
pkg_shasum="f37f25ff760e90088e7d03d1232002c2c2672646d5844fdf8e0d51a5cd75a503"
pkg_deps=(
	core/gcc-libs
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/python
	core/valgrind
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="${pkg_prefix}"
	make -j"$(nproc)"
}

do_check() {
	# The `/usr/bin/env` path is hardcoded in tests, so we'll add a symlink since fix_interpreter won't work.
	for prog in "$(pkg_path_for coreutils)"/bin/*; do
		ln -s "$prog" /usr/bin/"$(basename "$prog")"
	done
	make check
}
