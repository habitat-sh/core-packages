pkg_name="bats"
pkg_origin="core"
pkg_version="0.4.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Bats is a TAP-compliant testing framework for Bash. It provides a simple way \
to verify that the UNIX programs you write behave as expected.\
"
pkg_upstream_url="https://github.com/bats-core/bats-core"
pkg_license=('MIT')
pkg_source="https://github.com/sstephenson/bats/archive/v$pkg_version.tar.gz"
pkg_shasum="480d8d64f1681eee78d1002527f3f06e1ac01e173b761bc73d0cf33f4dc1d8d7"
pkg_dirname="bats-${pkg_version}"

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
