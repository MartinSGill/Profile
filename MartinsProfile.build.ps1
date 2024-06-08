#Requires -Version 7.4
#Requires -Modules @{ ModuleName="InvokeBuild"; ModuleVersion="5.11.1" }

param()

# Properties
$CompanyName = (property CompanyName 'Lupus Familiaris Software')
$Copyright =  (property Copyright '(c) 2024, Martin Gill. All Rights Reserved.')
$ModuleName = (property ModuleName 'MartinsProfile')
$ModuleVersion = (property ModuleVersion '1.3.0')

# Paths
$SrcFolder = (property SrcFolder (Join-Path $BuildRoot 'src'))
$ClassesFolder = (property ClassFolder (Join-Path $srcFolder 'Classes'))
$PublicFolder = (property PublicFolder (Join-Path $srcFolder 'Public'))
$PrivateFolder = (property PrivateFolder (Join-Path $srcFolder 'Private'))

$OutputFolder = (property ModuleOutputFolder (Join-Path $BuildRoot 'artifacts'))
$ModuleOutputFolder = (property ModuleOutputFolder (Join-Path $OutputFolder $ModuleName))
$DevRepoPath = (property DevRepoPath (Join-Path $OutputFolder 'devrepo'))

task Build GenerateModule, CopyAdditionalFiles, GenerateManifest, {

}

task Clean {
    remove $ModuleOutputFolder
}

task EnsureFolders {
    $null = New-Item -Path $ModuleOutputFolder -ItemType Directory -Force
}

$ClassScripts = Get-ChildItem -Path $ClassesFolder -Recurse -Filter '*.ps1'
$PublicScripts = Get-ChildItem -Path $PublicFolder -Recurse -Filter '*.ps1'
$PrivateScripts = Get-ChildItem -Path $PrivateFolder -Recurse -Filter '*.ps1'

task GenerateModule EnsureFolders, {
    $sb = [System.Text.StringBuilder]::new()

    # Classes
    $ClassScripts | ForEach-Object {
        $content = Get-Content -Raw -Path $_
        Write-Verbose "Adding Classes: $_"
        $null = $sb.AppendLine($content)
    }

    # Private Functions
    $PrivateScripts | ForEach-Object {
        $content = Get-Content -Raw -Path $_
        Write-Verbose "Adding Private: $_"
        $null = $sb.AppendLine($content)
    }

    # Public Functions
    $PublicScripts | ForEach-Object {
        $content = Get-Content -Raw -Path $_
        Write-Verbose "Adding Public: $_"
        $null = $sb.AppendLine($content)
    }

    # Init Script
    Write-Verbose 'Adding init script'
    $content = Get-Content -Raw -Path (Join-Path $SrcFolder init.ps1)
    $null = $sb.AppendLine($content)

    Write-Verbose 'Writing root module file'
    Set-Content -Path (Join-Path $ModuleOutputFolder "$moduleName.psm1") -Value $sb.ToString()
}

task CopyAdditionalFiles {
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
        Copy-Item -Path "$SrcFolder/$($_.Path)" -Destination "$ModuleOutputFolder/$($_.Path)" -Recurse -Force
    }
}

task GenerateManifest EnsureFolders, {
    $manifest = @{
        Path = "$ModuleOutputFolder/$ModuleName.psd1"
        NestedModules = @()
        Guid = '585b8e60-7427-478c-ad52-43302e91c970'
        CompanyName = $CompanyName
        Copyright = $Copyright
        RootModule = "$ModuleName.psm1"
        ModuleVersion = $ModuleVersion
        Description =  "Martin's Personal Profile"
        # ProcessorArchitecture = 'MSIL'
        PowerShellVersion =  '7.0'
        # ClrVersion =  ''
        # DotNetFrameworkVersion =  ''
        # PowerShellHostName = ''
        # PowerShellHostVersion = ''
        RequiredModules =  @(
            @{
                ModuleName = 'PSReadline'
                ModuleVersion = '2.3.4'
            }
            @{
                ModuleName = 'Terminal-Icons'
                ModuleVersion = '0.11.0'
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
        FunctionsToExport = @($PublicScripts | ForEach-Object { $_.BaseName })
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
        # HelpInfoUri = ''
        PassThru = $false
        DefaultCommandPrefix = "Pro"
        WhatIf = $false
    }
    New-ModuleManifest @manifest
}

task CreateDevRepository -If { @(Get-PSResourceRepository | Where-Object Name -eq 'MartinsProfileDev').Count -eq 0 } {
    $null = New-Item $DevRepoPath -Force -ItemType Directory
    Register-PSResourceRepository -Name MartinsProfileDev -Uri $DevRepoPath -Trusted
}

task PublishLocal Build, CreateDevRepository, {
    Publish-PSResource -Path $ModuleOutputFolder -Repository MartinsProfileDev -SkipDependenciesCheck
}

task DevInstall RemoveLocal, Build, ImportLocal, {

}

task RemoveLocal {
    $null = Remove-Module MartinsProfile -ErrorAction SilentlyContinue
}

task ImportLocal {
    Import-Module $ModuleOutputFolder/MartinsProfile
}

task Rebuild Clean,Build
