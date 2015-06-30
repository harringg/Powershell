function Get-Function
{
	<#
	.SYNOPSIS
		Default Synopsis
	
	.DESCRIPTION
		Default Description
	
	.PARAMETER param1
		param1 Description
	
	.EXAMPLE
				PS C:\> Get-Function -param1 'Value1'
	
	.NOTES
		    NAME: Get-ADTitle
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 6/25/2015 4:25 PM
			LASTEDIT: 6/25/2015 4:25 PM
            KEYWORDS:
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet("Value1", "Value2", "Value3")]
		[string]$param1
	)
	
	BEGIN
	{
		
	} #end BEGIN
	
	PROCESS
	{
		
	} #end PROCESS
	
	END
	{
		
	} #end END
} #end Get-Function
