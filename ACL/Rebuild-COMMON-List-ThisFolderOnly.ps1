# [Modified, 7/15/2016 11:13 AM, Grant Harrington]
# Rebuild-COMMON-List-ThisFolderOnly.ps1

#CONSANT VARIABLES
$ScriptName = 'Rebuild-COMMON-List-ThisFolderOnly.ps1'
$Domain = 'USDA'
$RU = 'COMMON'
$Directory = 'COMMON'
$BaseFolder = "E:\Units\{0}" -f $RU
$ADUCSG_ListFolderOnly = "ARSLNDFAR-{0}-DFS-LIST" -f $Directory

$Date = get-date -f yyMMdd_HHmm
$OutFilePath = "C:\SCRIPTS"
$OutFileFile = "{0}\Logs\{1}_{2}_SetFolderRestrictions_Log.txt" -f $OutFilePath,$Date,$Directory

<#
#region Test Variables
$BaseFolder
$ADUCSG_ListFolderOnly
$OutFileFile
$TestBase = Test-Path $BaseFolder
$TestBase
$TestList = Get-ADGroup $ADUCSG_ListFolderOnly
$TestList
#endregion
#>

$startDate = get-date
$StartIcacls = icacls $BaseFolder
$StartLogMessage = "Started processing folder $BaseFolder $startdate"
Write-Verbose $ScriptName -Verbose
Write-verbose $StartLogMessage -Verbose
$StartIcacls
$ScriptName | Out-File $OutFileFile -Append
$StartLogMessage | Out-File $OutFileFile -Append
$StartIcacls | Out-File $OutFileFile -Append


#region Set List, This Folder Only
# This allows members of this group to "pass through" the $BaseFolder to the underlying files/folders
# LIST (GUI), $FileSystemRights = 'ReadAndExecute, Synchronize'
# Basic: Read & execute, List folder contents, Read
# Advanced: Traverse Folder / Execute File, List Folder / Read Data, Read Attributes, Read Extended Attributes, Read Permissions
# This Folder Only (GUI = ThisFolderOnly)
# $InheritanceFlags = 'None'
# $PropagationFlags = 'None'


$FileSystemRights = 'ReadAndExecute, Synchronize'
$AccessControlType = 'ALLOW'
$IdentityReference = "{0}\{1}" -f $Domain,$ADUCSG_ListFolderOnly
$IsInherited = 'False'
$InheritanceFlags = 'None'
$PropagationFlags = 'None'

$ACL = (Get-Item $BaseFolder).GetAccessControl('Access')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
$ACL.AddAccessRule($ACE) #TODO set vs add, which should be used
Set-Acl -Path $BaseFolder -AclObject $ACL 
#endregion

$EndDate = get-date
$EndIcacls = icacls $BaseFolder
$EndLogMessage = "Completed Processing $BaseFolder $enddate"
Write-verbose $EndLogMessage -Verbose
$EndIcacls
$EndIcacls | Out-File $OutFileFile -Append
$EndLogMessage | Out-File $OutFileFile -Append

<#
Clear-Variable Domain
Clear-Variable RU
Clear-Variable RUPrevious
Clear-Variable Directory
Clear-Variable BaseFolder
Clear-Variable ADUCSG_Remove
Clear-Variable ADUCSG_List
Clear-Variable ADUCSG_Modify
Clear-Variable Date
Clear-Variable OutFilePath
Clear-Variable OutFileFile
Clear-Variable StartDate
Clear-Variable StartIcacls
Clear-Variable StartLogMessage
Clear-Variable EndDate
Clear-Variable EndIcacls
Clear-Variable EndLogMessage
Clear-Variable ACL
Clear-Variable ACE
#>