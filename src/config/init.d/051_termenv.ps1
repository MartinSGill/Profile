
VerboseBlock "Update TERM env" {
    if ($null -eq $env:TERM) {
        WriteDebug "TERM not set, setting to 'xterm'"
        $env:TERM = 'xterm'
    }
}
