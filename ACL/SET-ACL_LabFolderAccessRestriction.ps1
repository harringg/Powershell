# [Modified, 7/14/2016 8:26 PM, Grant Harrington]
# This is the format for removing RU's Modify ACL on Sub (In this case a LAB folder)
# E:\Units\COMMON\CER\LAB-FARIS

# Animals, ANS
# Cereals, CER
# Insects, IGB
# Potatoes, SUG
# Sunflowers, SPB

#CONSANT VARIABLES
$Domain = 'USDA'
$RU = 'CER'
$RUPrevious = 'Cereals'
$Directory = 'LAB-FARIS' #'PII'
$BaseFolder = "E:\Units\{0}\Snap\{1}" -f $RUPrevious,$Directory
#$RUFolder = "E:\Units\COMMON\{0}\{1}" -f $RU,$Directory
$ADUCSG_Remove = "ARSLNDFAR-{0}-DFS-MODIFY" -f $RU
$ADUCSG_List = "ARSLNDFAR-{0}-DFS-{1}-LIST" -f $RU,$Directory
$ADUCSG_Modify = "ARSLNDFAR-{0}-DFS-{1}-MODIFY" -f $RU,$Directory

$Date = get-date -f yyMMdd_HHmm
$OutFilePath= "C:\SCRIPTS"
$OutFileFile = "{0}\Logs\{1}_{2}_SetFolderRestrictions_Log.txt" -f $OutFilePath,$Date,$Directory

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

$startDate = get-date
$StartScreen = Write-Host "Started processing folder $BaseFolder $startdate"
$StartScreen
$StartIcacls = icacls $BaseFolder
$StartLog = "Started processing folder $BaseFolder $startdate"
$StartIcacls
$StartLog | Out-File $OutFileFile -Append
$StartIcacls | Out-File $OutFileFile -Append

# STEP 01
# THIS SETS BASE FOLDER TO <not inherited> AND KEEPS ALL EXISTING PERMISSIONS
$ACL = Get-ACL -Path $BaseFolder
# First Value: $TRUE = BLOCK INHERITANCE (aka Protect), $FALSE = ALLOW INHERITANCE (aka Do not Protect)
# Second Value: $TRUE = KEEP EXISTING ACE(s) (Access Control Entries), $FALSE = REMOVE ALL ACE(s) (Start from 'scratch') 
$ACL.SetAccessRuleProtection($True, $True)
Set-Acl -Path $BaseFolder -AclObject $ACL

#STEP 02
# THIS REMOVES THE ADUC SG FROM THE PARENT AND SUB-FOLDERS
$AccessControlType = 'ALLOW'
$IdentityReference = "{0}\{1}" -f $Domain,$ADUCSG_Remove
$FileSystemRights ='Modify, Synchronize'
$IsInherited = 'FALSE'
$InheritanceFlags = 'ContainerInherit, ObjectInherit'
$PropagationFlags = 'None'

$ACL = (Get-Item $BaseFolder).GetAccessControl('Access')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
$ACL.removeaccessruleall($ACE) #TODO set vs add, which should be used
Set-Acl -Path $BaseFolder -AclObject $ACL

<#
# During transisiton this step is omitted
# When directory structure is E:\Units\COMMON\RU\LAB-SY, this will be used
# Will need to create a 
#region Set List, This Folder Only
# This allows members of this group to "pass through" the $BaseFolder to the underlying files/folders
# LIST (GUI)
# Basic: Read & execute, List folder contents, Read
# Advanced: Traverse Folder / Execute File, List Folder / Read Data, Read Attributes, Read Extended Attributes, Read Permissions

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
# During transition, E:\Units\RU\SNAP\LAB-SY, use these settings (in GUI = ThisFolderSubfoldersAndFiles)
# $InheritanceFlags = 'ContainerInherit, ObjectInherit'
# $PropagationFlags = 'None'
# After transition, E:\Units\COMMON\RU\LAB-SY, use these settings (in GUI = SubfoldersAndFilesOnly)
# $InheritanceFlags = 'ContainerInherit, ObjectInherit'
# $PropagationFlags = 'InheritOnly'
# MODIFY (GUI)
# Basic: Modify, Read & execute, List folder contents, Read, Write
# Advanced: Traverse Folder / Execute File, List Folder / Read Data, Read Attributes, Read Extended Attributes, Create Files / Write Data, Write Attributes, Write Extended Attributes, Delete, Read Permissions

$FileSystemRights = 'Modify, Synchronize'
$AccessControlType = 'ALLOW'
$IdentityReference = "{0}\{1}" -f $Domain,$ADUCSG_Modify
$IsInherited = 'False'
$InheritanceFlags = 'ContainerInherit, ObjectInherit'
$PropagationFlags = 'None'

$ACL = (Get-Item $BaseFolder).GetAccessControl('Access')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
$ACL.AddAccessRule($ACE) #TODO set vs add, which should be used
Set-Acl -Path $BaseFolder -AclObject $ACL
#endregion

$endDate = get-date
$endScreen = Write-Host "Completed Processing $BaseFolder $enddate"
$endScreen
$endLog = "Completed Processing $BaseFolder $enddate"
$EndIcacls = icacls $BaseFolder
$EndIcacls | Out-File $OutFileFile -Append
$endLog | Out-File $OutFileFile -Append