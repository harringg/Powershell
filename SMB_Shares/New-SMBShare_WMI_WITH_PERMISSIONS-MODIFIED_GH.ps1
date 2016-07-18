# [Modified, 7/17/2016 12:20 AM, Grant Harrington]
# [Modified, 7/17/2016 7:45 PM, Grant Harrington]
# Modified from source: http://stackoverflow.com/questions/20333572/how-to-create-folder-share-and-apply-ntfs-permissions
# GHC = Grant Harrington Comments, my own comments, not included in original script

$Server = $env:COMPUTERNAME
$RUName= 'Cereals','Sunflowers'
$BaseFolder = 'C:\TEMP\UNITS'

foreach ($Directory in $RUName) {

#Local path
$FolderPath = "{0}\{1}" -f $BaseFolder,$Directory

$Shares=[WMICLASS]'WIN32_Share'
#Share name
# GHC This will make it an administrative share by including the '$' in the name
$ShareName = $Directory

#Create folder
#New-Item -type directory -Path $FolderPath

#Create share rights

#region GUI: Sharing > Advanced Sharing > Permissions > Authenticated Users, Change/Read
#Define a trustee (person/group to give access right)
$trustee = ([wmiclass]‘Win32_trustee’).psbase.CreateInstance()
$trustee.Domain = "NT Authority"
$trustee.Name = “Authenticated Users”

#Define an access control entry (permission-entry)
$ace = ([wmiclass]‘Win32_ACE’).psbase.CreateInstance()
#Modify-rights, GHC: 1245631 = Change/Read in GUI
$ace.AccessMask = 1245631
#Inheritance for folders and files
$ace.AceFlags = 3
$ace.AceType = 0
#Assign rights to Authenticated users ($trustee)
$ace.Trustee = $trustee
#endregion

#region GUI: Sharing > Advanced Sharing > Permissions > BUILTIN\Administrators, Full Controll/Change/Read
$trustee2 = ([wmiclass]‘Win32_trustee’).psbase.CreateInstance()
$trustee2.Domain = "BUILTIN"  #Or domain name
$trustee2.Name = “Administrators”

$ace2 = ([wmiclass]‘Win32_ACE’).psbase.CreateInstance()
#Full control, GHC: 2032127 = Full Control/Change/Read in GUI
$ace2.AccessMask = 2032127
$ace2.AceFlags = 3
$ace2.AceType = 0
#Assign rights to Administrators ($trustee2)
$ace2.Trustee = $trustee2
#endregion

#Create ACL/security descriptor. This is the security-definitions that you set on the share.
$sd = ([wmiclass]‘Win32_SecurityDescriptor’).psbase.CreateInstance()
#Specify that a DACL (ACL/security/permissions) are available, so the share isn't set to full access for everyone
$sd.ControlFlags = 4
#Add our rules
$sd.DACL = $ace, $ace2
#Set Administrators ($trustee2) as owner and group of ITEM (will be the share)
$sd.group = $trustee2
$sd.owner = $trustee2

#Create share with the security rules
# GHC  Need to break out what the '$FolderPath, $ShareName, 0, 100, "Description", "", $sd' means
# GUI > Server Manager > Roles > File Services > Share and Storage Management
# $FolderPath = GUI > Properties > Path
# $ShareName = GUI > Properties > Sharing > Share Name (top box on Sharing Tab)
# 0 = GUI > ???
# 100 = GUI > Properties > Sharing > Advanced > User Limit # Set to '0' for User Limit > Maximum Allowed
# "Description" = GUI > Properties > Sharing > Description
# "" = GUI > ???
# $sd = GUI > Properties > Permissions > Share Permissions
$shares.create($FolderPath, $ShareName, 0, 100, "$ShareName Shared Directory", "", $sd) | Out-Null

<# 
####COMMENT: At this point, I don't want to set NTFS, I've got other scripts for that ####

#Get NTFS permissiongs
$Acl = Get-Acl $FolderPath
#Disable inheritance and clear permissions
$Acl.SetAccessRuleProtection($True, $False)
#Define NTFS rights
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule('Administrators','FullControl','ContainerInherit, ObjectInherit', 'None', 'Allow')
$Acl.AddAccessRule($rule)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule('SYSTEM','FullControl','ContainerInherit, ObjectInherit', 'None', 'Allow')
$Acl.AddAccessRule($rule)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Authenticated Users",@("ReadData", "AppendData", "Synchronize"), "None", "None", "Allow")
$Acl.AddAccessRule($rule)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule('CREATOR OWNER','FullControl','ContainerInherit, ObjectInherit', 'InheritOnly', 'Allow')
$Acl.AddAccessRule($rule)
#>


# Sets the Cache to:
# No files or programs from the shared folder are available offline.
# GUI > Properties > Sharing > Advanced > Caching > No files or programs from the share are available offline 
([WMIClass]"\\$Server\root\cimv2:win32_Process").Create("cmd /C net share $ShareName /Cache:None") 

#Save ACL changes (NTFS permissions)
#Set-Acl $FolderPath $Acl | Out-Null
#Show ACL so user can verify changes
Get-Acl $FolderPath  | Format-List
} #end Foreach Loop