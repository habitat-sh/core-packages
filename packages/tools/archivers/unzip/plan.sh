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
	core/bzip2
)

pkg_bin_dirs=(bin)

do_prepare() {
	# Apply various fixes to unzip, based on corresponding nix pkg
	# https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/archivers/unzip/default.nix
	patch -p1 <"$PLAN_CONTEXT/01-manpages-in-section-1-not-in-section-1l.patch"
	patch -p1 <"$PLAN_CONTEXT/04-handle-pkware-verification-bit.patch"
	patch -p1 <"$PLAN_CONTEXT/05-fix-uid-gid-handling.patch"
	patch -p1 <"$PLAN_CONTEXT/06-initialize-the-symlink-flag.patch"
	patch -p1 <"$PLAN_CONTEXT/07-increase-size-of-cfactorstr.patch"
	patch -p1 <"$PLAN_CONTEXT/08-allow-greater-hostver-values.patch"
	patch -p1 <"$PLAN_CONTEXT/09-cve-2014-8139-crc-overflow.patch"
	patch -p1 <"$PLAN_CONTEXT/10-cve-2014-8140-test-compr-eb.patch"
	patch -p1 <"$PLAN_CONTEXT/11-cve-2014-8141-getzip64data.patch"
	patch -p1 <"$PLAN_CONTEXT/12-cve-2014-9636-test-compr-eb.patch"
	patch -p1 <"$PLAN_CONTEXT/13-remove-build-date.patch"
	patch -p1 <"$PLAN_CONTEXT/14-cve-2015-7696.patch"
	patch -p1 <"$PLAN_CONTEXT/15-cve-2015-7697.patch"
	patch -p1 <"$PLAN_CONTEXT/16-fix-integer-underflow-csiz-decrypted.patch"
	patch -p1 <"$PLAN_CONTEXT/17-restore-unix-timestamps-accurately.patch"
	patch -p1 <"$PLAN_CONTEXT/18-cve-2014-9913-unzip-buffer-overflow.patch"
	patch -p1 <"$PLAN_CONTEXT/19-cve-2016-9844-zipinfo-buffer-overflow.patch"
	patch -p1 <"$PLAN_CONTEXT/20-cve-2018-1000035-unzip-buffer-overflow.patch"
	patch -p1 <"$PLAN_CONTEXT/21-fix-warning-messages-on-big-files.patch"
	patch -p1 <"$PLAN_CONTEXT/22-cve-2019-13232-fix-bug-in-undefer-input.patch"
	patch -p1 <"$PLAN_CONTEXT/23-cve-2019-13232-zip-bomb-with-overlapped-entries.patch"
	patch -p1 <"$PLAN_CONTEXT/24-cve-2019-13232-do-not-raise-alert-for-misplaced-central-directory.patch"
	# patch -p1 <"$PLAN_CONTEXT/99-unzip60-alt-iconv-utf8.patch"
	# patch -p1 <"$PLAN_CONTEXT/implicit-declarations-fix.patch"
	sed -E -i "/-O3/s|(LF2=\")|\1${LDFLAGS}|" unix/Makefile

}

do_build() {
	# DEFINES="-DACORN_FTYPE_NFS -DWILD_STOP_AT_DIR -DLARGE_FILE_SUPPORT \
	# 	-DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DNO_LCHMOD \
	# 	-DDATE_FORMAT=DF_YMD -DUSE_BZIP2 -DNOMEMCPY -DNO_WORKING_ISPRINT"
	DEFINES="-DLARGE_FILE_SUPPORT -DUSE_BZIP2 -DUNIX"
	make -f unix/Makefile \
		CC="clang" \
		prefix="${pkg_prefix}" \
		D_USE_BZ2=-DUSE_BZIP2 \
		L_BZ2=-lbz2 \
		LF2="$LDFLAGS" \
		CF="$CFLAGS $CPPFLAGS -I. $DEFINES" \
		macosx
}

do_check() {
	# Set timezone for CET
	TZ=CET make -f unix/Makefile check
}

do_install() {
	make -f unix/Makefile prefix="${pkg_prefix}" install
}
