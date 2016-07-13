#[Modified, 7/12/2016 7:16 PM, Grant Harrington]

$SNAPDriveModify = Import-CSV "C:\SCRIPTS\Units-Snap-ANS-IGB.CSV"
#RUFolder,IdentityReference
foreach ($RU in $SNAPDriveModify) {
$RUFolder = "$($RU.RUFolder)"
$startDate = get-date
$StartScreen = Write-Host "Started processing folder $RUFolder $startdate"
$StartScreen
$StartLog = "Started processing folder $RUFolder $startdate"
$StartLog | Out-File "C:\Scripts\Logs\ACL-SNAP-ANS-IGB.txt" -Append
icacls $RUFolder

$FileSystemRights = 'Modify, Synchronize'
$AccessControlType = 'ALLOW'
$IdentityReference = "$($RU.IdentityReference)"
$IsInherited = 'False'
$InheritanceFlags = 'ContainerInherit, ObjectInherit'
$PropagationFlags = 'None'

$ACL = (Get-Item $RUFolder).GetAccessControl('Access')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
$ACL.AddAccessRule($ACE) 
Set-Acl -Path $RUFolder -AclObject $ACL

$endDate = get-date
$endScreen = Write-Host "Completed Processing $RUFolder $enddate"
$endScreen
$endLog = "Completed Processing $RUFolder $enddate"
$icacls = icacls $RUFolder
$icacls | Out-File "C:\Scripts\Logs\ACL-SNAP-ANS-IGB.txt" -Append
$endLog | Out-File "C:\Scripts\Logs\ACL-SNAP-ANS-IGB.txt" -Append
}
