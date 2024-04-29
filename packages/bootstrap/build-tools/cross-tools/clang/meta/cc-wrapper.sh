#!/bin/sh
HAB_DEBUG=${HAB_DEBUG:-${HAB_CLANG_DEBUG:-${HAB_@env_prefix@_DEBUG:-0}}} \
HAB_ALLOWED_IMPURE_PATHS=${HAB_@env_prefix@_ALLOWED_IMPURE_PATHS:-"@allowed_impure_paths@"} \
HAB_CC_EXECUTABLE_NAME=${HAB_@env_prefix@_CC_EXECUTABLE_NAME:-"@executable_name@"} \
HAB_LD_BIN=${HAB_@env_prefix@_LD_BIN:-"@ld_bin@"} \
@wrapper@ @program@ "$@"
