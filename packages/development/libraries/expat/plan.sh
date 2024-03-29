pkg_name="expat"
pkg_origin="core"
pkg_version="2.6.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Expat is a stream-oriented XML parser library written in C. Expat excels with \
files too large to fit RAM, and where performance and flexibility are crucial.\
"
pkg_upstream_url="https://libexpat.github.io/"
pkg_license=('MIT')
pkg_source="https://downloads.sourceforge.net/project/${pkg_name}/${pkg_name}/${pkg_version}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="d4cf38d26e21a56654ffe4acd9cd5481164619626802328506a2869afab29ab3"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/coreutils
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_check() {
	# Remove shebang line containing `/usr/bin/env` in test helper
	for file in run.sh test-driver-wrapper.sh; do
		sed -e "s,/usr/bin/env,$(pkg_path_for coreutils)/bin/env,g" -i "$file"
	done

	make check
}

do_install() {
	do_default_install

	# Install license file
	install -Dm644 COPYING "$pkgdir/share/licenses/COPYING"
}
