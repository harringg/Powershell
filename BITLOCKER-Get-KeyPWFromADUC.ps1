#Requires -RunAsAdministrator
#Requires -Version 3

function Get-KeyPWFromADUC {
	<#
	.SYNOPSIS
		Retrieves the Bitlocker Key ID and Recovery Key from ADUC
	
	.DESCRIPTION
		Retrieves the Bitlocker Key ID and Recovery Key from ADUC
	
	.PARAMETER param1
		param1 Description
	
	.EXAMPLE
				PS C:\> Get-KeyPWFromADUC
	
	.NOTES
		    NAME: Get-KeyPWFromADUC
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 6/18/2015 3:45 PM
			LASTEDIT: 7/22/2015 1:08 PM
            KEYWORDS: ADUC, BITLOCKER

            Modified concept based on: https://ndswanson.wordpress.com/2014/10/20/get-bitlocker-recovery-from-active-directory-with-powershell/
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ValidateSet("Value1", "Value2", "Value3")]
		[string]$param1
	)
	
	BEGIN {
		#$PC = 'ARSNDFAR5329FKK'
		#$computer = Get-ADComputer -Filter {Name -eq $PC }
		$computerAll = Get-ADComputer -Filter * | where { $_.DistinguishedName -like "*OU=Laptops,OU=DomainComputers,DC=Fargo,DC=local" }
	} #end BEGIN
	
	PROCESS {
		$BitlockerKeyIDAll = @()
		$BitlockerRecoveryKeyAll = @()
		
		foreach ($Computer in $computerAll) {
			$BitLockerObjects = Get-ADObject -Filter { objectclass -eq 'msFVE-RecoveryInformation' } -SearchBase $computer.DistinguishedName -Properties 'msFVE-RecoveryPassword'
			
			if ($BitLockerObjects.Name.Length -gt 1) {
				
				
				#2015-06-25T08:14:29-06:00{9373ABA4-xxxx-xxxx-xxxx-6DBDCC636CA4}
				# Find "this" = '^[^\{]*\{'
				# "This" = 2015-06-25T08:14:29-06:00{
				# Replace "this" with "that" = '{'
				# "That" = {
				# Result = {9373ABA4-xxxx-xxxx-xxxx-6DBDCC636CA4}
				
				#'^ = start at begining
				#[^\{]* = Find first instance of '{'
				#
				$ADUCBLName = $BitLockerObjects.Name -creplace ('^[^\{]*\{', '{')
				"$($Computer.Name) Full recovery key identification (from ADUC): = $ADUCBLName"
				"$($Computer.Name) Bitlocker Recovery Key (from ADUC): = $($BitLockerObjects.'msFVE-RecoveryPassword')"
				
				
			}
			else {
				"$($Computer.Name) does not have a Bitlocker recovery key registered in ADUC"
			} #end if-else
		} # end foreach
	} #end PROCESS
	
	
	END {
		
	} #end END
} #end Get-KeyPWFromADUC
