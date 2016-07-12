cls
#[Modified, 7/12/2016 10:30 AM, Grant Harrington]
### Gathers version of multiple .EXE files located in C:\Windows\System32
$EXEQuery = 'ntoskrnl'

#region Get-Item for all items in DLLQuery and add to Array
$EXEItem_Array = @()

Foreach ($EXE in $EXEQuery) {
$EXEPath = "C:\Windows\System32\{0}.exe" -f $EXE
$EXEItem = get-item $EXEPath | select *
$EXEItem_Array += $EXEItem
}
#endregion

#region Gather the IP address (IPv4)
$IPAddress = Get-CimInstance Win32_NetworkAdapterConfiguration | select *
$IP = $IPAddress.ipaddress | where {$_ -like "*.*"}
#endregion



$EXECustomObj_Array = @()

$EXEItem_Array | 

ForEach-Object {

$Date = get-date

$EXECustomObjProperties = [ORDERED]@{
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

$EXECustomObj = New-Object -TypeName PSCustomObject -Property $EXECustomObjProperties
$EXECustomObj_Array += $EXECustomObj
}
$EXECustomObj_Array | fl
