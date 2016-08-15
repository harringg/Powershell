function Deploy-LiteTouch {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
	.PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
	
	.EXAMPLE
				PS C:\> Deploy-LiteTouch -ComputerName ARSNDFAR5xxxxxx

	.NOTES
		    NAME: Export-GPOReports
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 11/17/2014 2:10:59 PM
			LASTEDIT: 8/15/2016 10:49 AM
            KEYWORDS:
	.LINK
		EAD Scripts
#>	
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $True, ParameterSetName = 'ComputerName')]
		[string[]]$ComputerName,
		[Parameter(Mandatory = $True, ParameterSetName = 'File')]
		[string]$FilePath
	)
	
	BEGIN {
		
		if ($PSBoundParameters.ContainsKey('File')) {
			$ComputerName = Get-Content -Path $FilePath
		}

        $LiteTouchPath = '\\10.170.180.2\it\MDTProduction\Scripts'
        $CSCRIPT = "{0}\LiteTouch.vbs" -f $LiteTouchPath
		
	} #end BEGIN
	
	PROCESS {
		
		foreach ($Computer in $ComputerName) {
			try {
				$PSSession = New-PSSession -ComputerName $Computer
				Invoke-Command -session $PSSession -ScriptBlock { cscript $CSCRIPT }
				
				Remove-PSSession -ID $PSSession.Id
			}
			catch {
				Write-Verbose "Failed to connect to $Computer"
			} #end try
		} #end foreach
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Deploy-LiteTouch