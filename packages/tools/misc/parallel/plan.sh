pkg_name="parallel"
pkg_origin="core"
pkg_version="20221222"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Parallel is a shell tool for executing jobs in parallel.  A job \
is typically a single command or a small script that has to be run \
for each of the lines in the input.  The typical input is a list of \
files, a list of hosts, a list of users, or a list of tables. \
\
If you use xargs today you will find GNU Parallel very easy to use. \
If you write loops in shell, you will find GNU Parallel may be able \
to replace most of the loops and make them run faster by running \
jobs in parallel.  If you use ppss or pexec you will find GNU \
Parallel will often make the command easier to read. \
\
GNU Parallel makes sure output from the commands is the same output \
as you would get had you run the commands sequentially.  This makes \
it possible to use output from GNU Parallel as input for other \
programs. \
"
pkg_upstream_url="https://www.gnu.org/software/parallel/"
pkg_license=('GPL-3.0-or-later')
pkg_source="https://ftp.gnu.org/gnu/parallel/${pkg_name}-${pkg_version}.tar.bz2"
pkg_shasum="4da90c7bec18a94431b4e3db49dd563f65cf20ceafd245f7cc7b42ef8bf8597f"
pkg_dirname="${pkg_name}-${pkg_version}"

pkg_deps=(
	core/coreutils
	core/procps-ng
	core/perl
)

pkg_build_deps=(
	core/texinfo
)

pkg_bin_dirs=(bin)

do_prepare() {
	# Fix all script interpreters
	grep -lr '/usr/bin/env' . | while read -r f; do
		sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i "$f"
	done
	grep -lr '/usr/bin/perl' . | while read -r f; do
		sed -e "s,/usr/bin/perl,$(pkg_interpreter_for perl bin/perl),g" -i "$f"
	done
}
