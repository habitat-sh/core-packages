program="xcode"
pkg_name="xcode"
pkg_origin="core"
pkg_version="latest"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('Apache-2.0 WITH LLVM-exception')

# Common sandbox exceptions required by almost all xcode tools
runtime_sandbox() {
    echo '(version 1)
(allow file* process-exec process-fork network-outbound network-inbound
    (literal "/usr/bin/xcrun")
    ;; provide access to usr libraries
    (literal "/usr")
    (subpath "/usr/lib")
    ;; provide access to the system libraries
    (literal "/System")
    (subpath "/System/Library")
    (literal "/Library")
    (subpath "/Library/Apple")
    (subpath "/Library/Developer/PrivateFrameworks")
    ;; provide access to xcode
    (literal "/Applications")
    (subpath "/Applications/Xcode.app")
    ;; provide access to tmp directories for intermediate compilation artifacts
    (subpath "/private/var/folders"))

;; disable sandbox for xcodebuild because it requires extensive rules
;; TODO: perhaps make this more fine grained and strict in the future to improve
;; reproducibility
(allow process-exec (with no-sandbox)
    (literal "/usr/bin/xcodebuild")
    (literal "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"))
;; access to read the active xcode
(allow file-read-metadata
    (literal "/private/var/db/xcode_select_link"))
'
}

do_build() {
    return 0
}

do_install() {
    return 0
}
