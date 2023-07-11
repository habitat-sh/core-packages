pkg_name="expat"
pkg_origin="core"
pkg_version="2.4.6"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Expat is a stream-oriented XML parser library written in C. Expat excels with \
files too large to fit RAM, and where performance and flexibility are crucial.\
"
pkg_upstream_url="https://libexpat.github.io/"
pkg_license=('MIT')
pkg_source="https://github.com/libexpat/libexpat/releases/download/R_${pkg_version//./_}/expat-${pkg_version}.tar.xz"
pkg_shasum="de55794b7a9bc214852fdc075beaaecd854efe1361597e6268ee87946951289b"
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
