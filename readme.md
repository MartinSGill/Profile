# Martin's Profile

## Introduction

The profile I use for my own powershell sessions. Mostly this is just for my
personal use, but feel free to use it and/or derive inspiration from it for
your own profile.

## Recent Changes

### Version 1.3

* Add Switch-DarkMode to toggle Windows Dark/Light theme

### Version 1.2

* Windows Terminal fragments added 'Add-TerminalConfig'
* Converted Build to InvokeBuild
* Fixed & Improved DevContainer
* Added support for publishing to PSGallery

### Version 1.0

* Renamed to `MartinsProfile`
* Default Prefix changed to `Pro` for profile
* Complete re-structure of module
* Improvements to load performance
* Dependencies & Imports now handled by Manifest
* Removed a number of useless/obsolete functions
* Added build script

## Install

### Install Dependencies

```powershell
winget install --id JanDeDobbeleer.OhMyPosh
winget install --id voidtools.Everything
Install-PSResource -Name Terminal-Icons -Version 0.10.0
Install-PSResource -Name posh-git -Version 1.1.0
Install-PSResource -Name PSReadline -Version 2.2.0
```

### Install the Module

```powershell
Install-PSResource MartinsProfile
```

### Import the Module

```powershell
Import-Module MartinsProfile
```

### Update your Profile

If you want the module to load automatically every time, then update your
profile with the line above.

You can find your profile path with

```powershell
$PROFILE.CurrentUserAllHosts
```

## Troubleshooting

On Windows you can hold the "shift" key while starting the profile to enable
debug output.

Alternatively you can set `$env:MyProfileDebugMode` before attempting to import
the profile to enable debug output.

## Development

Ensure dependencies have been installed.

### Build the Module

```powershell
git clone https://github.com/MartinSGill/Profile.git
cd Profile
```

**Option 1:** Open in VsCode and then open in DevContainer

```powershell
code .
```

**Option 2:** Without DevContainer

```powershell
Install-PSResource InvokeBuild
Import-Module InvokeBuild
Invoke-Build DevInstall
```
