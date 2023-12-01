pkg_name=tomcat7
pkg_description="An open source implementation of the Java Servlet, JavaServer Pages, Java Expression Language and Java WebSocket technologies."
pkg_origin=core
pkg_version=7.0.109
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_description="The Apache Tomcat software is an open source implementation of the Java Servlet, JavaServer Pages, Java Expression Language and Java WebSocket technologies."
pkg_upstream_url="http://tomcat.apache.org/"
pkg_source=http://archive.apache.org/dist/tomcat/tomcat-7/v${pkg_version}/bin/apache-tomcat-${pkg_version}.tar.gz
pkg_shasum=ebfeb051e6da24bce583a4105439bfdafefdc7c5bdd642db2ab07e056211cb31
pkg_deps=(core/coreutils core/bash)
pkg_exports=(
	[port]=server.port
)
pkg_exposes=(port)

do_unpack() {
	local source_dir=$HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}
	local unpack_file="$HAB_CACHE_SRC_PATH/$pkg_filename"

	mkdir "$source_dir"
	pushd "$source_dir" >/dev/null
	tar xz --strip-components=1 -f "$unpack_file"

	popd >/dev/null
}

do_build() {
	return 0
}

do_install() {
	build_line "Performing install"
	mkdir -p "${pkg_prefix}/tc"
	cp -vR ./* "${pkg_prefix}/tc"

	# default permissions included in the tarball don't give any world access
	find "${pkg_prefix}/tc" -type d -exec chmod -v 755 {} +
	find "${pkg_prefix}/tc" -type f -exec chmod -v 644 {} +
	find "${pkg_prefix}/tc" -type f -name '*.sh' -exec chmod -v 755 {} +
}
