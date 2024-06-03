program="m4"
pkg_name="m4"
pkg_origin="core"
pkg_version="latest"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('Apache-2.0 WITH LLVM-exception')
pkg_deps=(core/xcode)

runtime_sandbox() {
    echo '(version 1)
(allow file* process-exec process-fork network-outbound network-inbound
    (literal "/usr/bin")
    (literal "/usr/bin/gm4")
    (literal "/usr/bin/m4"))
'
}

do_build() {
    return 0
}

do_install() {
    return 0
}
