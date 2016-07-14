#[Modified, 7/12/2016 7:16 PM, Grant Harrington]
#[Modified, 7/14/2016 2:24 PM, Grant Harrington]

$Date = get-date -f yyMMdd_HHmm
$ImportCSVPath = "C:\SCRIPTS"
$ImportCSVFile = "Units-Snap-ANS-IGB"
$ImportCSV = "{0}\{1}.csv" -f $ImportCSVPath,$ImportCSVFile
$SNAPDriveModify = Import-Csv $ImportCSV
$OutFileFile = "{0}\Logs\{1}_{2}_Log.txt" -f $ImportCSVPath,$Date,$ImportCSVFile

<#
RUFolder,IdentityReference
"E:\Units\Animals\Snap","USDA\ARSLNDFAR-ANS-DFS-MODIFY"
#>

foreach ($RU in $SNAPDriveModify) {
$RUFolder = "$($RU.RUFolder)"
$startDate = get-date
$StartScreen = Write-Host "Started processing folder $RUFolder $startdate"
$StartScreen
$StartLog = "Started processing folder $RUFolder $startdate"
$StartLog | Out-File $OutFileFile -Append
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
$icacls | Out-File $OutFileFile -Append
$endLog | Out-File $OutFileFile -Append
}