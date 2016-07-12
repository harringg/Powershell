# [Modified, 7/11/2016 4:33 PM, Grant Harrington]
# Checks version of ws2_32.dll

get-item "C:\Windows\System32\ws2_32.dll" |
select @{n='ComputerName';e={$env:COMPUTERNAME}},FullName,CreationTime,@{n='Version';e={$_.versioninfo.productversion}} | fl

# [Modified, 7/11/2016 5:22 PM, Grant Harrington]
# Modified from reference: https://blogs.technet.microsoft.com/askpfeplat/2014/12/07/how-to-correctly-check-file-versions-with-powershell/
$DLLVersionInfomation = (get-item $env:windir\System32\ws2_32.dll).VersionInfo | select *
$DLLVersionInfomation.FileName
$DLLVersionInfomation.ProductBuildPart
$DLLVersionInfomation.ProductPrivatePart

# Report for NESSUS comments field
$env:COMPUTERNAME
$DLLVersionInfomation.FileName
$DetailsProductVersion = "{0}.{1}.{2}.{3}" -f $DLLVersionInfomation.ProductMajorPart,$DLLVersionInfomation.ProductMinorPart,$DLLVersionInfomation.ProductBuildPart,$DLLVersionInfomation.ProductPrivatePart
$DetailsProductVersion

#[Modified, 7/12/2016 8:48 AM, Grant Harrington]
### Gathers version of multiple DLLs located in C:\Windows\System32
cls
#[Modified, 7/12/2016 9:51 AM, Grant Harrington]
### Gathers version of multiple DLLs located in C:\Windows\System32
$DLLQuery = 'oleaut32','ntdll','seclogon','mshtml','msxml3','ole32','gdi32','rpcrt4','gpprefcl','wdigest'

#region Get-Item for all items in DLLQuery and add to Array
$DLLItem_Array = @()

Foreach ($DLL in $DLLQuery) {
$DLLPath = "C:\Windows\System32\{0}.dll" -f $DLL
$DLLItem = get-item $DLLPath | select *
$DLLItem_Array += $DLLItem
}
#endregion

#region Gather the IP address (IPv4)
$IPAddress = Get-CimInstance Win32_NetworkAdapterConfiguration | select *
$IP = $IPAddress.ipaddress | where {$_ -like "*.*"}
#endregion



$DLLCustomObj_Array = @()

$DLLItem_Array | 

ForEach-Object {

$Date = get-date

$DLLCustomObjProperties = [ORDERED]@{
    'Computer Name' = $env:COMPUTERNAME
    'System Time' = $Date
    'IP Address' = $IP
    'FullName' = ($_.Fullname)
    'CreationTime' = ($_.CreationTime)
    'FileVersion' = ("{0}.{1}.{2}.{3}" -f $_.VersionInfo.ProductMajorPart,
                                    $_.VersionInfo.ProductMinorPart,
                                    $_.VersionInfo.ProductBuildPart,
                                    $_.VersionInfo.ProductPrivatePart)
    }

$DLLCustomObj = New-Object -TypeName PSCustomObject -Property $DLLCustomObjProperties
$DLLCustomObj_Array += $DLLCustomObj
}
$DLLCustomObj_Array | fl
