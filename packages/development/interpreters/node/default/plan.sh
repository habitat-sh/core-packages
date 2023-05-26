pkg_name=node
pkg_origin=core
pkg_version="14.18.1"
pkg_description="Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine."
pkg_upstream_url=https://nodejs.org/
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://nodejs.org/dist/v${pkg_version}/node-v${pkg_version}.tar.gz"
pkg_shasum="89d22d34fd4ba3715252dcd2dd94d1699338436463b277163ed950040c7b621a"
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/python2
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
	sed -e "s#/usr/bin/env python#$(pkg_path_for python2)/bin/python#" -i configure
	# Ensure python2 is picked up by the configure script
	export FORCE_PYTHON2=1
}

do_build() {
	./configure \
		--prefix "${pkg_prefix}" \
		--dest-cpu "arm64" \
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
}
