pkg_name="musl"
pkg_origin="core"
pkg_version="1.2.5"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
musl is a new standard library to power a new generation of Linux-based \
devices. musl is lightweight, fast, simple, free, and strives to be correct \
in the sense of standards-conformance and safety.\
"
pkg_upstream_url="https://musl.libc.org"
pkg_license=('MIT')
pkg_source="https://git.musl-libc.org/cgit/musl/snapshot/musl-${pkg_version}.tar.gz"
pkg_shasum="83ff394502d1c334b040ea9bc66ec48bba453585e25b05f4bde3741d8245d883"

pkg_build_deps=(
	core/gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	stack_size="2097152"
	build_line "Setting default stack size to '$stack_size' from default '81920'"
	sed \
		-i "s/#define DEFAULT_STACK_SIZE .*/#define DEFAULT_STACK_SIZE $stack_size/" \
		src/internal/pthread_impl.h
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--syslibdir="$pkg_prefix/lib"

	make
}

do_install() {
	do_default_install

	# Install license
	install -Dm0644 COPYRIGHT "$pkg_prefix/share/licenses/COPYRIGHT"
}
