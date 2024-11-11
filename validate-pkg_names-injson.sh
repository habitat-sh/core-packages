#!/bin/bash
#
# script to check the package names in the repo has maintainance cycle listed in the
# category.json file.,thus ensuring all plan names in the repo has maintainance cycle.
# compares pkg_names extracted from repo with that of package names from json file.
#
# Author: Ravi Duddela <rduddela@progress.com>
# Maintainers: The Habitat Maintainers humans@habitat.sh
#
# Usage: jq to be installed for JSON parsing.
# takes category json file as input
# sh validate-pkg_names-injson.sh </path/to/category.json file>
#

# exit if the category json file is not provided
if [ -z "$1" ]; then
  echo "---Error: Please specify category.json file---"
  exit 1
fi

# check if provided file exists
if [ ! -f "$1" ]; then
  echo "---Error: File $1 doesnt exist.Please verify---"
  exit 1
fi

# define functions
# get pkg names from plan.sh files
get_linux_pkgnames_from_repo() {
  (
    for plan in $( find $repo_root_dir -name plan.sh ); do
    source "$plan"
    echo "${pkg_name}"
    done
  )
}

# get pkg names from json file
get_pkgnames_from_json() {
  (
    local jsonfile="$1"
    jq -r .data[].pkg_name $jsonfile
  )
}

# get pkg names from plan.ps1 files
get_win_pkgnames_from_repo() {
  (
    find $repo_root_dir -type f -name "*.ps1" | while IFS= read -r file; do
	    pkg_name=$(sed -n 's/.*pkg_name="\([^"]*\)".*/\1/p' "$file")
	    if [ -n "$pkg_name" ]; then
    	echo "${pkg_name}"
      fi
    done
  )
}

repo_root_dir=$(git rev-parse --show-toplevel)
jsonfile="$1"

repo_pkg_names=$(get_linux_pkgnames_from_repo "$repodir")
repo_win_pkg_names=$(get_win_pkgnames_from_repo "$repodir")
json_pkg_names=$(get_pkgnames_from_json "$jsonfile")


# convert names to arrays
IFS=$'\n' read -rd '' -a json_array <<< "$json_pkg_names"
IFS=$'\n' read -rd '' -a linux_array <<< "$repo_pkg_names"
IFS=$'\n' read -rd '' -a win_array <<< "$repo_win_pkg_names"

# concatenate linux package array and window packages array
repo_array=("${linux_array[@]}" "${win_array[@]}")


# compare each element with that of json array
for pkg_name in "${repo_array[@]}"; do
  found=false
  for json_name in "${json_array[@]}"; do
    if [[ "$pkg_name" == "$json_name" ]] ; then
      found=true # name found
      break
    fi
  done
  if [[ $found == false ]]; then
    echo package "$pkg_name is not in maintainance cycle"
    exit 1
  fi
done

echo "All packages from core-packages repo have maintainance cycle"
