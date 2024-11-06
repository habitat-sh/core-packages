#!/usr/bin/env bash

file=""
cmd=$(whereis -b jq | cut -d" " -f2)

main() {
	# check prerequisites exists
	if [ ! -x "$cmd" ]; then
		echo "command 'jq' could not be found! Aborting."
		exit 1
	fi

	while getopts ":f:chn" option; do
		case ${option} in
		c) # validate category of package family
			validate_package_category_per_family
			;;
		f) # input file
			file="$OPTARG"
			if [[ -z "$file" ]]; then
				echo "ERR: path to 'category.json' is missing. Aborting."
				exit 1
			fi

			file=$(readlink -f "$file")

			# Check if file exists
			if [ ! -f "$file" ]; then
				echo "ERR: file '${file}' could not be found! Aborting."
				exit 1
			fi
			;;
		h) # display help
			usage
			exit 1
			;;
		n) # validate package name
			# validate pkg name as per naming policy
			validate_package_name
			;;
		:) # missing argument for options that require one
			echo "ERR: Invalid option -$OPTARG requires an argument."
			exit 1
			;;
		?) # invalid option
			echo "ERR: Invalid argument: -$OPTARG."
			exit 1
			;;
		esac
	done

	shift $((OPTIND - 1))

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

validate_package_category_per_family() {
	# validate pkg category of packages belongs to same family
	local family=$(${cmd} -r '.data[].pkg_family' ${file} | sort -u)
	local family_array=($family)

	for i in "${family_array[@]}"; do
		# validate pkg category  in family
		local count=$(${cmd} --arg value $i -r '.data[] | select(.pkg_family == $value) | .pkg_category' ${file} | sort -u | wc -l)

		if [[ $count -ne 1 ]]; then
			echo "ERR: package family [$i] have multiple category packages"
		fi
	done
}

usage() {
	echo "A script to validate meta data about packages in repo."
	echo
	echo "Syntax: validate_packages.sh [-f file | -c | -h | -n]"
	echo "options:"
	echo "f        Specify category.json file."
	echo "c        Validate package category of each package family."
	echo "n        Validate packages name in json file."
	echo "h        Print this help."
	echo
}

main "$@"
