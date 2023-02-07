pkg_name="rsync"
pkg_version="3.2.7"
pkg_origin="core"
pkg_license=('GPL-3.0')
pkg_description="An open source utility that provides fast incremental file transfer"
pkg_upstream_url="https://rsync.samba.org/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://download.samba.org/pub/${pkg_name}/src/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="4e7d9d3f6ed10878c58c5fb724a67dacf4b6aac7340b13e488fb2dc41346f2bb"

pkg_deps=(
	core/acl
	core/attr
	core/bash
	core/coreutils
	core/glibc
	core/lz4
	core/openssl
	core/xxhash
	core/zstd
)
pkg_build_deps=(
	core/make
	core/gcc
	core/grep
	core/perl
	core/python
	core/diffutils
)
pkg_bin_dirs=(bin)

do_prepare() {
	# Replace /usr/bin/env with our coreutils env in scripts prior to build
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
}

# The tests may fail inside the studio depending on where your studio
# is hosted as some of the tests (default-acl, hardlinks, xattrs,
# xattrs-hlink) make assumptions about the capabilities of the
# underlying filesystem.
#
# In a boot2docker based studio expect default-acl and hardlinks to
# fail because of the limitations of aufs.
#
# On a machine with selinux, xattrs and xattrs-hlinks may fail because
# of the selinux context information in the extended attributes.
#
do_check() {
	make check
}