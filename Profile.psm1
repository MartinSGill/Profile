
#####
# Sub-Modules
#####

Get-ChildItem -Path $PSScriptRoot\Private\* -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Trace-Message "Sourced: $_"
}
Get-ChildItem -Path $PSScriptRoot\Public\* -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Trace-Message "Sourced: $_"
}

#####
# Colours
#####

# Set the colors as early as we can (before any output)
Set-HostColor

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
    Get-Quote | Write-Host -Foreground "xt214"
}

#####
# Live ID
#####

# If you log in with a Microsoft Identity, this will capture it
Set-Variable LiveID (
    [Security.Principal.WindowsIdentity]::GetCurrent().Groups.Where{
        $_.Value -match "^S-1-11-96"
    }.Translate([Security.Principal.NTAccount]).Value
) -Option ReadOnly -ErrorAction SilentlyContinue


#####
# PSReadline
#####

# Only configure PSReadLine if it's already running
if (Get-Module PSReadline) {
    Update-PSReadLine
}

#####
# Prompt
#####

switch -Regex ((Get-ParentProcess).Name) {
    'conemu|code|hyper|extraterm' {
        Trace-Message "Funky Prompt"
        Set-MyPrompt
    }
    Default {
        Trace-Message "Safe Prompt"
        Set-MyPrompt -SafeCharacters
    }
}

#####
# File Output Formats
#####

$Configuration = Import-Configuration
if ($Configuration.FileColors) {
    $global:PSFileFormats = $Configuration.FileColors
}

# Unfortunately, in order for our File Format colors and History timing to take prescedence, we need to PREPEND the path:
Update-FormatData -PrependPath (Join-Path $PSScriptRoot 'Formats.ps1xml')

#####
# Exports
#####

Export-ModuleMember -Function *-*
Export-ModuleMember -Alias * -Variable LiveID, QuoteDir
