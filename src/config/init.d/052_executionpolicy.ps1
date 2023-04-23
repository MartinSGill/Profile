
VerboseBlock "Execution Policy" {
    if ($PSVersionTable.Platform -eq "Windows") {
        WriteDebug "Setting Execution Policy to RemoteSigned"
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    }
}
