#!/bin/sh
HAB_DEBUG=${HAB_DEBUG:-${HAB_LD_DEBUG:-${HAB_@env_prefix@_DEBUG:-0}}} \
HAB_LD_RUN_PATH=${HAB_@env_prefix@_LD_RUN_PATH:-${HAB_LD_RUN_PATH:-${LD_RUN_PATH:-""}}} \
@wrapper@ @program@ "$@"
