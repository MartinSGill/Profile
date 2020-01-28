function Get-PromptPathString() {
    <#
        .Synopsis
            Returns a string representing the current path.
        .Notes
            Set $env:PROFILE_SAFE_CHARS to use only non-Powerline font
            characters.
    #>
    [CmdletBinding()]
    param (
        [Int]
        # Max number of path segments to return. Path is shortened if needed.
        $Segments = 6
    )

    $dirSep = [System.IO.Path]::DirectorySeparatorChar;

    $currentPath = $PWD -replace [regex]::Escape($HOME), "~"
    $splitPath = $currentPath -split [regex]::Escape($dirSep)

    $resultPathArray = @()
    if ($splitPath.Length -gt $Segments) {
        $resultPathArray += $splitPath[0..1]
        $resultPathArray += "…"
    }
    $resultPathArray += $splitPath | Select-Object -Last ($Segments - 2)
    $resultPath = $resultPathArray -join $dirSep
    $dirIcon = if ($env:PROFILE_SAFE_CHARS) {
        " "
    } else {
        if ($resultPath -eq "~") {
            "  "
        }
        elseif ($resultPath.StartsWith($env:SystemRoot) -or
            $resultPath.StartsWith($env:ProgramFiles) -or
            $resultPath.StartsWith(${env:ProgramFiles(x86)})) {
            "  "
        }
        elseif ($splitPath -contains ".vscode" -or
                $splitPath -contains ".vs") {
            "  "
        }
        elseif ($splitPath -contains ".idea") {
            "  "
        }
        elseif ($splitPath -contains "node_modules") {
            "  "
        } else {
            "  "
        }
    }

    $dirIcon + $resultPath
}
