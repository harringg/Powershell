# Remove all memberships from the user except for "Domain Users"
$GetUser.memberOf | Get-adgroup | where {$_.name -notmatch '^users|domain users$'} | Remove-ADGroupMember -Members $GetUser -WhatIf

$GetUser.SamAccountName
$GetUser.Manager
$GetUser.extensionAttribute1

# Workflow: Clear ADUser's Manager field and extensionattribute1 (in-house Attribute used for Lincpass/RSA SecurID designation)
Set-ADUser –Identity $GetUser -Clear Manager,extensionattribute1
# Workflow: Set ADUser to Disabled
Disable-ADAccount -Identity $GetUser

# Workflow: Move ADUser to EAD Disabled_Users OU
$DisabledUsersOU = 'OU=Disabled_Users,OU=_User_Mgmt,OU=ARS,OU=Agencies,DC=usda,DC=net'
Move-ADObject -Identity $GetUser -TargetPath $DisabledUsersOU

#$ThisUser = Get-ADUser -Identity $User -Properties extensionAttribute1
#Set-ADUser –Identity $ThisUser -add @{"extensionattribute1"="MyString"}  