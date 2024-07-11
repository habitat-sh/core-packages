pkg_name="scons"
pkg_origin=core
pkg_version="4.6.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT' 'Apache-2.0' 'BSD-3-Clause')
pkg_upstream_url=http://www.scons.org/
pkg_description="Substitute for classic 'make' tool with autoconf/automake functionality"
pkg_source="https://github.com/SCons/scons/archive/refs/tags/${pkg_version}.tar.gz"
pkg_shasum="085fc9df961224b91ed715c5c44a11796a3e614d146139989ab14e8a347425ff"

pkg_deps=(
    core/coreutils
    core/python
    core/perl
    core/bash
    core/ruby3_3
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_build() {
  return 0
}

do_install() {
    python -m pip install --prefix="${pkg_prefix}" scons
  
  for binary in scons scons-time sconsign
  do
    fix_interpreter "$pkg_prefix/bin/$binary" core/coreutils bin/env
  done

  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/docbook/docbook-xsl-1.76.1/fo/pdf2index" core/perl bin/perl
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/docbook/docbook-xsl-1.76.1/extensions/xslt.py" core/python bin/python

  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/docbook/docbook-xsl-1.76.1/install.sh" core/bash bin/bash
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/docbook/docbook-xsl-1.76.1/tools/bin/docbook-xsl-update" core/bash bin/bash
  
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Utilities/sconsign.py" core/coreutils bin/env
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Utilities/ConfigureCache.py" core/coreutils bin/env
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/ninja/ninja_scons_daemon.py" core/coreutils bin/env
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/ninja/ninja_run_daemon.py" core/coreutils bin/env
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/ninja/ninja_daemon_build.py" core/coreutils bin/env
  fix_interpreter "${pkg_prefix}/lib/python3.10/site-packages/SCons/Tool/docbook/docbook-xsl-1.76.1/epub/bin/dbtoepub" core/coreutils bin/env
}
