pkg_name=pango
pkg_origin=core
pkg_version="1.54.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('LGPL-2.0-only')
pkg_upstream_url="http://www.pango.org"
pkg_description="Pango is a library for laying out and rendering of text, with an emphasis on internationalization."
pkg_source="https://download.gnome.org/sources/pango/${pkg_version%.*}/pango-${pkg_version}.tar.xz"
pkg_shasum="8a9eed75021ee734d7fc0fdf3a65c3bba51dfefe4ae51a9b414a60c70b2d1ed8"
pkg_filename=${pkg_name}-${pkg_version}.tar.xz

pkg_deps=(
	core/glibc
	core/gcc-libs
	core/cairo
	core/pixman
	core/glib
	core/pcre2
	core/libffi
	core/zlib
	core/fontconfig
	core/freetype
	core/libxml2
	core/libpng
	core/util-linux
	core/harfbuzz
	core/fribidi
)
pkg_build_deps=(
	core/meson
	core/ninja
	core/gcc
	core/cmake
	core/pkg-config
	core/patchelf
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/
	meson setup builddir --prefix=${pkg_prefix} \
		--buildtype=release \
		-Ddocumentation=false \
		-Dintrospection="disabled" \
		--wrap-mode=nofallback

	ninja -C builddir
}

do_install() {
	#ravi changes-->
	#freetype is not added to LD_RUN_PATH though it is added in pkg_deps.
	# not sure why. need to check from hab-auto-build.
	#so appending freetype below
	export LD_RUN_PATH="$LD_RUN_PATH:$(pkg_path_for freetype)/lib"

	ninja -C builddir install
	
	build_line "Setting rpath for all binaries to '${LD_RUN_PATH}'"
	#freetype is not getting set for some binaries with --set-rpath 
	#so using --add-needed for freetype .so. TO use --add-needed freetype
	#should be in the RUN PATH.
	find "${pkg_prefix}/bin" -type f -executable \
	-exec patchelf --set-interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" \
	--set-rpath "${LD_RUN_PATH}" --add-needed libfreetype.so.6 {} \;

	find "${pkg_prefix}/lib" -type f -name "*.so.*" \
    -exec patchelf --set-rpath "${LD_RUN_PATH}" --add-needed libfreetype.so.6 {} \;
	#-->
}

do_check() {
	ninja -C builddir test
}
