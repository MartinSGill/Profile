
function Get-ParentProcess {
    [CmdletBinding()]
    param ()
    Get-Process -Id (Get-ParentProcessId)
}
