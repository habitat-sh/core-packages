pkg_name="gcc-libs-stage1"
pkg_origin="core"
pkg_version="9.4.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Runtime libraries shipped by GCC."
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')

pkg_lib_dirs=(lib)

pkg_deps=(
	core/glibc
)

pkg_build_deps=(
	core/gcc-stage1/"${pkg_version}"
	core/build-tools-patchelf
)

do_install() {
	local gcc
	local libc

	# We link against the newly built glibc, this should be ok
	# since the glibc-stage0 and glibc packages are the same version
	gcc="$(pkg_path_for gcc-stage1)"
	libc="$(pkg_path_for glibc)"

	mkdir -pv "$pkg_prefix/lib"

	cp -av "${gcc}/lib64"/* "$pkg_prefix/lib"/
	rm -fv "$pkg_prefix/lib"/*.spec "$pkg_prefix/lib"/*.py

	# Due to the copy-from-package trick above, the resulting `RUNPATH` entries
	# have more path entries than are actually being used (for mpfr, libmpc,
	# etc), so we'll use `patchelf` trim these unused path entries for each
	# shared library.
	find "$pkg_prefix/lib" \
		-type f \
		-name '*.so.*' \
		-exec patchelf --set-rpath "${libc}/lib:$pkg_prefix/lib" {} \;
	find "$pkg_prefix/lib" \
		-type f \
		-name '*.so.*' \
		-exec patchelf --shrink-rpath {} \;
}

do_build() {
	return 0
}

do_strip() {
	return 0
}
