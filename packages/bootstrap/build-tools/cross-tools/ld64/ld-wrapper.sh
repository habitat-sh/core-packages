#!/bin/sh
if [ -x "/usr/bin/xcrun" ]; then
    program=$(/usr/bin/xcrun -f ld)
elif [ -x "/usr/bin/ld" ]; then
    program="/usr/bin/ld"
else
    program="ld"
fi
HAB_DEBUG=${HAB_DEBUG:-${HAB_LD_DEBUG:-${HAB_@env_prefix@_DEBUG:-0}}} \
HAB_LD_RUN_PATH=${HAB_@env_prefix@_LD_RUN_PATH:-${HAB_LD_RUN_PATH:-${LD_RUN_PATH:-""}}} \
@wrapper@ "$program" "$@"