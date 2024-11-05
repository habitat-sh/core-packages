#!/bin/bash
#script to check the package names in the repo has maintainance cycle listed in the
#category.json file.,thus ensuring all plan names in the repo has maintainance cycle.
#compares pkg_names extracted from repo with that of package names from json file.
#Author: Ravi Duddela <rduddela@progress.com>
#Maintainers: The Habitat Maintainers humans@habitat.sh
#Usage: jq to be installed for JSON parsing.
#reconfirm the jsonfile and repodir. here has given default locations.
#this script to be run from root folder of core-packages repo.

get_names_from_repo() {
  (
    local repodir="${1}"
    cd "$repodir"
    for plan in $( find . -name plan.sh ); do
    source "$plan"
    echo "${pkg_name}"
    done
  )
}

get_names_from_json() {
  (
    local jsonfile="$1"
    jq -r .data[].pkg_name category.json
  )
}

jsonfile=category.json  #here can give path of json file if not present in pwd.
repodir="$PWD"  #can change the path of repo if not run from pwd.

repo_pkg_names=$(get_names_from_repo "$repodir")
json_pkg_names=$(get_names_from_json "$jsonfile")

# Convert names to arrays
IFS=$'\n' read -rd '' -a json_array <<< "$json_pkg_names"
IFS=$'\n' read -rd '' -a repo_array <<< "$repo_pkg_names"

#compare each element with that of json array
for pkg_name in "${repo_array[@]}"; do
  found=false
  for json_name in "${json_array[@]}"; do
    if [[ "$pkg_name" == "$json_name" ]] ; then
      found=true #name found
      break
    fi
  done
  if [[ $found == false ]]; then
    echo "$pkg_name not in maintainance cycle"
    exit 1
  fi
done

echo "All packages from core-packages repo has maintainance cycle"
