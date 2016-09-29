#[Modified, 7/31/2016 8:08 PM, Grant Harrington]

$computerInstance = new-object Microsoft.ActiveDirectory.Management.ADcomputer
New-ADcomputer -Name "ARSNDFAR4127072" -Instance $computerInstance -Path 'OU=Computers-Portable,OU=SPB,OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net' -Description 'Test PC'

See Wipe-Reload_PA3060Computer.ps1 for variables for this script
$SAMAccountName = $ADUCComputersWRAll_Array.sAMAccountNameIdentity
$Description = $ADUCComputersWRAll_Array.Description
$Path = $ADUCComputersWRAll_Array.DistinguishedName -replace 'CN=[A-Z0-9]{15},','' #This converts the DistinguishedName and extracts the OU path in order to place the new PC in the same OU

New-ADComputer -SAMAccountName $SAMAccountName -Instance $computerInstance -Path $Path -Description $Description


### Modified 8/16/2016
$PA3060Units = 'OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net'
$RU = 'OCD'
$PCType = 'Desktop'
$ComputerName = 'ARSNDFAR4NEWPC1'
$Description = 'Test PC'
switch ($PCType)
{
    'Desktop' { $PCOU = 'Computers-Desktop'}
    'Portable' { $PCOU = 'Computers-Portable'}
}

$OUPath = "OU={0},OU={1},{2}" -f $PCOU,$RU,$PA3060Units

$ComputerInstance = new-object Microsoft.ActiveDirectory.Management.ADcomputer
New-ADcomputer -Name $ComputerName -Instance $ComputerInstance -Path $OUPath -Description $Description