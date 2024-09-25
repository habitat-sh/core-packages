pkg_name=systemd
pkg_origin=core
pkg_version="255.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="systemd is an init system used in Linux distributions to \
bootstrap the user space. Subsequently to booting, it is used to manage system \
processes."
pkg_license=('GPL-2.0-only')
#https://systemd.io
pkg_source="https://github.com/systemd/systemd-stable/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_upstream_url="https://github.com/systemd/systemd"
pkg_shasum="fecc51873373f3db9e461b36277dfc6ff7945de3a8e3cb931296f74f63ee1f14"
pkg_dirname="systemd-stable-${pkg_version}"

pkg_deps=(
	core/glibc
	core/libcap
	core/lz4
	core/util-linux
	core/libseccomp
	core/xz
	core/zstd
	core/curl
	core/python
	core/bash
)
pkg_build_deps=(
	core/coreutils
	core/dbus
	core/gcc
	core/gettext
	core/gperf
	core/m4
	core/meson
	core/ninja
	core/pkg-config
	core/patchelf
	core/patch
	core/cmake
	core/libidn2
	core/sed
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(
	lib
	var/lib
	usr/lib
)

pkg_svc_user=root
pkg_svc_group=root

do_prepare() {
	if [[ ! -f /usr/bin/env ]]; then
		ln -s "$(pkg_path_for core/coreutils)/bin/env" /usr/bin/env
		_clean_file=true
	fi

	export LANG=en_US.utf8
	export LC_ALL=en_US.utf8
	# Systemd needs itself in rpath
	export LD_RUN_PATH="${LD_RUN_PATH}:${pkg_prefix}/lib:${pkg_prefix}/lib/systemd"
	build_line "Setting LD_RUN_PATH=${LD_RUN_PATH}"
	LD_LIBRARY_PATH="${LD_RUN_PATH}"
	export LD_LIBRARY_PATH
	build_line "Setting LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
	pip install jinja2

	# https://github.com/systemd/systemd/commit/442bc2afee6c5f731c7b3e76ccab7301703a45a7
	# Bug with 247
	#  patch -p1 < "${PLAN_CONTEXT}"/patches/0001-meson-set-cxx-variable-before-using-it.patch
	patch -p1 <"${PLAN_CONTEXT}/01_fix_redeclaration_of_struct"
}

do_build() {
	export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/

	# meson_options.txt
	local meson_opts=(
		"--prefix=${pkg_prefix}"
		"-Dmode=release"
		"-Dman=disabled"
		"-Dhtml=disabled"
		"-Ddbuspolicydir=${pkg_prefix}/etc/dbus-1/system.d"
		"-Ddbussessionservicedir=${pkg_prefix}/etc/dbus-1/services"
		"-Ddbussystemservicedir=${pkg_prefix}/etc/dbus-1/system-services"
		"-Dlink-udev-shared=true"
		"-Dlink-executor-shared=true"
		"-Dlink-systemctl-shared=true"
		"-Dlink-networkd-shared=true"
		"-Dlink-timesyncd-shared=true"
		"-Dlink-journalctl-shared=true"
		"-Dlink-boot-shared=true"
		"-Dlink-portabled-shared=true"
		"-Dtests=false"
	)
	meson setup builddir "${meson_opts[@]}"
	ninja -C builddir
}

do_install() {
	ninja -C builddir install

	unset LD_LIBRARY_PATH
	LIBPATH=$LD_LIBRARY_PATH:$(pkg_path_for zstd)/lib:$(pkg_path_for libseccomp)/lib:$(pkg_path_for util-linux)/lib:$(pkg_path_for libcap)/lib:$(pkg_path_for lz4)/lib:$(pkg_path_for xz)/lib

	# set runtime path
	push_runtime_env LD_LIBRARY_PATH $LIBPATH

	# https://github.com/mesonbuild/meson/issues/6541
	# Is meson stripping rpath here?
	find "$pkg_prefix"/bin -type f -executable \
		-exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
		-exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;

	for lib in "${pkg_lib_dirs[@]}"; do
		find "${pkg_prefix}/${lib}" -type f -executable \
			-exec sh -c 'file -i "$1" | grep -q "x-pie-executable; charset=binary"' _ {} \; \
			-exec patchelf --force-rpath --set-rpath "${LD_RUN_PATH}" {} \;
	done

	for lib in "${pkg_lib_dirs[@]}"; do
		find "${pkg_prefix}/${lib}" -type f -name '*.so' \
			-exec patchelf --shrink-rpath {} \;
	done

	# fix interpreter
	sed -e "s,/usr/bin/env bash,$(pkg_path_for bash)/bin/bash,g" -i "${pkg_prefix}/lib/systemd/systemd-update-helper"
	sed -e "s,/usr/bin/env python3,$(pkg_path_for python)/bin/python,g" -i "${pkg_prefix}/bin/ukify"
	sed -e "s,/usr/bin/env python3,$(pkg_path_for python)/bin/python,g" -i "${pkg_prefix}/lib/kernel/install.d/60-ukify.install"
}

do_check() {
	meson test -C build/
}

do_strip() {
	return 0
}

do_end() {
	if [[ -n "${_clean_file}" ]]; then
		rm -f /usr/bin/env
	fi
}
