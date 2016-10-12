function Get-PA3060Users {
	<#
	.SYNOPSIS
		This gathers the User Information in the PA3060 ADUC OU
	.DESCRIPTION
		This script is used to query the server once and add the data to a variable
		upon which assorted reports can be run by placing the $PA3060_USERS in the pipeline
		$PA3060_USERS is declared as a global variable, so you only need to call this function once,
		at the begining of your script
	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Get-PA3060Users
	.NOTES
		    NAME: Get-PA3060Users
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 6/16/2016 1:45 PM
			LASTEDIT: 7/25/2016 8:58 PM
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
		[ValidateSet('InitializeVariable', 'ExportXML')]
		[string]$PRODUCTION = 'InitializeVariable'
	)
	
	BEGIN {
		
		$EAD_PA3060 = "OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net"
		
	} #end BEGIN
	
	PROCESS {
		
		SWITCH ($PRODUCTION) {
			InitializeVariable {
				IF ($PA3060_USERS) {
					Write-Verbose '$PA3060_USERS variable is already populated.'
				} #end IF
				ELSE {
					Write-Verbose 'Populating variable $PA3060_USERS...'
					$global:PA3060_USERS = Get-ADUser -SearchBase $EAD_PA3060 -filter * -Properties *
				} #end ELSE
				
			} #end InitializeVariable
			ExportXML {
				IF ($PA3060_USERS) {
					Write-Verbose 'Exporting CliXml...'
					$PA3060_USERS | Export-Clixml "C:\Temp\Clixml-Users.xml"
				} #end IF
				ELSE {
					Get-PA3060_USERS -PRODUCTION InitializeVariable -Verbose
				} #end ELSE
			} #end ExportXML
		} #end SWITCH
		
	} #end PROCESS
	
	END {
		
	} #end END

} #end Get-PA3060Users

Get-PA3060Users -PRODUCTION InitializeVariable -Verbose