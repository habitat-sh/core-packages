#!/bin/sh
# If we are debugging add additional environment variables to ensure we can
# see the linker debug output
if [ "$HAB_DEBUG" = "1" ]; then
	RUSTFLAGS="$RUSTFLAGS -C link-arg=-Wl,--verbose"
	if [ -z "$RUSTC_LOG" ]; then
		export RUSTC_LOG="rustc_codegen_ssa::back::link=info"
	else
		export RUSTC_LOG="$RUSTC_LOG,rustc_codegen_ssa::back::link=info"
	fi
fi
# If the HAB_LD_LINK_MODE is not explicitly specified we set it to minimal
# to avoid unnecessary rpaths
if [ -z "$HAB_LD_LINK_MODE" ]; then
	export HAB_LD_LINK_MODE="minimal"
fi
@program@ "$@"
