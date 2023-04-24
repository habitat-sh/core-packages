pkg_name=python
pkg_distname=Python
pkg_version=3.10.8
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Python-2.0.1')
pkg_description="Python is a programming language that lets you work quickly \
  and integrate systems more effectively."
pkg_upstream_url="https://www.python.org"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_source="https://www.python.org/ftp/python/${pkg_version}/${pkg_dirname}.tgz"
pkg_shasum=f400c3fb394b8bef1292f6dc1292c5fadc3533039a5bc0c3e885f3e16738029a

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/python bin/python3 bin/python3.10)

pkg_deps=(
	core/bzip2
	core/expat
	core/gcc-libs
	core/gdbm
	core/glibc
	core/libffi
	core/ncurses
	core/openssl
	core/readline
	core/sqlite
	core/xz
	core/zlib
)

pkg_build_deps=(
	core/pkg-config
	core/coreutils
	core/diffutils
	core/gcc
	core/linux-headers
	core/make
	core/build-tools-util-linux
)

do_prepare() {
	LDFLAGS="${LDFLAGS} -Wl,-rpath=${pkg_prefix}/lib"
}

do_build() {
	./configure --prefix="$pkg_prefix" \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-expat \
		--with-ensurepip \
		--with-openssl="$(pkg_path_for openssl)" \
		--enable-optimizations
	make
}

do_check() {
	make test
}

do_install() {
	do_default_install

	# link pythonx.x to python for pkg_interpreters
	local minor=${pkg_version%.*}
	local major=${minor%.*}
	ln -rs "$pkg_prefix/bin/pip$minor" "$pkg_prefix/bin/pip"
	ln -rs "$pkg_prefix/bin/pydoc$minor" "$pkg_prefix/bin/pydoc"
	ln -rs "$pkg_prefix/bin/python$minor" "$pkg_prefix/bin/python"
	ln -rs "$pkg_prefix/bin/python$minor-config" "$pkg_prefix/bin/python-config"

	# Remove idle as we are not building with Tk/x11 support so it is useless
	rm -vf "$pkg_prefix/bin/idle$major"
	rm -vf "$pkg_prefix/bin/idle$minor"

	platlib=$(python -c "import sysconfig;print(sysconfig.get_path('platlib'))")
	cat <<EOF >"$platlib/_manylinux.py"
# Disable binary manylinux1(CentOS 5) wheel support
manylinux1_compatible = False
EOF
}
