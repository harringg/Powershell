# Step 00: Create $PA3060_COMPUTERS array
#"C:\Users\grant.harrington\Documents\SCRIPTS\POSH\EAD\ADUC\Computers\Get-PA3060Computers-FUNCTION.ps1"
cls
# Step 01: Gather existing groups and description from PC
# PC to wipe/reload
$RemovePC = 'ARSNDFAR4127072'
$RemovePC = $NewPC

# Empty Container for new PSObjects
$ADUCComputersWRAll_Array = @()

#$PA3060_COMPUTERS | where {$_.SamAccountName -like "*$removePC*"} |
Get-ADComputer $RemovePC -Properties * |
ForEach-Object {

$ADUCComputersWRProperties = [ORDERED]@{
    'sAMAccountNameIdentity' = ($_.SamAccountName)
    'whenCreated' = ($_.whenCreated)
    'Description' = ($_.Description)
    'DistinguishedName' = ($_.DistinguishedName)
    'IPv4Address' = ($_.IPv4Address)
    'MemberOf' = ($_.MemberOf | ForEach-Object {([regex]"CN=(.*?),").match($_).Groups[1].Value}) -join ","
    'ObjectSID' = ($_.ObjectSID)
    }

# New PSCustomObject using Properties from HashTable
$ADUCComputersWRAll = New-Object -TypeName PSCustomObject -Property $ADUCComputersWRProperties

$ADUCComputersWRAll_Array += $ADUCComputersWRAll
}

$ADUCComputersWRAll_Array

# Step 02: Delete PC from ADUC (create a review/live function with -WhatIf)
#Remove-ADComputer -Identity $RemovePC -WhatIf
#Remove-ADComputer -Identity $RemovePC -Verbose
# Step 03: Recreate new PC object
# -Add with Domain Users ability to add back
# -Add back security groups (use split to create objects that get piped to add back and looped through)
# -Add back description
#$ADGroups = $ADUCComputersWRAll_Array.memberof -split ','

#This will add back the PC to the security groups it was already a member of
'ARSNDFAR4NEWPC1$'| Add-ADPrincipalGroupMembership -MemberOf $ADGroups
$NewPC = 'ARSNDFAR4127072$'
$NewPC | Add-ADPrincipalGroupMembership -MemberOf $ADGroups

#Set-ADComputer -Identity $RemovePC -Description "$($ADUCComputersWRAll_Array.Description)" -WhatIf
#Set-ADComputer -Identity $RemovePC -Description "$($ADUCComputersWRAll_Array.Description)" -Verbose
#Set-ADComputer -Identity $NewPC -Description "$($ADUCComputersWRAll_Array.Description)" -vERBOSE