#http://www.powershelladmin.com/wiki/Find_last_boot_up_time_of_remote_Windows_computers_using_WMI
$PCName = 'ARSNDFAR5WHRDZ1'
$LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Comp $PCName | Select -Exp LastBootUpTime
Write-host "Last Boot Time for: $PCName"
[System.Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)