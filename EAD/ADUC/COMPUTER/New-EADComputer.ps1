#[Modified, 11/14/2016 3:26 PM, Grant Harrington]
function New-EADComputer {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
	.PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> New-EADComputer -RU ANS -PCType Desktop -PRODUCTION REVIEW
	            PS C:\> New-EADComputer -RU ANS -PCType Desktop -PRODUCTION LIVE
	.NOTES
		    NAME: New-EADComputer
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 11/8/2016 5:48 PM
            KEYWORDS:
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('ANS','CER','IGB','OCD','SPB','SUG')]
		[string]$RU,
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('Desktop', 'Portable')]
		[string]$PCType,
		[Parameter(Mandatory = $TRUE)]
		[string]$Location,
		[Parameter(Mandatory = $TRUE)]
		[string]$EADUsername,
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
        ."C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\POSHTOOLS\Validate-EADPCName.ps1"
        Write-host "Invoke Validate-EADPCName"
		$Date = Get-Date -format yyMMdd
		$PA3060Units = 'OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net'
		#$Description = 'IGB, BRL xxx, USER 01'
        $Description = "{0}, {1}, {2}" -f $RU,$Location,$EADUsername

		Switch ($PCType) {
			'Desktop' { $PCOU = 'Computers-Desktop' }
			'Portable' { $PCOU = 'Computers-Portable' }
		} #end Switch PCType
		$ComputerName = $EADName
		$OUPath = "OU={0},OU={1},{2}" -f $PCOU, $RU, $PA3060Units
	} #end BEGIN
	
	PROCESS {
		
		Switch ($PRODUCTION) {
			LIVE {
            $ComputerInstance = new-object Microsoft.ActiveDirectory.Management.ADcomputer
            New-ADcomputer -Name $ComputerName -Instance $ComputerInstance -Path $OUPath -Description $Description
			} # end LIVE
			REVIEW {
		$ComputerExists = Get-ADComputer $ComputerName
		if ($ComputerExists) {
			Write-Host "$($ComputerExists.Name) is already in EAD"
			Write-Host "$Computerexists"
		}
		else {
			Write-Host "$ComputerName was not found and will be added"
            Write-Host "New-ADcomputer -Name $ComputerName -Instance $ComputerInstance -Path $OUPath -Description $Description"
		}
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end New-EADComputer

#region ScriptWIP
<#
$computerInstance = new-object Microsoft.ActiveDirectory.Management.ADcomputer
New-ADcomputer -Name "ARSNDFAR4127072" -Instance $computerInstance -Path 'OU=Computers-Portable,OU=SPB,OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net' -Description 'Test PC'

See Wipe-Reload_PA3060Computer.ps1 for variables for this script
$SAMAccountName = $ADUCComputersWRAll_Array.sAMAccountNameIdentity
$Description = $ADUCComputersWRAll_Array.Description
$Path = $ADUCComputersWRAll_Array.DistinguishedName -replace 'CN=[A-Z0-9]{15},','' #This converts the DistinguishedName and extracts the OU path in order to place the new PC in the same OU

New-ADComputer -SAMAccountName $SAMAccountName -Instance $computerInstance -Path $Path -Description $Description


### Modified 10/20/2016
$PA3060Units = 'OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net'
$RU = 'OCD'
$PCType = 'Desktop'
$ComputerName = 'ARSNDFAR4KH0SD2'
$Description = 'OCD, NCSL 148 (LCR), Grant Harrington'
switch ($PCType)
{
    'Desktop' { $PCOU = 'Computers-Desktop'}
    'Portable' { $PCOU = 'Computers-Portable'}
}

$OUPath = "OU={0},OU={1},{2}" -f $PCOU,$RU,$PA3060Units
$ComputerExists = Get-ADComputer $ComputerName
if ($ComputerExists)
{Write-Host "$($ComputerExists.Name) is already in EAD"
Write-Host "$Computerexists"
} else {
Write-Host "$($ComputerExists.Name) was not found and will be added"
}

$ComputerInstance = new-object Microsoft.ActiveDirectory.Management.ADcomputer
New-ADcomputer -Name $ComputerName -Instance $ComputerInstance -Path $OUPath -Description $Description 

."C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\POSHTOOLS\Validate-EADPCName.ps1"
Write-host "Invoke Validate-EADPCName"
#>
#endregion