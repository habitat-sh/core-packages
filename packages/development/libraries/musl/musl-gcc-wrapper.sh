#!/bin/sh
HAB_DYNAMIC_LINKER="@prefix@/lib/ld-musl-x86_64/so.1" \
HAB_GCC_C_START_FILES="@prefix@/lib" \
HAB_GCC_C_STD_LIBS="@prefix@/lib" \
HAB_GCC_C_STD_HEADERS="@prefix@/include" \
exec "${REALGCC:-gcc}" "$@" -specs "@prefix@/lib/musl-gcc.specs"