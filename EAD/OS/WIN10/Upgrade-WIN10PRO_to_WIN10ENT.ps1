#[Modified, 8/11/2016 11:32 AM, Grant Harrington]
#TODO: Convert to Advanced Function
#TODO: Allow for batch input of PC names
#TODO: Check for existing OS
#Get-CimInstance Win32_OperatingSystem -ComputerName ARSNDFAR4CJHKB2
#Get-WmiObject Win32_OperatingSystem -ComputerName ARSNDFAR4CJHKB2 -Property *
#Get-WmiObject Win32_system -ComputerName ARSNDFAR4CJHKB2 -Property *

#Get-CimInstance Win32_OperatingSystemAutochkSetting
#PC to upgrade from WIN 10 PRO to WIN 10 ENT
$PCName = 'ARSNDFAR5P0XNK3'
$PCName = 'ARSNDFAR4806072'
$PCName = 'ARSNDFAR517114F'

#Location specific SmartCardExempt AD SecurityGroup
$SecurityGroup = 'ARSL-SmartCardExempt-PA3060'
#Location specific USGCB Test OU
$ExemptOU = 'OU=USGCB Test,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net'
#Gather PC's EAD Attributes
$PCObjectHome = Get-ADComputer -Identity $PCName
#Using REGEX, create the "Home" OU (where the PC was prior to moving to ExemptOU
$HomeOU = $PCObjectHome.DistinguishedName -replace 'CN=[A-Z0-9]{15},',''

$VLAEntKey = '<FILL IN WITH YOUR VLA KEY>'

#Step 01 - Move PC from "Home" OU to Location specific USGCB Test OU
Move-ADObject -Identity $PCObjectHome.DistinguishedName -TargetPath $ExemptOU

#Step 02 - Add PC to Location specific SmartCardExempt AD SecurityGroup
$PCObjectHome.SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $SecurityGroup


#Step 03 - Reboot PC
Restart-Computer -ComputerName $PCName -Force #SUCCESS

#Pauses script to allow for PC to comeback online before measuring PING
Start-Sleep -Seconds 60

#TODO: Make a while-do loop to automate script
Test-Connection -ComputerName $PCName -Count 100


#Step 04 - Set Key and Edition
#TODO
#USE PSSessions
#See GHGet-OSInfo.ps1 for details/specifics

#Dism /online /set-edition:Enterprise /AcceptEula /ProductKey:YNJFD-XT2CY-WJW7H-MM2QF-W8F8R

#$computer = gc env:computername
#$key = "<FILL IN WITH YOUR VLA KEY>"
#$service = get-wmiObject -query “select * from SoftwareLicensingService” -computername $computer
#$service.InstallProductKey($key)
#$service.RefreshLicenseStatus()

Set-WindowsEdition -Edition Enterprise
Set-WindowsProductKey -ProductKey $VLAEntKey

#Step 05 - Remove PC from Location specific SmartCardExempt AD SecurityGroup
$PCObjectHome.SamAccountName | Remove-ADPrincipalGroupMembership -MemberOf $SecurityGroup

#Step 06 - Move PC from Location specific USGCB Test OU to "Home" OU
#Step 06.a This is getting the current Location of the Comptuer Object
$PCObjectExempt = Get-ADComputer -Identity $PCName
Move-ADObject -Identity $PCObjectExempt.DistinguishedName -TargetPath $HomeOU

#Step 07 - Reboot PC
Restart-Computer -ComputerName $PCName -Force