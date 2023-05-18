pkg_name="clens"
pkg_origin="core"
pkg_version="0.7.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
clens is a convenience library to port code to different operating systems. \
Operating systems traditionally have different enough APIs that porting code \
is painful. To keep code readable and #ifdef free, clens brings other APIs or \
missing functions into specific OS focus.\
"
pkg_upstream_url="https://sourceforge.net/projects/clens/"
pkg_license=('isc')
pkg_source="https://downloads.sourceforge.net/project/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="064ac9954d38633e2cff6b696fd049dedc3e90b79acffbee1a87754bcf604267"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/libbsd
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# This flag is required for gcc to be able to compile
	# the source with no warnings which stop compilation
	CFLAGS="-Wno-format-truncation ${CFLAGS}"
}

do_build() {
	mkdir -pv obj
	make LOCALBASE="$pkg_prefix"
}

do_install() {
	make LOCALBASE="$pkg_prefix" install
}
