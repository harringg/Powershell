cls
#[Modified, 7/12/2016 10:24 AM, Grant Harrington]
### Gathers version of multiple .SYS files located in C:\Windows\System32\drivers
$DRIVERSQuery = 'ubstore','srvnet'

#region Get-Item for all items in DLLQuery and add to Array
$DRIVERSItem_Array = @()

Foreach ($DRIVERS in $DRIVERSQuery) {
$DRIVERSPath = "C:\Windows\System32\drivers\{0}.sys" -f $DRIVERS
$DRIVERSItem = get-item $DRIVERSPath | select *
$DRIVERSItem_Array += $DRIVERSItem
}
#endregion

#region Gather the IP address (IPv4)
$IPAddress = Get-CimInstance Win32_NetworkAdapterConfiguration | select *
$IP = $IPAddress.ipaddress | where {$_ -like "*.*"}
#endregion



$DRIVERSCustomObj_Array = @()

$DRIVERSItem_Array | 

ForEach-Object {

$Date = get-date

$DRIVERSCustomObjProperties = [ORDERED]@{
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

$DRIVERSCustomObj = New-Object -TypeName PSCustomObject -Property $DRIVERSCustomObjProperties
$DRIVERSCustomObj_Array += $DRIVERSCustomObj
}
$DRIVERSCustomObj_Array | fl
