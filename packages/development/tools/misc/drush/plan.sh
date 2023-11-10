pkg_name=drush
pkg_origin=core
pkg_version="8.4.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('gplv2+')
pkg_deps=(core/bash core/coreutils core/php core/which)
pkg_build_deps=(core/composer)
pkg_bin_dirs=(bin/vendor/bin)
pkg_upstream_url="http://www.drush.org/en/master/"
pkg_description="Drush is a command line shell and Unix scripting interface for Drupal."

do_prepare() {
	export COMPOSER_HOME="$HAB_CACHE_SRC_PATH/$pkg_dirname/.composer"
	export COMPOSER_ALLOW_SUPERUSER=1

	build_line "Setting COMPOSER_HOME=$COMPOSER_HOME"
	build_line "Setting COMPOSER_ALLOW_SUPERUSER=$COMPOSER_ALLOW_SUPERUSER"
}

do_build() {
	composer global require drush/drush:$pkg_version
}

do_install() {
	cp -r "$COMPOSER_HOME/"* "$pkg_prefix/bin/"
	# remove unneed cache directory
	rm -rf $pkg_prefix/bin/cache

	# fix all interpreters
	grep -lr '/usr/bin/env' "$pkg_prefix" | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
	# fix all interpreters
	grep -lr '/bin/bash' "$pkg_prefix" | while read -r f; do
		sed -e "s,/bin/bash,$(pkg_interpreter_for bash bin/bash),g" -i "$f"
	done
}
