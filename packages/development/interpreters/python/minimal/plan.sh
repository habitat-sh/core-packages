pkg_name=python-minimal
pkg_distname=Python
pkg_version=3.10.0
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Python-2.0')
pkg_description="Python is a programming language that lets you work quickly \
  and integrate systems more effectively. \
  \
  This package is not intended for regular use. Please use core/python instead."
pkg_upstream_url="https://www.python.org"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_source="https://www.python.org/ftp/python/${pkg_version}/${pkg_dirname}.tgz"
pkg_shasum="c4e0cbad57c90690cb813fb4663ef670b4d0f587d8171e2c42bd4c9245bd2758"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/python bin/python3 bin/python3.10)

pkg_deps=(
  core/glibc
)

pkg_build_deps=(
  core/coreutils
  core/diffutils
  core/gcc
  core/linux-headers
  core/make
  core/util-linux
)

do_build() {
  ./configure --prefix="$pkg_prefix" \
    --without-ensurepip
  make
}

do_install() {
  make install

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
		sed -e "s,/usr/local/bin/python,$pkg_prefix/bin/python3,g" -i "$f"
	done
  grep -lr '#!  python3' "$pkg_prefix" | while read -r f; do
		sed -e "s,#!  python3,#!$pkg_prefix/bin/python3,g" -i "$f"
	done
  grep -lr '#! python3' "$pkg_prefix" | while read -r f; do
		sed -e "s,#! python3,#!$pkg_prefix/bin/python3,g" -i "$f"
	done
}
