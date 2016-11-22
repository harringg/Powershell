 #################################### Assumed Actions ###########################################
## This script is running on a computer that is known to have the sofware we're looking for on it
################################################################################################


## Use the SCCM WMI class SMS_InstalledSoftware to see if the software is registered there
$InstalledProducts = Get-WmiObject -Namespace 'root\cimv2\sms' -Class SMS_InstalledSoftware -ComputerName localhost
## To review the installed products (optional)
$InstalledProducts | Sort ProductName | select ProductName,ProductVersion

## To look at all the available fields you can filter on
$InstalledProducts | select * -First 1

## Partial name of software title you are looking for
$SoftwareSearch = "pulse"
$SoftwareResults = $InstalledProducts | where { $_.ARPDisplayName -imatch $SoftwareSearch } | Select ARPDisplayName,LocalPackage,ProductVersion,Publisher,UninstallString,SoftwareCode
$Java = $InstalledProducts | Select ARPDisplayName,LocalPackage,ProductVersion,Publisher,UninstallString,SoftwareCode
$SoftwareResults

# Product name = ARPDisplayName
# Location of cached MSI = LocalPackage
# Product Version = ProductVersion
# Publisher = Publisher
# Uninstall String = UninstallString
# GUID = SoftwareCode

#To confirm your selecting the correct software package, run this command
$Java.ARPDisplayName[0]
$Java.ProductVersion[0]

$RemoveJava= $InstalledProducts | where { ($_.ARPDisplayName -eq "$($Java.ARPDISPLAYNAME[0])") -and ($_.ProductVersion -eq "$($Java.ProductVersion[0])") }
 
## Create the code to put in our software upgrade script
## To make the uninstall silent an extremely common set of switches for msiexec is /qn (quiet with no interface)
$CachedMSI = $RemoveJava.LocalPackage

## The cached MSI's path is always in the LocalPackage property under each instance in SMS_InstalledSoftware
## /x = Uninstall
## /qn = (q) all defaults (n) no UI appears

#Start-Process 'msiexec.exe' -ArgumentList "/x $CachedMSI /qn" -Wait -NoNewWindow