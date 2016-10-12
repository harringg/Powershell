#PC to add to ARSL-RSA-SecurID-Computers-PA3060
$PCName = 'ARSNDFAR537BB82'
'ARSNDFAR40Y36V1','ARSNDFAR4224003','ARSNDFAR4719001','ARSNDFAR4930051','ARSNDFAR4930050','ARSNDFAR4819006','ARSNDFAR44BKH9'

#Location specific SmartCardExempt AD SecurityGroup

$SecurityGroup = 'ARSL-RSA-SecurID-Computers-PA3060'
$SecurityGroup = 'ARSL-SmartCardExempt-PA3060'
$SecurityGroup = 'ARSLNDFAR-CER-DFS-LAB-<SY>-MODIFY'
$SecurityGroup = 'ARS-PA-3060-AO-Staff'
Get-ADGroupMember $SecurityGroup | select Name | sort name

#Gather PC's EAD Attributes
$PCObject = Get-ADComputer -Identity $PCName

#Gather User's EAD Attributes
$UserName = read-host "User Name"
$UserObject = Get-ADUser -Identity $UserName

#Step 02 - Add PC to Location specific SecurityGroup
$PCObject.SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $SecurityGroup

#Step 02 - Add User to Location specific SecurityGroup
$UserObject.SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $SecurityGroup

Get-adgroupmember $SecurityGroup | sort Name | select Name

#Step 03 - Reboot PC
Restart-Computer -ComputerName $PCName -Force #SUCCESS

#Step 05 - Remove PC from Location specific SecurityGroup
$PCObject.SamAccountName | Remove-ADPrincipalGroupMembership -MemberOf $SecurityGroup

#Step 07 - Reboot PC
Restart-Computer -ComputerName $PCName -Force