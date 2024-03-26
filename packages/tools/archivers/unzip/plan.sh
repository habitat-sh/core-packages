pkg_name="unzip"
pkg_origin="core"
pkg_version="6.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
UnZip is an extraction utility for archives compressed in .zip format (also \
called 'zipfiles').\
"
pkg_upstream_url="https://sourceforge.net/projects/infozip/"
pkg_license=('Info-ZIP')
pkg_source="https://downloads.sourceforge.net/infozip/unzip60.tar.gz"
pkg_shasum="036d96991646d0449ed0aa952e4fbe21b476ce994abc276e49d30e686708bd37"
pkg_dirname="unzip60"

pkg_deps=(
	core/glibc
	core/bzip2
)
pkg_build_deps=(
	core/gcc
)

pkg_bin_dirs=(bin)

do_prepare() {
	# Apply various fixes to unzip, based on corresponding nix pkg
	# https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/archivers/unzip/default.nix
	patch -p1 <"$PLAN_CONTEXT/CVE-2014-8139.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2014-8140.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2014-8141.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2014-9636.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2014-9913.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2015-7696.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2015-7697.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2016-9844.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2018-18384.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2019-13232-1.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2019-13232-2.patch"
	patch -p1 <"$PLAN_CONTEXT/CVE-2019-13232-3.patch"
	patch -p1 <"$PLAN_CONTEXT/initialize-the-symlink-flag.patch"
}

do_build() {
	DEFINES="-DACORN_FTYPE_NFS -DWILD_STOP_AT_DIR -DLARGE_FILE_SUPPORT \
		-DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DNO_LCHMOD \
		-DDATE_FORMAT=DF_YMD -DUSE_BZIP2 -DNOMEMCPY -DNO_WORKING_ISPRINT"
	make -f unix/Makefile \
		prefix="${pkg_prefix}" \
		D_USE_BZ2=-DUSE_BZIP2 \
		L_BZ2=-lbz2 \
		LF2="$LDFLAGS" \
		CF="$CFLAGS $CPPFLAGS -I. $DEFINES" \
		unzips
}

do_check() {
	# Set timezone for CET
	TZ=CET make -f unix/Makefile check
}

do_install() {
	make -f unix/Makefile prefix="${pkg_prefix}" install
}
