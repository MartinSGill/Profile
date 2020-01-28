trap { Write-Warning ($_.ScriptStackTrace | Out-String) }
# This timer is used by Trace-Message, I want to start it immediately
$TraceVerboseTimer = New-Object System.Diagnostics.Stopwatch
$TraceVerboseTimer.Start()
${;} = [System.IO.Path]::PathSeparator
# The job of the profile script is to:
# 1. Fix the PSModulePath and then
# 2. Import the Profile module (which this script is part of, technically)

## Set the profile directory first, so we can refer to it from now on.
Set-Variable ProfileDir (Split-Path $Profile.CurrentUserAllHosts -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue

$Env:PSModulePath = @(
    # Prioritize "this" location (probably CloudDrive, but possibly my Projects folder)
    @(Split-Path $PSScriptRoot) +
    # The normal FIRST module location is where the "real" profile lives
    @(Join-Path $ProfileDir Modules | Convert-Path) +
    @($Env:PSModulePath -split ${;}) +
    # Ever an optimist, I'll include the _other_ PowerShell\Modules path too
    @(Split-Path $ProfileDir | Join-Path -ChildPath *PowerShell\Modules | Convert-Path) +
    # The "right" one of these is already in the Env:PSModulePath, but just in case
    @(Join-Path $PSHome Modules | Convert-Path) +
    # Here we guaranteeing that all the PSHome\Modules are there
    @(Split-Path $PSHome | Split-Path | Join-Path -ChildPath *PowerShell\Modules | Convert-Path) +
    @(Split-Path $PSHome | Join-Path -ChildPath *\Modules | Convert-Path) +
    # Guarantee my ~\source\PSModules are there so I can load my dev projects
    @("$Home\source\PSModules") | Select-Object -Unique
) -join ${;}

# Note these are dependencies of the Profile module, but it's faster to load them explicitly up front
Import-Module -FullyQualifiedName   @{ ModuleName="Environment";      ModuleVersion="1.1.0" },
                                    @{ ModuleName="Configuration";    ModuleVersion="1.3.1" },
                                    @{ ModuleName="Pansies";          ModuleVersion="1.4.0" },
                                    @{ ModuleName="PowerLine";        ModuleVersion="3.1.1" },
                                    @{ ModuleName="posh-git";         ModuleVersion="1.0.0" },
                                    @{ ModuleName="PSReadLine";       ModuleVersion="2.0.0" } # -Verbose:$false

# If it's Windows PowerShell, we can turn on Verbose output if you're holding shift
if ("Desktop" -eq $PSVersionTable.PSEdition) {
    # Check SHIFT state ASAP at startup so I can use that to control verbosity :)
    Add-Type -Assembly PresentationCore, WindowsBase
    try {
        if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -OR
            [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
            $VerbosePreference = "Continue"
        }
    } catch {
        # If that didn't work ... oh well.
    }
}

Import-Module -FullyQualifiedName @{ ModuleName = "Profile"; ModuleVersion = "1.4.2" } -Verbose:$false

# First call to Trace-Message, pass in our TraceTimer that I created at the top to make sure we time EVERYTHING.
# This has to happen after the verbose check, obviously
Trace-Message "Modules Imported" -Stopwatch $TraceVerboseTimer

# I prefer that my sessions start in a predictable location, regardless of elevation, etc.
if ($psEditor.Workspace.Path) { # in VS Code, start in the workspace!
    Set-Location $psEditor.Workspace.Path
}

Set-InvokeBuildCompleters

# Set error message format.
$global:ErrorView = "ConciseView"

Trace-Message "Profile Finished!" -KillTimer
Remove-Variable TraceVerboseTimer

## Relax the code signing restriction so we can actually get work done
Set-ExecutionPolicy RemoteSigned Process
$VerbosePreference = "SilentlyContinue"
