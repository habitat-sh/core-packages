pkg_name=meson
pkg_origin=core
pkg_version="1.5.0"
pkg_description="The Meson Build System"
pkg_upstream_url="http://mesonbuild.com/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/mesonbuild/${pkg_name}/archive/${pkg_version}.tar.gz"
pkg_shasum="781913826fb6f478eb7d77e1942ab3df39444e4c90e9a3523737e215171db469"

pkg_deps=(  
  core/python
)
pkg_build_deps=(
  core/sed
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_build() {
  python -m pip install wheel --no-build-isolation
  pip wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
}

do_install() {
  pip3 install --no-index --find-links dist --prefix="${pkg_prefix}" meson

  mkdir -p ${pkg_prefix}/share/shell-completions/{bash,zsh}
  install -vDm644 data/shell-completions/bash/meson ${pkg_prefix}/share/shell-completions/bash/meson
  install -vDm644 data/shell-completions/zsh/_meson ${pkg_prefix}/share/shell-completions/zsh/_meson

  local path="${pkg_prefix}/lib/python3.10/site-packages/mesonbuild/scripts"
  sed -e "s,/usr/bin/env python,$(pkg_path_for python)/bin/python,g" -i "$path/python_info.py"
  sed -e "s,/usr/bin/env python3,$(pkg_path_for python)/bin/python,g" -i "$path/cmake_run_ctgt.py"

  #local dir="import ${pkg_prefix}/lib/python3.10/site-packages/mesonbuild"
  #sed "/mesonbuild/i $dir" -i ${pkg_prefix}/bin/meson
}