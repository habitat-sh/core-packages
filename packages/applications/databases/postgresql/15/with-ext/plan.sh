# shellcheck disable=SC2164
pkg_name="postgresql-with-ext-15"
pkg_version="15.1"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="PostgreSQL is a powerful, open source object-relational database system."
pkg_upstream_url="https://www.postgresql.org/"
pkg_license=('PostgreSQL')

# Determine the location of this plan file
plan_path=$(dirname "${BASH_SOURCE[0]}")

# Determine the package name of the core plan
core_pkg=$(
	source "${plan_path}"/../core/plan.sh
	echo "$pkg_origin/$pkg_name"
)
# Determine the package names of all extension plans
extension_pkgs=$(
	for ext in "${plan_path}"/../extensions/*; do
		echo "$(
			source "$ext/plan.sh"
			echo "$pkg_origin"/"$pkg_name"
		)"
	done
)

all_pkgs=(${extension_pkgs[@]})
all_pkgs+=("$core_pkg")

# Set the pkg_deps to the pkg_deps of the core
pkg_deps=($(
	source "${plan_path}"/../core/plan.sh
	echo "${pkg_deps[@]}"
))
# Add the pkg_deps of each extension
for ext in "${plan_path}"/../extensions/*; do
	pkg_deps+=($(
		source $ext/plan.sh
		echo "${pkg_deps[@]}"
	))
done
# Remove duplicate pkg_dep entries
pkg_deps=($(for pkg in "${pkg_deps[@]}"; do echo "${pkg}"; done | sort -u))

# Set the fixed pkg_build_deps
pkg_build_deps=(
	core/patchelf
	core/rsync
	core/findutils
	core/file
)

# Add the core and extensions packages as build deps
pkg_build_deps+=(${all_pkgs[@]})

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_exports=(
	[port]=port
	[superuser_name]=superuser.name
	[superuser_password]=superuser.password
)
pkg_exposes=(port)

do_build() {
	return 0
}

do_install() {
	
	# For each package we need to combine we sync the necessary folders
	# to the final pkg_prefix folder.
	for pkg in "${all_pkgs[@]}"; do
		rsync \
			-a \
			-v \
			--include="bin/***" \
			--include="lib/***" \
			--include="include/***" \
			--include="share/***" \
			--exclude="*" \
			"$(pkg_path_for ${pkg})"/ \
			"${pkg_prefix}"
	done

	# Patch all binaries and libraries to replace any rpath entries pointing to
	# the postgres and extension folders to this pkg_prefix folder instead
	find "${pkg_prefix}" -type f -exec sh -c 'case $( file -bi "$1" ) in *application/x-executable* | *application/x-pie-executable* | *application/x-sharedlib*) exit 0; esac; exit 1' sh {} \; -print | while read -r f; do
		local old_rpath
		local new_rpath
		old_rpath=$(patchelf --print-rpath "$f")
		new_rpath=$old_rpath
		for pkg in "${all_pkgs[@]}"; do
			new_rpath=${new_rpath//"$(pkg_path_for $pkg)/"/"${pkg_prefix}/"}
		done
		if [[ "$new_rpath" != "$old_rpath" ]]; then
			echo "Patching rpath of $f"
			patchelf --set-rpath "$new_rpath" "$f"
		fi
	done
}
