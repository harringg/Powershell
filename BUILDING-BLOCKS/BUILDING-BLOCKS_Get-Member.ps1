New-Variable -Name 
$BLV = Get-BitLockerVolume

$member = $BLV | gm -MemberType Properties

$gacl = Get-Acl
$member = $gacl | gm -MemberType Properties

$gacl | fl

$gacl = Get-ChildItem
$member = $gacl | gm -MemberType Properties

Get-CimClass -ClassName win32_bios
$gacl = Get-CimInstance -ClassName win32_bios -Property *

###################################################
# Places a Cmdlet's result in a variable, gacl
$gacl = Get-Acl
# Creates an array with the Get-Member Properties 
# and places them in a variable, member
$member = $gacl | gm -MemberType Properties

# Builds the shell for the OBJProperty array
write-host "`$OBJProperty = @{"
# Takes each name value from Get-Member and
# writes to the screen the syntax for creating
# a list of OBJProperty for concise manipulation
foreach ($mymember in $member.name) {
write-host "'$mymember' = `$gacl.$mymember"
}
# Finishes the shell for the OBJProperty array
write-host "}"
###################################################
$member.name

$OBJProperty = @{
'Access' = $gacl.Access
'CentralAccessPolicyId' = $gacl.CentralAccessPolicyId
'CentralAccessPolicyName' = $gacl.CentralAccessPolicyName
'Group' = $gacl.Group
'Owner' = $gacl.Owner
'Path' = $gacl.Path
'Sddl' = $gacl.Sddl
'PSChildName' = $gacl.PSChildName
'PSDrive' = $gacl.PSDrive
'PSParentPath' = $gacl.PSParentPath
'PSPath' = $gacl.PSPath
'PSProvider' = $gacl.PSProvider
'AccessRightType' = $gacl.AccessRightType
'AccessRuleType' = $gacl.AccessRuleType
'AreAccessRulesCanonical' = $gacl.AreAccessRulesCanonical
'AreAccessRulesProtected' = $gacl.AreAccessRulesProtected
'AreAuditRulesCanonical' = $gacl.AreAuditRulesCanonical
'AreAuditRulesProtected' = $gacl.AreAuditRulesProtected
'AuditRuleType' = $gacl.AuditRuleType
'AccessToString' = $gacl.AccessToString
'AuditToString' = $gacl.AuditToString
}


$object = New-Object –TypeName PSObject –Prop $OBJProperty
Write-Output $object