#region Remove-ADMemberFromGroup

# [Modified, 8/4/2016 8:46 PM, Grant Harrington]
# grant.harrington@ars.usda.gov

# TOOD: Convert into Advanced Function

# AD SG that contains members (USER/COMPUTER) to remove in batch
$EADGroup = 'RS.PA-usda-computer-add-complete'

# Sets the OU to filter on, ensuring only select objects will be removed
$EADOU = '3060'

# Extracts the specified members of the group as TypeName: Selected.Microsoft.ActiveDirectory.Management.ADPrincipal
$ObjectsToRemove = Get-ADGroupMember $EADGroup | Where-Object {$_.distinguishedName -like "*OU=$EADOU*"}

# Lists the extracted results (to ensure you removing the correct data)
$ObjectsToRemove | Sort Name | Select Name,Distinguishedname

# Removes the specified Members from the Group
# Notice the action is being performed on the GROUP
# What if: Removes all the specified member(s) from the specified group(s).
$ObjectsToRemove | Remove-ADPrincipalGroupMembership -MemberOf $EADGroup -WhatIf

break
# Removes the specified Members from the Group
$ObjectsToRemove | Remove-ADPrincipalGroupMembership -MemberOf $EADGroup

#endregion
