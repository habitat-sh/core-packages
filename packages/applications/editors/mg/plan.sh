pkg_name="mg"
pkg_origin="core"
pkg_version="20230501"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
mg is Micro GNU/emacs, this is a portable version of the mg maintained by the \
OpenBSD team.\
"
pkg_upstream_url="https://github.com/hboetes/mg"
pkg_license=('LicenseRef-Public-Domain')
pkg_source="https://github.com/hboetes/$pkg_name/archive/$pkg_version.tar.gz"
pkg_shasum="e2878feca64067a0c524e456ffba68d8cb69bcdce0943d2f2b69cad06174462e"

pkg_deps=(
	core/glibc
	core/ncurses
	core/libbsd
)
pkg_build_deps=(
	core/binutils
	core/coreutils
	core/gcc
	core/pkg-config
)

pkg_bin_dirs=(bin)

do_prepare() {
	# shellcheck disable=SC2002
	cat "$PLAN_CONTEXT/update-path.patch" |
		sed \
			-e "s,@prefix@,$pkg_prefix,g" \
			-e "s,@pkgconfig@,$(pkg_path_for pkg-config),g" \
			-e "s,@coreutils@,$(pkg_path_for coreutils),g" \
			-e "s,@binutils@,$(pkg_path_for binutils),g" |
		patch -p1
}

do_build() {
	make \
		prefix="$pkg_prefix"
}

do_install() {
	do_default_install

	# Install license file from README
	install -Dm644 README "$pkg_prefix/share/licenses/README"
}
