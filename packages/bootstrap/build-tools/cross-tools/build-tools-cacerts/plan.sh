pkg_name="build-tools-cacerts"
pkg_origin="core"
pkg_version="2022-10-11"
pkg_description="\
The Mozilla CA certificate store in PEM format (around 250KB uncompressed).
"
pkg_upstream_url="https://curl.se/docs/caextract.html"
pkg_license=('MPL-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://curl.se/ca/cacert-${pkg_version}.pem"
pkg_shasum="2cff03f9efdaf52626bd1b451d700605dc1ea000c5da56bd0fc59f8f43071040"

pkg_version() {
	local build_date
	# Extract the build date of the certificates file
	# shellcheck disable=SC2002
	build_date="$(cat "$HAB_CACHE_SRC_PATH/$pkg_filename" |
		grep 'Certificate data from Mozilla' |
		sed 's/^## Certificate data from Mozilla as of: //')"

	# Update the `$pkg_version` value with the build date
	date --date="$build_date" "+%Y.%m.%d"
}

do_download() {
	do_default_download
	update_pkg_version
}

do_unpack() {
	mkdir -pv "$HAB_CACHE_SRC_PATH/$pkg_dirname"
	cp -v "$HAB_CACHE_SRC_PATH/$pkg_filename" "$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

do_prepare() {
	# Tells the core/build-tools-openssl habitat package where to find the SSL certs
	set_runtime_env "HAB_SSL_CERT_FILE" "${pkg_prefix}/ssl/certs/cacert.pem"
	# Compatibility with non-habitat openssl libraries built which check this
	# environment variable by default for SSL certs
	set_runtime_env "SSL_CERT_FILE" "${pkg_prefix}/ssl/certs/cacert.pem"
}

do_build() {
	return 0
}

do_install() {
	mkdir -pv "$pkg_prefix/ssl/certs"
	cp -v "$pkg_filename" "$pkg_prefix/ssl/certs/cacert.pem"
	ln -sv certs/cacert.pem "$pkg_prefix/ssl/cert.pem"
}
