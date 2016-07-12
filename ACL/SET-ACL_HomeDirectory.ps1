#[Modified, 7/12/2016 2:56 PM, Grant Harrington]

$UserNameList = Import-Csv "C:\SCRIPTS\XDrive_ACLs-AG.csv"
<#
Data is generated using: ADUCUserHomeDirectory.ps1
In Excel, HomeDirectory = \\path\path1\path2\first.last
Find/replace \\path\path1\path2\, leaving first.last

SamAccountName,HomeDirectory
First.Last,First.Last
First.Last,LastF
#>

foreach ($Username in $UserNameList) {
$RUFolder = "Z:\Units\USERS\$($UserName.HomeDirectory)"
$startDate = get-date
$StartScreen = Write-Host "Started processing folder $RUFolder $startdate"
$StartScreen
$StartLog = "Started processing folder $RUFolder $startdate"
$StartLog | Out-File "C:\Scripts\Logs\ACL-Batch.txt" -Append
icacls $RUFolder

$FileSystemRights = 'FullControl'
$AccessControlType = 'Allow'
$IdentityReference = "USDA\$($UserName.SamAccountName)"
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
$icacls | Out-File "C:\Scripts\Logs\ACL-Batch.txt" -Append
$endLog | Out-File "C:\Scripts\Logs\ACL-Batch.txt" -Append
}
