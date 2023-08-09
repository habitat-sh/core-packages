pkg_name="libhab"
pkg_origin="core"
pkg_version="0.0.1"
pkg_description="A library to wrap C library functions for Habitat compatibility"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_lib_dirs=(lib)

do_build() {
	gcc -c -fPIC -o "$CACHE_PATH/libhabi.o" "$PLAN_CONTEXT/hab_interpose.c"
	gcc -c -fPIC -o "$CACHE_PATH/libhabw.o" "$PLAN_CONTEXT/hab_wrap.c"

	ar -rv "$CACHE_PATH/libhabi.a" "$CACHE_PATH/libhabi.o"
	ar -rv "$CACHE_PATH/libhabw.a" "$CACHE_PATH/libhabw.o"
}

do_install() {
	install -Dm644 "$CACHE_PATH/libhabi.a" "$pkg_prefix/lib/libhabi.a"
	install -Dm644 "$CACHE_PATH/libhabw.a" "$pkg_prefix/lib/libhabw.a"
}
