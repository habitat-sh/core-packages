pkg_name=node16
pkg_origin=core
pkg_version=16.13.1
pkg_description="Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine."
pkg_upstream_url=https://nodejs.org/
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://nodejs.org/dist/v${pkg_version}/node-v${pkg_version}.tar.gz"
pkg_shasum=34b23965457fb08a8c62f81e8faf74ea60587cda6fa898e5d030211f5f374cb6
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/python
	core/bash
	core/coreutils
)
pkg_build_deps=(
	core/gcc
	core/grep
	core/make
	core/which
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

	# Node produces a lot of scripts, we need to fix all their interpreters
	grep -nrlI '^\#\!.*bin/env' "$pkg_prefix" | while read -r target; do
		sed -e "s|#!.*bin/env|#!$(pkg_path_for coreutils)/bin/env|" -i "$target"
	done
	grep -nrlI '^\#\!.*bin/python' "$pkg_prefix" | while read -r target; do
		sed -e "s|#!.*bin/python|#!$(pkg_path_for python2)/bin/python|" -i "$target"
	done
	grep -nrlI '^\#\!.*bin/bash' "$pkg_prefix" | while read -r target; do
		sed -e "s|#!.*bin/bash|#!$(pkg_path_for bash)/bin/bash|" -i "$target"
	done
	grep -nrlI '^\#\!.*bin/node' "$pkg_prefix" | while read -r target; do
		sed -e "s|#!.*bin/node|#!${pkg_prefix}/bin/env|" -i "$target"
	done

	# This script has a hardcoded bare `node` command
	sed -e "s#^\([[:space:]]\)\+node\([[:space:]]\)#\1${pkg_prefix}/bin/node\2#" -i "${pkg_prefix}/lib/node_modules/npm/bin/node-gyp-bin/node-gyp"
}
