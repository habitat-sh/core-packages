program="libjpeg-turbo"

pkg_name="libjpeg-turbo"
pkg_origin="core"
pkg_version="1.5.3"
pkg_description="A faster (using SIMD) libjpeg implementation"
pkg_upstream_url="http://libjpeg-turbo.virtualgl.org/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('IJG' 'BSD-3-Clause' 'Zlib')
pkg_source="https://sourceforge.net/projects/${program}/files/${pkg_version}/${program}-${pkg_version}.tar.gz/download"
pkg_filename=${program}-${pkg_version}.tar.gz
pkg_shasum="b24890e2bb46e12e72a79f7e965f409f4e16466d00e1dd15d93d73ee6b592523"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/make
	core/gcc
	core/file
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# The configure script expects `file` binaries to be in `/usr/bin`
	if [[ ! -r /usr/bin/file ]]; then
		ln -sv "$(pkg_path_for file)/bin/file" /usr/bin/file
		_clean_file=true
	fi
}

do_check() {
	make test
}

do_end() {
	# Clean up
	if [[ -n $_clean_file ]]; then
		rm -fv /usr/bin/file
	fi
}
