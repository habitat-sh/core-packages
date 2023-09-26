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
# Add gcc_libs to the LD_RUN_PATH to ensure a rpath entry for gcc_libs/lib
# is always added by our hab-ld-wrapper
if [ -z "$LD_RUN_PATH" ]; then
	export LD_RUN_PATH="@gcc_libs@"
else
	export LD_RUN_PATH="@gcc_libs@:$LD_RUN_PATH"
fi
@program@ "$@"
