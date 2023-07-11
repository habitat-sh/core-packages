pkg_name=raml2html
pkg_origin=core
pkg_version="6.7.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_deps=(core/node)
pkg_description="RAML to HTML documentation generator."
pkg_upstream_url="https://github.com/raml2html/raml2html"
pkg_bin_dirs=(bin)

do_build() {
	env PREFIX="$CACHE_PATH" npm i -g "${pkg_name}@$pkg_version"
}

do_install() {
	mv "$CACHE_PATH/lib/node_modules/$pkg_name"/* "$pkg_prefix/"

	# Fix node interpreters to use our node
	grep -lr '#!.*bin/env node' "$pkg_prefix" | while read -r f; do
		sed -e "s,#!.*bin/env node,#!$(pkg_interpreter_for node bin/node),g" -i "$f"
	done
}

do_strip() {
	return 0
}
