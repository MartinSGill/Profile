
VerboseBlock "Execution Policy" {
    if ($PSVersionTable.Platform -eq "Windows") {
        Write-MyProDebug "Setting Execution Policy to RemoteSigned"
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    }
}
