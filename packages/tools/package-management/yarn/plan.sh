pkg_name="yarn"
pkg_origin="core"
pkg_version="1.22.22"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Yarn is a package manager for your code. It allows you to use and share code with other developers from around the world. Yarn does this quickly, securely, and reliably so you don’t ever have to worry."
pkg_upstream_url="https://yarnpkg.com/"
pkg_license=('BSD-2-Clause')
pkg_source="https://github.com/yarnpkg/yarn/releases/download/v${pkg_version}/yarn-v${pkg_version}.tar.gz"
pkg_shasum="88268464199d1611fcf73ce9c0a6c4d44c7d5363682720d8506f6508addf36a0"

pkg_build_deps=(
	core/sed
)
pkg_deps=(
  core/coreutils
  core/node
)

pkg_bin_dirs=(bin)

# Yarn unpacks into dist, so fix that
do_unpack() {
  pushd "${HAB_CACHE_SRC_PATH}" > /dev/null
    mkdir -pv "${pkg_dirname}"
    tar --strip-components=1 --directory="${pkg_dirname}" -xf "${pkg_filename}"
  popd > /dev/null
}

do_build() {
  return 0
}

do_install() {
  find bin -type f | while read -r f; do
    install -D -m 0755 "${f}" "${pkg_prefix}/${f}"
  done
  rm -rf "${pkg_prefix}/bin"/*.cmd

  find lib LICENSE package.json -type f | while read -r f; do
    install -D -m 0644 "${f}" "${pkg_prefix}/${f}"
  done

	# Fix /usr/bin/env interpreters to use our coreutils
	grep -lr '/usr/bin/env' "$pkg_prefix" | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
}
