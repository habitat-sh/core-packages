pkg_name="re2c"
pkg_origin="core"
pkg_version="3.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('PDDL-1.0')
pkg_upstream_url="http://re2c.org/"
pkg_description="re2c is a lexer generator for C/C++."
pkg_source="https://github.com/skvadrik/${pkg_name}/releases/download/${pkg_version}/${pkg_name}-${pkg_version}.tar.xz"
pkg_filename="${pkg_name}-${pkg_version}.tar.bz2"
pkg_shasum="b3babbbb1461e13fe22c630a40c43885efcfbbbb585830c6f4c0d791cf82ba0b"
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
