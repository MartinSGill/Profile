
Add-Type -Path "$PSScriptRoot\dlls\Humanizer.dll"

#####
# Sub-Modules
#####

Get-ChildItem -Path $PSScriptRoot\Private\* -Filter "*.ps1" | ForEach-Object {
    Trace-Message "Sourcing: '$($_.FullName)'"
    . $_.FullName

}
Get-ChildItem -Path $PSScriptRoot\Public\* -Filter "*.ps1" | ForEach-Object {
    Trace-Message "Sourcing: '$($_.FullName)'"
    . $_.FullName
}

#####
# Colours
#####

$Host.PrivateData.VerboseForegroundColor = [System.ConsoleColor]::Gray
$Host.PrivateData.DebugForegroundColor = [System.ConsoleColor]::DarkBlue
$Host.PrivateData.WarningForegroundColor = [System.ConsoleColor]::Yellow
$Host.PrivateData.ErrorForegroundColor = [System.ConsoleColor]::Red

if(!$ProfileDir -or !(Test-Path $ProfileDir)) {
    $ProfileDir = Split-Path $Profile.CurrentUserAllHosts
    Write-Warning "ProfileDir $ProfileDir"
}

#####
# Tools
#####

# Run these functions once
Update-ToolPath

#####
# Quote
#####

$QuoteDir = Join-Path (Split-Path $ProfileDir -parent) "Quotes"
if(!(Test-Path $QuoteDir)) {
    $QuoteDir = Join-Path $PSScriptRoot Quotes
}

# Only export $QuoteDir if it refers to a folder that actually exists
Set-Variable QuoteDir (Resolve-Path $QuoteDir) -Description "Personal Quotes Path Source"

Trace-Message "Random Quotes Loaded"

## Get a random quote, and print it in yellow :D
if( Test-Path "${QuoteDir}\attributed quotes.txt" ) {
    # Get-Quote | Write-Host -Foreground "xt214"
    Format-Quote -Text (Get-Quote)
}

#####
# Live ID
#####

try {
    # If you log in with a Microsoft Identity, this will capture it
    Set-Variable LiveID (
        [Security.Principal.WindowsIdentity]::GetCurrent().Groups.Where{
            $_.Value -match "^S-1-11-96"
        }.Translate([Security.Principal.NTAccount]).Value
    ) -Option ReadOnly -ErrorAction SilentlyContinue
}
catch {
    # Can fail if not using a LiveId.
}

#####
# PSReadline
#####

# Only configure PSReadLine if it's already running
if (Get-Module PSReadline) {
    Update-PSReadLine
}

# Invoke-Expression (& starship init powershell)
Import-Module oh-my-posh
Set-PoshPrompt -Theme (Join-Path $PSScriptRoot 'themes' -AdditionalChildPath 'mytheme.omp.json')

#####
# File Output Formats
#####

$Configuration = Import-Configuration
if ($Configuration.FileColors) {
    $global:PSFileFormats = $Configuration.FileColors
}

# Unfortunately, in order for our File Format colors and History timing to take prescedence, we need to PREPEND the path:
Update-FormatData -PrependPath (Join-Path $PSScriptRoot 'Formats/FileSystemTypes.formats.ps1xml')
Update-FormatData -PrependPath (Join-Path $PSScriptRoot 'Formats/TimeSpan.formats.ps1xml')

#####
# Exports
#####

Export-ModuleMember -Function *-*
Export-ModuleMember -Alias * -Variable LiveID, QuoteDir, PromptUseSafeCharacters
