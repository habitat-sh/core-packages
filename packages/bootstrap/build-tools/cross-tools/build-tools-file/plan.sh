program="file"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-file"
pkg_origin="core"
pkg_version="5.42"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
file is a standard Unix program for recognizing the type of data contained in \
a computer file.\
"
pkg_upstream_url="https://www.darwinsys.com/file/"
pkg_license=("LicenseRef-file")
pkg_source="ftp://ftp.astron.com/pub/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="c076fb4d029c74073f15c43361ef572cfb868407d347190ba834af3b1639b0e4"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/build-tools-glibc
)
pkg_build_deps=(
	core/native-cross-gcc
	"core/native-file/${pkg_version}"
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(./config.guess)" \
		--host="$native_target" \
		--target="$native_target"

	# The file command on the build host needs to be same version as
	# the one we are building in order to create the signature file.
	make FILE_COMPILE="$(pkg_path_for native-file)"/bin/file
}

do_check() {
	make check
}

do_install() {
	make install

	# As per the copyright, we must include the copyright statement in binary
	# distributions
	#
	# Source: https://github.com/file/file/blob/master/COPYING
	install -v -Dm644 COPYING "$pkg_prefix/share/COPYING"
}
