#!/usr/bin/env bash

file=$1
cmd=$(whereis -b jq | cut -d" " -f2)

main() {
	# check prerequisites exists
	if [ ! -x "$cmd" ]; then
		echo "command 'jq' could not be found! Aborting."
		exit 1
	fi

	if [[ ! -n "$file" ]]; then
		echo "path to 'category.json' is missing. Aborting."
		exit 1
	fi

	file=$(readlink -f "$file")

	# check prerequisites exists
	if [ ! -f "$file" ]; then
		echo "file '${file}' could not be found! Aborting."
		exit 1
	fi

	# validate pkg name as per naming policy
	validate_package_name

	exit 0
}

validate_package_name() {
	# validate pkg name: 7zip, pkg-config, pcre2, gcc-stage0, go1_22, postgresql15-client etc
	# get all pkg name
	local name=$("$cmd" -r '.data[].pkg_name' "$file")
	local name_array=($name)

	for i in "${name_array[@]}"; do
		# validate pkg name
		if [[ ! "$i" =~ ^[a-zA-Z0-9-]+([0-9]_[0-9]+)?$ ]]; then
			if [[ $i != "libatomic_ops" ]]; then
				echo "ERR: package name [$i] is not as per the policy"
			fi
		fi
	done
}

main "$@"
