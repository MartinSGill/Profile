
VerboseBlock "Update TERM env" {
    if ($null -eq $env:TERM) {
        Write-MyProDebug "TERM not set, setting to 'xterm'"
        $env:TERM = 'xterm'
    }
}
