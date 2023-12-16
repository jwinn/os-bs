# elevate powershell, if required
# https://stackoverflow.com/a/57035712/2441655

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent();
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator;

if (!$principal.IsInRole($adminRole)) {
    # run the script elevated--preserving the working dir
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

# update the Microsoft Store Apps
Get-CimInstance -Namespace root/CIMV2/mdm/dmmap -ClassName MDM_EnterpriseModernAppManagement_AppManagement01 | Invoke-CimMethod -MethodName UpdateScanMethod

# TBD: the above command schedules the updates and returns,
#      but doesn't wait for updates to complete
# Note: it may be ideal for the winget commands to run as the current user

# ensure the App Installer is installed, via the Microsoft Store

# update winget sources
winget source update

# install apps, via winget
