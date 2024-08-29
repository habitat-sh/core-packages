#!@shell@
HAB_DYNAMIC_LINKER=${HAB_DYNAMIC_LINKER:-"@dynamic_linker@"} \
HAB_DEBUG=${HAB_DEBUG:-${HAB_GCC_DEBUG:-${HAB_@env_prefix@_DEBUG:-0}}} \
HAB_CC_EXECUTABLE_NAME=${HAB_@env_prefix@_CC_EXECUTABLE_NAME:-"@executable_name@"} \
HAB_LD_BIN=${HAB_@env_prefix@_LD_BIN:-"@ld_bin@"} \
HAB_C_START_FILES=${HAB_@env_prefix@_C_START_FILES:-"@c_start_files@"} \
HAB_C_STD_LIBS=${HAB_@env_prefix@_C_STD_LIBS:-"@c_std_libs@"} \
HAB_C_STD_HEADERS=${HAB_@env_prefix@_C_STD_HEADERS:-"@c_std_headers@"} \
HAB_CXX_STD_LIBS=${HAB_@env_prefix@_CXX_STD_LIBS:-"@cxx_std_libs@"} \
HAB_CXX_STD_HEADERS=${HAB_@env_prefix@_CXX_STD_HEADERS:-"@cxx_std_headers@"} \
