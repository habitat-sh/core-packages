pkg_name=unzip
pkg_origin=core
pkg_version=6.0
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
UnZip is an extraction utility for archives compressed in .zip format (also \
called 'zipfiles').\
"
pkg_upstream_url="https://sourceforge.net/projects/infozip/"
pkg_license=('Zlib')
pkg_source="https://downloads.sourceforge.net/infozip/unzip60.tar.gz"
pkg_shasum="036d96991646d0449ed0aa952e4fbe21b476ce994abc276e49d30e686708bd37"
pkg_dirname=unzip60
pkg_deps=(
  core/bzip2
  core/glibc
)
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_bin_dirs=(bin)

do_build() {
  DEFINES="-DACORN_FTYPE_NFS -DWILD_STOP_AT_DIR -DLARGE_FILE_SUPPORT \
    -DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DNO_LCHMOD \
    -DDATE_FORMAT=DF_YMD -DUSE_BZIP2 -DNOMEMCPY -DNO_WORKING_ISPRINT"
  make \
    -f unix/Makefile \
    prefix="${pkg_prefix}" \
    D_USE_BZ2=-DUSE_BZIP2 \
    L_BZ2=-lbz2 \
    LF2="$LDFLAGS" \
    CF="$CFLAGS $CPPFLAGS -I. $DEFINES" \
    unzips
}

do_install() {
  make -f unix/Makefile prefix="${pkg_prefix}" install
}

