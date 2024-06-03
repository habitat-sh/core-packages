program="system"
pkg_name="system"
pkg_origin="core"
pkg_version="latest"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('Apache-2.0')

runtime_sandbox() {
    echo '(version 1)
(allow file* process-exec process-fork
    (literal "/bin/pwd")
    (literal "/usr/bin/which")
    (literal "/usr/bin/uname")
    (literal "/usr/bin/arch")
    (literal "/usr/bin/cpio")
    (literal "/usr/sbin/dtrace")
    (literal "/usr/bin/sw_vers"))

;; provide access to ps and sudo which must run outside the sandbox
(allow file-read*
    (literal "/bin/ps")
    (literal "/usr/bin/sudo"))
(allow process-exec (with no-sandbox)
    (literal "/bin/ps")
    (literal "/usr/bin/sudo"))

;; provide access to i18n, icu and locale
(allow file-read*
    (subpath "/usr/share/locale")
    (subpath "/usr/share/icu")
    (subpath "/usr/share/i18n"))
'
}

do_build() {
    return 0
}

do_install() {
    return 0
}
