function Get-PA3060Computers {
	<#
	.SYNOPSIS
		This gathers the Computer Information from the PCs in the PA3060 ADUC OU
	.DESCRIPTION
		This script is used to query the server once and add the data to a variable
		upon which assorted reports can be run by placing the $PA3060_COMPUTERS in the pipeline
		$PA3060_COMPUTERS is declared as a global variable, so you only need to call this function once,
		at the begining of your script
	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Get-PA3060Computers
	.NOTES
		    NAME: Get-PA3060Computers
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 6/16/2016 1:45 PM
			LASTEDIT: 7/25/2016 8:32 PM
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
				IF ($PA3060_COMPUTERS) {
					Write-Verbose '$PA3060_COMPUTERS variable is already populated.'
				} #end IF
				ELSE {
					Write-Verbose 'Populating variable $PA3060_COMPUTERS...'
					$global:PA3060_COMPUTERS = Get-ADComputer -SearchBase $EAD_PA3060 -Filter * -Properties *
				} #end ELSE
				
			} #end InitializeVariable
			ExportXML {
				IF ($PA3060_COMPUTERS) {
					Write-Verbose 'Exporting CliXml...'
					$PA3060_COMPUTERS | Export-Clixml "C:\Temp\Clixml-Computers.xml"
				} #end IF
				ELSE {
					Get-PA3060Computers -PRODUCTION InitializeVariable -Verbose
				} #end ELSE
			} #end ExportXML
		} #end SWITCH
		
	} #end PROCESS
	
	END {
		
	} #end END
	
} #end Get-PA3060Computers

measure-command {Get-PA3060Computers -PRODUCTION InitializeVariable -Verbose}