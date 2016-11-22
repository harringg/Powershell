Push-Location #Records the current network path
$PulseInstallerPath = '\\usda.net\ars\PA3060\INSTALLERS\JUNIPER_VPN'
$PulseFolderName = 'Juniper_JunosPulse_5.1.61601'
$PulseExe = 'JunosPulse.x64.msi'
$JNPRPreconfigFile = 'LincPass.jnprpreconfig'
$InstallerRoot = "{0}\{1}" -f $PulseInstallerPath,$PulseFolderName

Set-Location $InstallerRoot

& msiexec /i $PulseExe CONFIGFILE=$JNPRPreconfigFile ALLUSERS=1 /qn /norestart /log output.log
Pop-Location #Restores the network path recorded in Push-Location