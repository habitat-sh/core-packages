pkg_name=node
pkg_origin=core
pkg_version=18.20.4
pkg_description="Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine."
pkg_upstream_url=https://nodejs.org/
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://nodejs.org/dist/v${pkg_version}/node-v${pkg_version}.tar.gz"
pkg_shasum=349259af6821f730bc4ca3a0e6576efc75ba86e546d118629a5b75eb8ebc3a0b
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/python
	core/bash
	core/coreutils

)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_interpreters=(bin/node)
pkg_lib_dirs=(lib)
pkg_dirname="node-v${pkg_version}"

do_prepare() {
	# ./configure has a shebang of #!/usr/bin/env python. Fix it.
	sed -e "s#/usr/bin/env python#$(pkg_path_for python)/bin/python#" -i configure
}

do_build() {
	./configure \
		--prefix "${pkg_prefix}" \
		--dest-cpu "x64" \
		--dest-os "linux"

	make -j"$(nproc)"
}

do_install() {
	do_default_install

	# Node produces a lot of scripts that hardcode `/usr/bin/env`, so we need to
	# fix that everywhere to point directly at the env binary in core/coreutils.
	grep -nrlI '^\#\!.*bin/env' "$pkg_prefix" | while read -r target; do
		sed -e "s|#!.*bin/env|#!$(pkg_path_for coreutils)/bin/env|" -i "$target"
	done
	grep -nrlI '^\#\!.*bin/bash' "$pkg_prefix" | while read -r target; do
		sed -e "s|#!.*bin/bash|#!$(pkg_path_for bash)/bin/bash|" -i "$target"
	done
	grep -nrlI '^\#\!/usr/bin/env' "$pkg_prefix" | while read -r target; do
		sed -e "s#\#\!/usr/bin/env node#\#\!${pkg_prefix}/bin/node#" -i "$target"
		sed -e "s#\#\!/usr/bin/env sh#\#\!$(pkg_path_for bash)/bin/sh#" -i "$target"
		sed -e "s#\#\!/usr/bin/env bash#\#\!$(pkg_path_for bash)/bin/bash#" -i "$target"
		sed -e "s#\#\!/usr/bin/env python#\#\!$(pkg_path_for python)/bin/python#" -i "$target"
	done

	# This script has a hardcoded bare `node` command
	sed -e "s#^\([[:space:]]\)\+node\([[:space:]]\)#\1${pkg_prefix}/bin/node\2#" -i "${pkg_prefix}/lib/node_modules/npm/bin/node-gyp-bin/node-gyp"
}
