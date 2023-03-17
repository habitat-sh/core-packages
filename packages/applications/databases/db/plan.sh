pkg_name="db"
pkg_origin="core"
pkg_version="5.3.28"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Berkeley DB is a family of embedded key-value database libraries providing \
scalable high-performance data management services to applications.\
"
pkg_upstream_url="http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/overview/index.html"
pkg_license=('custom')
# Oracle's official download link for Berkeley DB is now behind a login screen
# Pull from LFS mirrors for now
pkg_source="https://download.oracle.com/berkeley-db/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/make
	core/gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

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
