#!/bin/bash
# This installs any additional packages before starting the studio.
# It is useful in scenarios where you have a newer version of a package
# and want habitat to pick the newer locally installed version during
# a studio build. We do exactly this during the package refresh process.
if [ -n "${HAB_STUDIO_INSTALL_PKGS-}" ]; then
	echo "Installing additional packages in image"
	deps=$(echo "$HAB_STUDIO_INSTALL_PKGS" | tr ":" "\n")
	for dep in $deps; do
		hab pkg install "$dep"
	done
fi
hab pkg build -N "$1"
