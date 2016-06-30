function Get-RSGPO {
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
			LASTEDIT: 6/16/2016 1:45 PM
            KEYWORDS:
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $FALSE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {

	} #end BEGIN
	
	PROCESS {
    
    Write-Verbose "Gathering all GPOs in USDA.net domain and assinging to `$RSGPOAll Variable"
	$global:RSGPOAll = get-gpo -all | select DisplayName
	} #end PROCESS
	
	END {
		
	} #end END
} #end Get-PA3060Users

Get-RSGPO -Verbose
