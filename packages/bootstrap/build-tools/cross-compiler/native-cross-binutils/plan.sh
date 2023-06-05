program="binutils"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="native-cross-binutils"
pkg_origin="core"
pkg_version="2.37"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Binary Utilities, or binutils, are a set of programming tools for \
creating and managing binary programs, object files, libraries, profile data, \
and assembly source code.
"
pkg_upstream_url="https://www.gnu.org/software/binutils/"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.bz2"
pkg_shasum="67fc1a4030d08ee877a4867d3dcab35828148f87e1fd05da6db585ed5a166bd4"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/hab-ld-wrapper
)

pkg_bin_dirs=(
	bin
)

do_prepare() {
	# Use symlinks instead of hard links to save space (otherwise `strip(1)`
	# needs to process each hard link seperately)
	for f in binutils/Makefile.in gas/Makefile.in ld/Makefile.in gold/Makefile.in; do
		sed -i "$f" -e 's|ln |ln -s |'
	done
}

do_build() {
	patch -p0 < "$PLAN_CONTEXT/malformarchive-linking-fix.patch"
	./configure \
		--prefix=$pkg_prefix \
		--target="$native_target" \
		--disable-nls \
		--enable-gprofng=no \
		--disable-werror \
		--enable-new-dtags
	make V=1
}

do_check() {
	make check
}

do_install() {
	make install
	wrap_binary "${native_target}-ld.bfd"
}

wrap_binary() {
	local binary
	local env_prefix
	local hab_ld_wrapper
	local wrapper_binary
	local actual_binary

	binary="$1"
	env_prefix="NATIVE_CROSS_BINUTILS"
	hab_ld_wrapper="$(pkg_path_for hab-ld-wrapper)"
	wrapper_binary="$pkg_prefix/bin/$binary"
	actual_binary="$pkg_prefix/bin/$binary.real"

	build_line "Adding wrapper for $binary"
	mv -v "$wrapper_binary" "$actual_binary"

	sed "$PLAN_CONTEXT/ld-wrapper.sh" \
		-e "s^@env_prefix@^${env_prefix}^g" \
		-e "s^@wrapper@^${hab_ld_wrapper}/bin/hab-ld-wrapper^g" \
		-e "s^@program@^${actual_binary}^g" \
		>"$wrapper_binary"

	chmod 755 "$wrapper_binary"
}
