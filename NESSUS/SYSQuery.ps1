cls
#[Modified, 7/12/2016 10:16 AM, Grant Harrington]
### Gathers version of multiple .SYS files located in C:\Windows\System32
$SYSQuery = 'win32k'

#region Get-Item for all items in DLLQuery and add to Array
$SYSItem_Array = @()

Foreach ($SYS in $SYSQuery) {
$SYSPath = "C:\Windows\System32\{0}.sys" -f $SYS
$SYSItem = get-item $SYSPath | select *
$SYSItem_Array += $SYSItem
}
#endregion

#region Gather the IP address (IPv4)
$IPAddress = Get-CimInstance Win32_NetworkAdapterConfiguration | select *
$IP = $IPAddress.ipaddress | where {$_ -like "*.*"}
#endregion



$SYSCustomObj_Array = @()

$SYSItem_Array | 

ForEach-Object {

$Date = get-date

$SYSCustomObjProperties = [ORDERED]@{
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

$SYSCustomObj = New-Object -TypeName PSCustomObject -Property $SYSCustomObjProperties
$SYSCustomObj_Array += $SYSCustomObj
}
$SYSCustomObj_Array | fl
