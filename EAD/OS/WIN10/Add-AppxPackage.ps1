#[Modified, 8/5/2016 2:48 PM, Grant Harrington]
# Reinstall built-in applications
Get-AppxPackage -AllUsers| Foreach {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation)\AppXManifest.xml”}