program="python"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-python"
pkg_distname="Python"
pkg_version="3.10.8"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Python-2.0.1')
pkg_description="Python is a programming language that lets you work quickly \
  and integrate systems more effectively."
pkg_upstream_url="https://www.python.org"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_source="https://www.python.org/ftp/python/${pkg_version}/${pkg_dirname}.tgz"
pkg_shasum="f400c3fb394b8bef1292f6dc1292c5fadc3533039a5bc0c3e885f3e16738029a"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/python bin/python3 bin/python3.10)

pkg_deps=(
	core/build-tools-glibc
	core/build-tools-coreutils
)

pkg_build_deps=(
	core/build-tools-gcc
)

do_build() {
	./configure --prefix="$pkg_prefix" \
		--enable-shared \
		--without-ensurepip
	make
}

do_install() {
	make install
	grep -lr '/usr/bin/env' "$pkg_prefix" | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for build-tools-coreutils bin/env),g" -i "$f"
	done
	# Explicity point to this python version, this interpreter line is used by the cgi.py script
	grep -lr '/usr/local/bin/python' "$pkg_prefix" | while read -r f; do
		sed -e "s,/usr/local/bin/python,$pkg_prefix/bin/python3,g" -i "$f"
	done
	ln -s "python3.10" "$pkg_prefix"/bin/python
}
