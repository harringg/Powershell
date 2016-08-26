#[Modified, 8/26/2016 9:59 AM, Grant Harrington]
$NewADUser = 'first.last'
$MoveUser = Get-aduser $NewADUser
$MangerName = 'first.last'
$Manager = Get-ADUser $MangerName
$RU = 'ANS'
$MoveTo = "OU=Users,OU={0},OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net" -f $RU

Move-ADObject -Identity $MoveUser -TargetPath $MoveTo -Verbose

#Rerun (now in new OU)
$MoveUser = Get-aduser $NewADUser -Properties Manager,MemberOf

Set-ADUser -Identity $MoveUser -Manager $Manager -WhatIf
Set-ADUser -Identity $MoveUser -Manager $Manager -Verbose

#Rerun (now has new Manager)
$MoveUser = Get-aduser $NewADUser -Properties Manager

$SecurityGroup = "ARSGNDFAR-{0}-GROUP-ALL" -f $RU
$MoveUser.MemberOf
$MoveUser.SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $SecurityGroup 
