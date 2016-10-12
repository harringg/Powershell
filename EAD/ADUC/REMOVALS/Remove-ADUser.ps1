#[Modified, 10/12/2016 5:12 PM, Grant Harrington]
#Based on GUI workflow in ADManager
#https://arsitwiki.usda.net/mediawiki/index.php/EAD_Disable_an_Account

#0. Audit existing settings
."C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\AUDIT\Audit-ADUser.ps1"
$OutgoingEmployee = Read-Host "Enter First.Last"
Audit-ADUser -SearchUser $OutgoingEmployee -SearchBase PA3060

#0.a Move Files to Supervisor's directory
# TO DO

$ExportPath = "\\10.170.180.2\Public\IT\Shared Knowledge\EMPLOYEE RECORDS\OUTGOING\AUDIT RECORDS"
$RU = Read-Host "Enter RU"
$Date = get-date -f yyMMdd_HHmm
$ExportCSVFile = "{0}\{1}-{2}-{3}.csv" -f $ExportPath,$RU,$OutgoingEmployee,$Date
$ObjAccountReview | Export-Csv $ExportCSVFile -NoTypeInformation

#1. Account Tab (EAD)
$GetUser = Get-ADUser $OutgoingEmployee -Properties *

#2. Change Password
."C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\POSHTOOLS\Create-Password.ps1"

$ResetPassword = ConvertTo-SecureString -string $RandomPassword -AsPlainText -force
Set-ADAccountPassword -Identity $GetUser -Reset -NewPassword $ResetPassword -Verbose

#3. Set Account Disabled checkbox
# Workflow: Set ADUser to Disabled
Disable-ADAccount -Identity $GetUser

#4. Remove all groups from the user
# Remove all memberships from the user except for "Domain Users"
$GetUser.memberOf | Get-adgroup | where {$_.name -notmatch '^users|domain users$'} | Remove-ADGroupMember -Members $GetUser -WhatIf
$GetUser.memberOf | Get-adgroup | where {$_.name -notmatch '^users|domain users$'} | Remove-ADGroupMember -Members $GetUser -Verbose

#4.a Clear Manager Field and Custom Attributes
# Workflow: Clear ADUser's Manager field and extensionattribute1 (in-house Attribute used for Lincpass/RSA SecurID designation)
Set-ADUser –Identity $GetUser -Clear Manager,extensionattribute1

#5. Move to Disabled_Users
# Workflow: Move ADUser to EAD Disabled_Users OU
$DisabledUsersOU = 'OU=Disabled_Users,OU=_User_Mgmt,OU=ARS,OU=Agencies,DC=usda,DC=net'
Move-ADObject -Identity $GetUser -TargetPath $DisabledUsersOU

<#
$GetUser.SamAccountName
$GetUser.Manager
$GetUser.extensionAttribute1
#>