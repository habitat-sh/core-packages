original_arguments=$@

# Detect if C++ compiler is being used
is_cxx=false
if [[ "$HAB_CC_EXECUTABLE_NAME" == *"++" ]]; then
    is_cxx=true
fi

# Process arguments
filtered_arguments=()
add_start_files=true
add_c_std_headers=true
add_c_std_libs=true
add_cxx_std_headers=true
add_cxx_std_libs=true

previous_argument=""
while [[ $# -gt 0 ]]; do
    case "$previous_argument" in
        "-nostdinc")
            add_c_std_headers=false
            add_cxx_std_headers=false
            ;;
        "-nostdinc++")
            add_cxx_std_headers=false
            ;;
        "-nolibc")
            add_c_std_libs=false
            ;;
        "-nostdlib")
            add_c_std_libs=false
            add_cxx_std_libs=false
            ;;
        "-nostartfiles")
            add_start_files=false
            ;;
        "-isysroot")
            # Skip the current argument
            previous_argument=""
            continue
            ;;
        "-x")
            if [[ "$1" == c++* ]]; then
                is_cxx=true
            fi
            ;;
    esac
    filtered_arguments+=("$1")
    previous_argument="$1"
    shift
done

# Add the path to the linker binary
if [[ -n "$HAB_LD_BIN" ]]; then
    filtered_arguments+=("-B$HAB_LD_BIN")
fi

# Add start files if needed
if [[ "$add_start_files" == true ]]; then
    IFS=':' read -r -a start_files <<< "$HAB_C_START_FILES"
    for dir in "${start_files[@]}"; do
        filtered_arguments+=("-B$dir")
    done
fi

# Add C++ specific libraries and headers
if [[ "$is_cxx" == true ]]; then
    if [[ "$add_cxx_std_libs" == true ]]; then
        IFS=':' read -r -a cxx_std_libs <<< "$HAB_CXX_STD_LIBS"
        for lib_dir in "${cxx_std_libs[@]}"; do
            filtered_arguments+=("-L$lib_dir")
        done
    fi
    if [[ "$add_cxx_std_headers" == true ]]; then
        IFS=':' read -r -a cxx_std_headers <<< "$HAB_CXX_STD_HEADERS"
        for include_dir in "${cxx_std_headers[@]}"; do
            filtered_arguments+=("-isystem $include_dir")
        done
    fi
fi

# Add C standard libraries and headers
if [[ "$add_c_std_libs" == true ]]; then
    IFS=':' read -r -a c_std_libs <<< "$HAB_C_STD_LIBS"
    for lib_dir in "${c_std_libs[@]}"; do
        filtered_arguments+=("-L$lib_dir")
    done
fi
if [[ "$add_c_std_headers" == true ]]; then
    IFS=':' read -r -a c_std_headers <<< "$HAB_C_STD_HEADERS"
    for include_dir in "${c_std_headers[@]}"; do
        filtered_arguments+=("-idirafter $include_dir")
    done
fi

# Log debug information if debugging is enabled
if [[ "$HAB_DEBUG" == "1" ]]; then
    {
        echo "is_cxx: $is_cxx"
        echo "add_start_files: $add_start_files"
        echo "add_c_std_libs: $add_c_std_libs"
        echo "add_c_std_headers: $add_c_std_headers"
        echo "add_cxx_std_libs: $add_cxx_std_libs"
        echo "add_cxx_std_headers: $add_cxx_std_headers"
        echo "filtered_cc_arguments: ${filtered_arguments[@]}"
	echo "filtered_cc_arguments: ["
	for arg in "${filtered_arguments[@]}"; do
    	    echo "    \"$arg\","
	done
	echo "]"
	echo "work_dir: $(pwd)"
	echo "original: @program@ $original_arguments"
	echo "wrapped: @program@ ${filtered_arguments[@]}"
    } 1>&2
fi

# Execute the wrapped compiler with the modified arguments
exec @program@ "${filtered_arguments[@]}"