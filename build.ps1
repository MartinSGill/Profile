#Requires -Module @{ ModuleName = "Configuration"; ModuleVersion="1.5.1" }

[CmdletBinding()]
param()

Push-Location $PSScriptRoot
$sb = [System.Text.StringBuilder]::new()

$moduleName = 'MartinsProfile'
$artifactFolder = "artifacts/$moduleName"
$srcFolder = 'src'
$classesFolder = Join-Path $srcFolder 'Classes'
$publicFolder = Join-Path $srcFolder 'Public'
$privateFolder = Join-Path $srcFolder 'Private'

# Classes
Get-ChildItem -Path $classesFolder -Recurse -Filter '*.ps1' | ForEach-Object {
    $content = Get-Content -Raw -Path $_
    Write-Verbose "Adding Classes: $_"
    $null = $sb.AppendLine($content)
}

# Private Functions
Get-ChildItem -Path $privateFolder -Recurse -Filter '*.ps1' | ForEach-Object {
    $content = Get-Content -Raw -Path $_
    Write-Verbose "Adding Private: $_"
    $null = $sb.AppendLine($content)
}

# Public Functions
$publicFunctions = Get-ChildItem -Path $publicFolder -Recurse -Filter '*.ps1'
$publicFunctions | ForEach-Object {
    $content = Get-Content -Raw -Path $_
    Write-Verbose "Adding Public: $_"
    $null = $sb.AppendLine($content)
}

# Init Script
Write-Verbose 'Adding init script'
$content = Get-Content -Raw -Path src/init.ps1
$null = $sb.AppendLine($content)

# Generate Artifacts
if ((Test-Path -Path $artifactFolder)) {
    Write-Verbose "Removing artifacts folder: $artifactFolder"
    Remove-Item -Path $artifactFolder -Force -Recurse
}

Write-Verbose "Creating Artifacts folder: $artifactFolder"
$null = New-Item -Path $artifactFolder -ItemType Directory -Force

Write-Verbose 'Writing root module file'
Set-Content -Path (Join-Path $artifactFolder "$moduleName.psm1") -Value $sb.ToString()

$additionalFiles = @(
    @{
        Name = 'config'
        Path = 'config'
    }
    @{
        Name = 'Dlls'
        Path = 'Dlls'
    }
    @{
        Name = 'Types'
        Path = 'Types'
    }
    @{
        Name = 'Formats'
        Path = 'Formats'
    }
)

Write-Verbose 'Copying Additional Files'
$additionalFiles | ForEach-Object {
    Write-Verbose "Copying $($_.Name)"
    Copy-Item -Path "$srcFolder/$($_.Path)" -Destination "$artifactFolder/$($_.Path)" -Recurse
}

Write-Verbose 'Generating PSD1'
$manifest = @{
    Path = "$artifactFolder/$moduleName.psd1"
    NestedModules = @()
    Guid = '585b8e60-7427-478c-ad52-43302e91c970'
    CompanyName =  'Lupus Familiaris Software'
    Copyright =  '(c) 2023, Martin Gill. All Rights Reserved.'
    RootModule =  "$moduleName.psm1"
    ModuleVersion =  '1.0.0'
    Description =  ''
    # ProcessorArchitecture = 'MSIL'
    PowerShellVersion =  '7.0'
    # ClrVersion =  ''
    # DotNetFrameworkVersion =  ''
    # PowerShellHostName = ''
    # PowerShellHostVersion = ''
    RequiredModules =  @(
        @{
            ModuleName = 'PSReadline'
            ModuleVersion = '2.2.0'
        }
        @{
            ModuleName = 'Terminal-Icons'
            ModuleVersion = '0.10.0'
        }
        @{
            ModuleName = 'posh-git'
            ModuleVersion = '1.1.0'
        }
    )
    TypesToProcess = Get-ChildItem -Path "$srcFolder/Types/*.ps1xml" | ForEach-Object { "Types/$($_.Name)" }
    FormatsToProcess = Get-ChildItem -Path "$srcFolder/Formats/*.ps1xml" | ForEach-Object { "Formats/$($_.Name)" }
    ScriptsToProcess = ''
    RequiredAssemblies = @('Dlls/Humanizer.dll')
    FileList = @()
    ModuleList = @()
    FunctionsToExport = @($publicFunctions | ForEach-Object { $_.BaseName })
    AliasesToExport = @()
    VariablesToExport = @()
    CmdletsToExport = @()
    DscResourcesToExport = @()
    CompatiblePSEditions = 'Core'
    PrivateData = @{}
    # Tags = @()
    # ProjectUri = ''
    # LicenseUri = ''
    # IconUri = ''
    ReleaseNotes = 'TODO: Release Notes'
    # Prerelease = ''
    RequireLicenseAcceptance = $false
    # ExternalModuleDependencies = @()
    # HelpInfoUri = ''
    PassThru = $false
    DefaultCommandPrefix = "Pro"
    WhatIf = $false
}
New-ModuleManifest @manifest

Pop-Location
