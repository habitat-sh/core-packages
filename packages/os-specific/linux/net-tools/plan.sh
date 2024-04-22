program="net-tools"
pkg_name="net-tools"
pkg_origin="core"
pkg_version="2.10"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0-only')
pkg_source=http://downloads.sourceforge.net/net-tools/"${pkg_name}"-"${pkg_version}".tar.xz
pkg_upstream_url="https://sourceforge.net/projects/net-tools/"
pkg_description="The Net-tools package is a collection of programs for controlling the network subsystem of the Linux kernel."
pkg_shasum=b262435a5241e89bfa51c3cabd5133753952f7a7b7b93f32e08cb9d96f580d69
pkg_deps=(core/glibc)
pkg_build_deps=(core/diffutils core/patch core/make core/gcc core/coreutils)
pkg_bin_dirs=(bin sbin)

do_prepare() {
    #change the /usr/bin/ path to core-utils path in scripts
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_path_for coreutils)/bin/env,g" -i "$f"
	done
}

do_build() {
    yes "" | make -j1
}

do_install() {
    make -j1 install BASEDIR="${pkg_prefix}"
    cp ${CACHE_PATH}/COPYING "${pkg_prefix}"
}