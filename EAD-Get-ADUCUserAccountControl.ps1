Get-ADUser -Filter {sAMAccountName -like "*LastName*"} -Properties * | Select Name, UserAccountControl,SmartCardLogonRequired | ft -AutoSize

Get-ADComputer -Filter {sAMAccountName -eq 'COMPUTERNAME$'} -Properties * | Select Name, OperatingSystem, UserAccountControl | ft -AutoSize

# http://www.netvision.com/ad_useraccountcontrol.php
# https://support.microsoft.com/en-us/kb/305144

$AllDomainPCs = Get-ADComputer -Filter * -Properties *

foreach ($PC in $AllDomainPCs) {
    $PC | Select Name, OperatingSystem, UserAccountControl
    }

$AllDomainUsers = Get-ADUser -Filter * -Properties *

foreach ($User in $AllDomainUsers) {
    $User | Select Name, UserAccountControl,SmartCardLogonRequired
    }
