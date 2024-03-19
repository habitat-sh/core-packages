pkg_name="db"
pkg_origin="core"
pkg_version="5.3.28"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Berkeley DB is a family of embedded key-value database libraries providing \
scalable high-performance data management services to applications.\
"
pkg_upstream_url="http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/overview/index.html"
pkg_license=('Sleepycat')
# Oracle's official download link for Berkeley DB is now behind a login screen
# Pull from LFS mirrors for now
pkg_source="https://download.oracle.com/berkeley-db/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628"

pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_prepare() {
	# This patch resolves a type conflict error with GCC 9 and GLIBC 2.34 when compiling Berkeley DB.
	# The issue arises due to a mismatch between the expected and actual signatures of the built-in
	# function `__atomic_compare_exchange`. Berkeley DB was using this function in a way that's
	# incompatible with these newer compiler and library versions.
	#
	# To resolve this, the patch changes the function name from `__atomic_compare_exchange` to
	# `__atomic_compare_exchange_db` in two locations within `atomic.h`.
	#
	# The first change is made in the `#define` macro for `atomic_compare_exchange`, which alters
	# the macro to call the newly-named `__atomic_compare_exchange_db` function.
	#
	# The second change is made in the function declaration itself, renaming
	# `__atomic_compare_exchange` to `__atomic_compare_exchange_db`.
	#
	# As a result, the built-in `__atomic_compare_exchange` function and the function within
	# Berkeley DB no longer conflict, allowing the code to compile successfully with GCC 9
	# and GLIBC 2.34.

	# https://git.archlinux.org/svntogit/packages.git/plain/trunk/atomic.patch?h=packages/db
	patch -p0 <"$PLAN_CONTEXT"/patches/atomic.patch
}

do_build() {
	pushd build_unix >/dev/null
	../dist/configure \
		--prefix="${pkg_prefix}" \
		--build="${pkg_target%%-*}"-unknown-linux-gnu \
		--enable-compat185 \
		--enable-cxx \
		--enable-dbm \
		--enable-stl
	make LIBSO_LIBS=-lpthread -j"$(nproc)"
	popd >/dev/null
}

do_install() {
	pushd build_unix >/dev/null
	do_default_install
	make uninstall_docs
	rm -rf ${pkg_prefix}/docs
	popd >/dev/null

	# Install license file
	install -Dm644 LICENSE "${pkg_prefix}/share/licenses/LICENSE"
}
