pkg_name=python37
pkg_distname=Python
pkg_version="3.7.11"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Python-2.0')
pkg_description="Python is a programming language that lets you work quickly \
  and integrate systems more effectively."
pkg_upstream_url="https://www.python.org"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_source="https://www.python.org/ftp/python/${pkg_version}/${pkg_dirname}.tgz"
pkg_shasum="b4fba32182e16485d0a6022ba83c9251e6a1c14676ec243a9a07d3722cd4661a"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/python bin/python3 bin/python3.7 bin/python3.7m)

pkg_deps=(
  core/bzip2
  core/coreutils
  core/expat
  core/gcc-libs
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
  core/pkg-config
  core/gcc
  core/util-linux
)

do_setup_environment() {
  export LDFLAGS="$LDFLAGS -lgcc_s"
}

do_prepare() {
  sed -i.bak 's/#zlib/zlib/' Modules/Setup.dist
  sed -i -re "/(SSL=|_ssl|-DUSE_SSL|-lssl).*/ s|^#||" Modules/Setup.dist
}

do_build() {
  ./configure --prefix="$pkg_prefix" \
              --enable-loadable-sqlite-extensions \
              --enable-shared \
              --with-system-expat \
              --with-ensurepip \
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
		sed -e "s,/usr/local/bin/python,$pkg_prefix/bin/python3,g" -i "$f"
	done
}
