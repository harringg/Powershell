﻿#$Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
#$Path = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
$Path = 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
$Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP'
$Path = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
$Path = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'

function Test-RegistryValue {

param (

 [parameter(Mandatory=$false)]
 [ValidateNotNullOrEmpty()]$Path,

[parameter(Mandatory=$false)]
 [ValidateNotNullOrEmpty()]$Value
)

try {

Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
 return $true
 }

catch {

return $false

}

}


Invoke-Command -ComputerName NP42-SSANNCSL -Credential 'fargo\administrator' -ScriptBlock  {Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'}
Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'

Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion | Select-Object -ExpandProperty Property

Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce | Select-Object -ExpandProperty Property

Get-Item -Path Registry::'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP'| Select-Object -ExpandProperty Property

get-item -Path $path

Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion -Name PSHome
Remove-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion -Name PowerShellPath



Invoke-Command -ComputerName $Computer -ScriptBlock { Remove-ItemProperty -Path 'HKLM:System\CurrentControlSet\Services\NTFRS\Parameters\Backup/Restore\Process at Startup'-Name 'BurFlags' }
      Invoke-Command -ComputerName $Computer -ScriptBlock { New-ItemProperty -Path 'HKLM:System\CurrentControlSet\Services\NTFRS\Parameters\Backup/Restore\Process at Startup'-Name 'BurFlags' -Value '210' -PropertyType "DWORD" }
      [string]$BurFlagsKeyValue =  Invoke-Command -ComputerName $Computer -ScriptBlock ({ Get-ItemProperty -Path 'HKLM:System\CurrentControlSet\Services\NTFRS\Parameters\Backup/Restore\Process at Startup'-Name 'BurFlags' }).BurFlags
      Write-OutPut "Burflags is set to $BurFlagsKeyValue on $Computer `r "



Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'

help Get-ItemProperty -ShowWindow


# 160426 Change RequireSecuritySignature and EnableSecuritySignature from 1 to 0 to allow users to mount Drobo Drive
$Path = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'

Name                           Property                                                                                                                                                       
----                           --------                                                                                                                                                       
Parameters                     ServiceDllUnloadOnStop   : 1                                                                                                                                   
                               RequireSecuritySignature : 1                                                                                                                                   
                               EnableSecuritySignature  : 1                                                                                                                                   
                               EnablePlainTextPassword  : 0                                                                                                                                   
                               ServiceDll               : C:\WINDOWS\System32\wkssvc.dll                                                                                                      
                               OtherDomains             : {}                                                                                                                                  



$ReqSecSignature = 'RequireSecuritySignature'
$EnableSecSignature = 'EnableSecuritySignature'
$Value = '0' 
$PropertyType = 'DWORD'

New-ItemProperty -Path $Path 

Invoke-Command -ComputerName $Computer -ScriptBlock { 
    
    Remove-ItemProperty -Path 'HKLM:System\CurrentControlSet\Services\NTFRS\Parameters\Backup/Restore\Process at Startup'-Name 'BurFlags' }

Invoke-Command -ComputerName $Computer -ScriptBlock { 

    New-ItemProperty -Path 'HKLM:System\CurrentControlSet\Services\NTFRS\Parameters\Backup/Restore\Process at Startup'-Name 'BurFlags' -Value '210' -PropertyType "DWORD" }

    [string]$BurFlagsKeyValue =  Invoke-Command -ComputerName $Computer -ScriptBlock 
    ({ Get-ItemProperty -Path 'HKLM:System\CurrentControlSet\Services\NTFRS\Parameters\Backup/Restore\Process at Startup'-Name 'BurFlags' }).BurFlags
      Write-OutPut "Burflags is set to $BurFlagsKeyValue on $Computer `r "


$Path = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
Get-Item -Path $path
Push-Location
Set-Location $Path
Set-ItemProperty . EnableSecuritySignature "0"
Set-ItemProperty . RequireSecuritySignature "0"
Pop-Location


PS C:\WINDOWS\system32> Get-Item -Path $path


    Hive: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation


Name                           Property                                                                                                                                                                  
----                           --------                                                                                                                                                                  
Parameters                     ServiceDllUnloadOnStop   : 1                                                                                                                                              
                               RequireSecuritySignature : 1                                                                                                                                              
                               EnableSecuritySignature  : 0                                                                                                                                              
                               EnablePlainTextPassword  : 0                                                                                                                                              
                               ServiceDll               : C:\WINDOWS\System32\wkssvc.dll                                                                                                                 
                               OtherDomains             : {}                


Push-Location #Records the current network path
$Path = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
Set-Location $Path
Pop-Location #Restores the network path recorded in Push-Location

Get-Item -Path $path
Get-ItemProperty -Path $Path
Get-ItemPropertyValue -Path $path
Get-ChildItem -Path $path | select @{N="SID";E={($_.Property).State}}
Get-ChildItem -Path $path | % { Get-ItemProperty $_.pspath} | select ProfileImagePath,PSChildName

    Hive: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation


Name                           Property                                                                                                                                                                                                                                        
----                           --------                                                                                                                                                                                                                                        
Parameters                     ServiceDllUnloadOnStop   : 1                                                                                                                                                                                                                    
                               RequireSecuritySignature : 0                                                                                                                                                                                                                    
                               EnableSecuritySignature  : 0                                                                                                                                                                                                                    
                               EnablePlainTextPassword  : 0                                                                                                                                                                                                                    
                               ServiceDll               : C:\WINDOWS\System32\wkssvc.dll                                                                                                                                                                                       
                               OtherDomains             : {}                                                                                                                                                                                                                   

###
#[Modified, 8/5/2016 3:11 PM, Grant Harrington]
https://connect.microsoft.com/PowerShell/feedback/details/1609288/pin-to-taskbar-no-longer-working-in-windows-10

Removing Edge / Store icons is somewhat tricky. I usually do it right after the OSD by modifying the HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband key and then restarting the explorer process:

Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband]
"Favorites"=hex:ff
"FavoritesChanges"=dword:00000015
"FavoritesVersion"=dword:00000002
"FavoritesRemovedChanges"=dword:00000001