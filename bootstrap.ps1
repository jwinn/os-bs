# elevate powershell, if required
# https://stackoverflow.com/a/57035712/2441655

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent();
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator;

$appStoreUpdate = "Get-CimInstance -Namespace root/CIMV2/mdm/dmmap -ClassName MDM_EnterpriseModernAppManagement_AppManagement01 | Invoke-CimMethod -MethodName UpdateScanMethod"

# update the Microsoft Store Apps
if (!$principal.IsInRole($adminRole)) {
    Start-Process PowerShell $appStoreUpdate
} else ($principal.IsInRole($adminRole)) {
    Start-Process PowerShell -Verb RunAs $appStoreUpdate
}
# TBD: the above command schedules the updates and returns,
#      but doesn't wait for updates to complete
# Note: it may be ideal for the winget commands to run as the current user

# ensure the App Installer is installed, via the Microsoft Store

# update winget sources
winget source update

# install apps, via winget
winget install --exact --id AutoHotkey.AutoHotkey --version 1.1.37.01
winget install Brave.Brave
winget install Discord.Discord
winget install DominikReichl.KeePass
winget install EpicGames.EpicGamesLauncher
winget install GOG.Galaxy
winget install Git.Git
winget install Google.Chrome
winget install LizardByte.Sunshine
winget install Logitech.OptionsPlus
winget install Microsoft.VisualStudioCode
winget install Microsoft.WindowsTerminal
winget install MoonlightGameStreamingProject.Moonlight
winget install Mozilla.Firefox
winget install Parsec.Parsec
winget install Valve.Steam
winget install VMware.WorkstationPlayer

# TBD: dotfiles?
# TBD: Windows Subsystem for Linux (WSL) install?
# TBD: configure settings?
