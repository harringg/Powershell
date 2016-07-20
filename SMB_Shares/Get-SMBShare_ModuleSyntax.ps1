Get-SmbClientConfiguration
Get-SmbClientNetworkInterface
.\Get-SMBShare.ps1
Get-SmbShare | select *

New-SmbShare -ContinuouslyAvailable -FolderEnumerationMode 

Get-SmbShare | select * -first 1 | fl

Get-SmbShare -Name M300 | select presetpathacl
(Get-SmbShare -Name M300).PresetPathAcl

$M300Share = (Get-SmbShare -Name M300)
$M300Share | select *
$M300Share.CATimeout
$M300Share.CimClass
$M300Share.CimInstanceProperties
$M300Share.CimSystemProperties
$M300Share.ConcurrentUserLimit
$M300Share.ContinuouslyAvailable
$M300Share.CurrentUsers
$M300Share.Description
$M300Share.EncryptData
$M300Share.Name
$M300Share.Path
$M300Share.PSComputerName
$M300Share.Scoped
$M300Share.ScopeName
$M300Share.SecurityDescriptor
$M300Share.ShadowCopy
$M300Share.Special
$M300Share.Temporary
$M300Share.Volume
$M300Share.AvailabilityType
$M300Share.CachingMode
$M300Share.FolderEnumerationMode 
$M300Share.PresetPathAcl
$M300Share.ShareState
$M300Share.ShareType
$M300Share.SmbInstance

$M300Share