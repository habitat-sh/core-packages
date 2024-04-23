program="python2"
pkg_name="python2"
pkg_distname=Python
pkg_version="2.7.18"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Python-2.0.1')
pkg_description="Python is a programming language that lets you work quickly \
  and integrate systems more effectively."
pkg_upstream_url="https://www.python.org"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_source="https://www.python.org/ftp/python/${pkg_version}/${pkg_dirname}.tgz"
pkg_shasum="da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

pkg_deps=(
	core/bzip2
	core/coreutils
	core/expat
	core/gdbm
	core/glibc
	core/libffi
	core/ncurses
	core/openssl
	core/readline
	core/sqlite
	core/zlib
)

pkg_build_deps=(
	core/gcc
	core/linux-headers
	core/pkg-config
	core/util-linux
)

pkg_interpreters=(bin/python bin/python2 bin/python2.7)

do_prepare() {
	sed -i.bak 's/#zlib/zlib/' Modules/Setup.dist
	sed -i -re "/(SSL=|_ssl|-DUSE_SSL|-lssl).*/ s|^#||" Modules/Setup.dist
}

do_build() {
	./configure --prefix="$pkg_prefix" \
		--enable-shared \
		--enable-unicode=ucs4 \
		--with-threads \
		--with-system-expat \
		--with-system-ffi \
		--with-ensurepip \
		--enable-optimizations
	make
}

do_check() {
	make test
}

do_install() {
	make install

	# Remove idle as we are not building with Tk/x11 support so it is useless
	rm -vf "$pkg_prefix/bin/idle"

	# Get the path of the platform-specific library.
	platlib=$(python -c "import sysconfig;print(sysconfig.get_path('platlib'))")

	# Create a _manylinux.py file in the platform-specific library path.
	# Disable binary manylinux1(CentOS 5) wheel support.
	# This is done to prevent potential issues with installing Python binary packages (wheels)
	# that were built for compatibility with CentOS 5 and other older Linux distributions.
	# Since such binary packages might contain shared libraries linked against older system
	# libraries, there could be compatibility issues when they're installed on newer Linux
	# distributions. By setting `manylinux1_compatible` to `False`, pip will not install
	# manylinux1 wheels on this system, so packages will be built from source code instead.
	# For more information on manylinux1 compatibility see PEP 513:
	# https://www.python.org/dev/peps/pep-0513/
	cat <<EOF >"$platlib/_manylinux.py"
manylinux1_compatible = False
EOF

	# Fix /usr/bin/env interpreters to use our coreutils
	grep -lr '/usr/bin/env' "$pkg_prefix" | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
	# Explicity point to this python version, this interpreter line is used by the cgi.py script
	grep -lr '/usr/local/bin/python' "$pkg_prefix" | while read -r f; do
		sed -e "s,/usr/local/bin/python,$pkg_prefix/bin/python,g" -i "$f"
	done
}
