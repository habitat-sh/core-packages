pkg_name="bats"
pkg_origin="core"
pkg_version="1.8.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Bats is a TAP-compliant testing framework for Bash. It provides a simple way \
to verify that the UNIX programs you write behave as expected.\
"
pkg_upstream_url="https://github.com/bats-core/bats-core"
pkg_license=('MIT')
pkg_source="https://github.com/bats-core/bats-core/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="0f2df311a536e625a72bff64c838e67c7b5032e6ea9edcdf32758303062b2f3b"
pkg_dirname="bats-core-${pkg_version}"

pkg_deps=(
	core/bash
	core/coreutils
)

pkg_build_deps=(
	core/procps-ng
	core/util-linux
	core/parallel
)

pkg_bin_dirs=(bin)

do_build() {
	# Replace all occurrences in the codebase of the reliance on `/usr/bin/env`.
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
}

do_check() {
	# Some of the tests expect coreutils binaries like 'mkdir' to be present in 
	# standard locations, so we are going to create symlinks to them.
	for prog in "$(pkg_path_for coreutils)"/bin/*; do
		ln -s "$prog" /bin/"$(basename "$prog")"
	done
	./bin/bats --tap test
}

do_install() {
	./install.sh "$pkg_prefix"
}
