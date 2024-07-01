pkg_name=node
pkg_origin=core
pkg_version=18.12.1
pkg_description="Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine."
pkg_upstream_url=https://nodejs.org/
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://nodejs.org/dist/v${pkg_version}/node-v${pkg_version}.tar.gz"
pkg_shasum=ba8174dda00d5b90943f37c6a180a1d37c861d91e04a4cb38dc1c0c74981c186
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
	local dest_cpu
        local dest_os
        case $pkg_target in
        aarch64-linux)
                dest_cpu="arm64"
                dest_os="linux"
                ;;
        x86_64-linux)
                dest_cpu="x64"
                dest_os="linux"
                ;;
        esac
        ./configure \
                --prefix "${pkg_prefix}" \
                --dest-cpu "${dest_cpu}" \
                --dest-os "${dest_os}"
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
