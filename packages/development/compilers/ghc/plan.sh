pkg_name=ghc
pkg_origin=core
pkg_version="9.10.1"
pkg_license=('BSD-3-Clause')
pkg_upstream_url="https://www.haskell.org/ghc/"
pkg_description="The Glasgow Haskell Compiler - Binary Bootstrap"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://downloads.haskell.org/~ghc/${pkg_version}/ghc-${pkg_version}-x86_64-deb11-linux.tar.xz"
pkg_shasum="78975575b8125ecf1f50f78b1016b14ea6e87abbf1fc39797af469d029c5d737"
pkg_dirname="ghc-${pkg_version}"

pkg_deps=(
	core/glibc
	core/gmp
	core/libffi
	core/ncurses
	core/coreutils
	core/gcc
	core/gcc-base
	core/gcc-libs
	core/binutils
)
pkg_build_deps=(
	core/make
	core/patchelf
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/runhaskell bin/runghc)

do_unpack() {
	do_default_unpack

	mv ghc-${pkg_version}-x86_64-unknown-linux ${pkg_dirname}
}

do_build() {
	./configure \
		--prefix="${pkg_prefix}"
}

do_install() {
	# make install
	cp -r bin include lib wrappers "${pkg_prefix}"

	# The ghc binary (ghc-${pkg_version}) requires libtinfo.so.6, which is not available
	# in the current ncurses build because it was built with the --enable-widec option.
	ln -sfv "$(pkg_path_for ncurses)/lib/libtinfow.so" "${pkg_prefix}/bin/libtinfo.so.6"

	export LD_RUN_PATH="${LD_RUN_PATH}:${pkg_prefix}/lib/x86_64-linux-ghc-${pkg_version}:${pkg_prefix}/bin"

	build_line "Setting rpath for all binaries to '${LD_RUN_PATH}'"
	find "${pkg_prefix}/bin" -type f -executable \
		-exec patchelf --set-interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" \
		--set-rpath "${LD_RUN_PATH}" {} \;

	build_line "Setting rpath for all libraries to '${LD_RUN_PATH}'"
	find "${pkg_prefix}/lib" -type f -name "*.so" \
		-exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;

	patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/lib/x86_64-linux-ghc-${pkg_version}/libffi.so.8.1.4
	patchelf --set-rpath "$LD_RUN_PATH" ${pkg_prefix}/lib/x86_64-linux-ghc-${pkg_version}/libffi.so.8

	sed -e "s,/usr/bin/env,$(pkg_path_for coreutils)/bin/env,g" -i ${pkg_prefix}/lib/post-link.mjs

	sed -e "s,/usr/bin/gcc,$(pkg_path_for gcc-base)/bin/gcc,g" -i ${pkg_prefix}/lib/settings
	sed -e "s,/usr/bin/ld.gold,$(pkg_path_for binutils)/bin/ld.gold,g" -i ${pkg_prefix}/lib/settings
}

do_strip() {
	return 0
}
