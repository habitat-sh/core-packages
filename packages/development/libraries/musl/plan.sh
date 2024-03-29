pkg_name="musl"
pkg_origin="core"
pkg_version="1.2.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
musl is a new standard library to power a new generation of Linux-based \
devices. musl is lightweight, fast, simple, free, and strives to be correct \
in the sense of standards-conformance and safety.\
"
pkg_upstream_url="https://musl.libc.org"
pkg_license=('MIT')
pkg_source="https://musl.libc.org/releases/musl-${pkg_version}.tar.gz"
pkg_shasum="9b969322012d796dc23dda27a35866034fa67d8fb67e0e2c45c913c3d43219dd"

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
