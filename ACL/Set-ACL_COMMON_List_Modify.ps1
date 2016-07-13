# [Modified, 7/13/2016 3:05 PM, Grant Harrington]
# This script will apply:
# List, This Folder Only (allowing pass-through access to the directory)
# Modify, Subfolders and Files (allowing Modify rights to everything inside the directory)
# This used when your NAS folder structure is
# Parent
# -Child
# --GrandChild01
# --GrandChild02
# It will allow users to navigate and edit content of GrandChild01, 
# without the ability to delete either Grandchild01 or 02 folders

$BaseFolder = "Z:\Units\COMMON\GRANT"
$AUDCSG_List = 'USDA\ARSLNDFAR-IT-DFS-LIST'
$ADUCSG_Modify = 'USDA\ARSLNDFAR-IT-DFS-MODIFY'

cls
get-date
Write-Host $BaseFolder
Get-acl $BaseFolder | fl
icacls $BaseFolder
((Get-Item $BaseFolder).GetAccessControl('Access').Access) #This gets the root directory ACL

#region Set List, This Folder Only
# This allows members of this group to "pass through" the $BaseFolder to the underlying files/folders

$FileSystemRights = 'ReadAndExecute, Synchronize'
$AccessControlType = 'ALLOW'
$IdentityReference = $AUDCSG_List
$IsInherited = 'False'
$InheritanceFlags = 'None'
$PropagationFlags = 'None'

$ACL = (Get-Item $BaseFolder).GetAccessControl('Access')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
$ACL.AddAccessRule($ACE) #TODO set vs add, which should be used
Set-Acl -Path $BaseFolder -AclObject $ACL 
#endregion

#region Set Modify, Subfolders and Files
# This allows users to Edit,Add,Delete all files/folders under the $BaseFolder
$FileSystemRights = 'Modify, Synchronize'
$AccessControlType = 'ALLOW'
$IdentityReference = $ADUCSG_Modify
$IsInherited = 'False'
$InheritanceFlags = 'ContainerInherit, ObjectInherit'
$PropagationFlags = 'InheritOnly'

$ACL = (Get-Item $BaseFolder).GetAccessControl('Access')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
$ACL.AddAccessRule($ACE) #TODO set vs add, which should be used
Set-Acl -Path $BaseFolder -AclObject $ACL
#endregion
