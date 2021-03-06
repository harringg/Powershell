﻿# [Modified, 7/15/2016 11:55 AM, Grant Harrington]
# Rebuild-COMMON-RU-ListThisFolderOnly-ModifySubfoldersAndFilesOnly.ps1

#CONSANT VARIABLES
$ScriptName = 'Rebuild-COMMON-RU-ListThisFolderOnly-ModifySubfoldersAndFilesOnly.ps1'
$Domain = 'USDA'
$RU = 'OCD'
$Directory = 'COMMON'
$BaseFolder = "E:\Units\{0}\{1}" -f $Directory,$RU
$ADUCSG_List = "ARSLNDFAR-{0}-DFS-LIST" -f $RU
$ADUCSG_Modify = "ARSLNDFAR-{0}-DFS-MODIFY" -f $RU

$Date = get-date -f yyMMdd_HHmm
$OutFilePath = "C:\SCRIPTS"
$OutFileFile = "{0}\Logs\{1}_{2}_SetFolderRestrictions_Log.txt" -f $OutFilePath,$Date,$RU

<#
#region Test Variables
$BaseFolder
$ADUCSG_Remove
$ADUCSG_List
$ADUCSG_Modify
$OutFileFile
$TestBase = Test-Path $BaseFolder
$TestBase
$TestRemove = Get-ADGroup $ADUCSG_Remove
$TestRemove
$TestList = Get-ADGroup $ADUCSG_List
$TestList
$TestModify = Get-ADGroup $ADUCSG_Modify
$TestModify
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
$IdentityReference = "{0}\{1}" -f $Domain,$ADUCSG_List
$IsInherited = 'False'
$InheritanceFlags = 'None'
$PropagationFlags = 'None'

$ACL = (Get-Item $BaseFolder).GetAccessControl('Access')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
$ACL.AddAccessRule($ACE) #TODO set vs add, which should be used
Set-Acl -Path $BaseFolder -AclObject $ACL 
#endregion
#>

#region Set Modify, Subfolders and Files
# This allows users to Edit,Add,Delete all files/folders under the $BaseFolder	
# Modify (GUI), $FileSystemRights = 'Modify, Synchronize'
# Basic: Modify, Read & execute, List folder contents, Read, Write
# Advanced: Traverse Folder / Execute File, List Folder / Read Data, Read Attributes, Read Extended Attributes, Create Files / Write Data, Write Attributes, Write Extended Attributes, Delete, Read Permissions
# Subfolders and Files Only (GUI = SubfoldersAndFilesOnly)
# $InheritanceFlags = 'ContainerInherit, ObjectInherit'
# $PropagationFlags = 'InheritOnly'

$FileSystemRights = 'Modify, Synchronize'
$AccessControlType = 'ALLOW'
$IdentityReference = "{0}\{1}" -f $Domain,$ADUCSG_Modify
$IsInherited = 'False'
$InheritanceFlags = 'ContainerInherit, ObjectInherit'
$PropagationFlags = 'InheritOnly'

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