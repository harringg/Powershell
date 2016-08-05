function Remove-ARSAppxPackage {
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
				PS C:\> Remove-ARSAppxPackage -PRODUCTION REVIEW -ImportFile AppxPackage-REMOVE
	            PS C:\> Remove-ARSAppxPackage -PRODUCTION LIVE -ImportFile AppxPackage-REMOVE
	.NOTES
		    NAME: Remove-ARSAppxPackage
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 8/5/2016 11:11 AM
			LASTEDIT: 8/5/2016 11:11 AM
            KEYWORDS: WIN10
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW',
		[Parameter(Mandatory = $TRUE)]
		[string]$ImportFile
	)
	
	BEGIN {
		
		$Date = Get-Date -format yyMMdd
		$ImportPath = "C:\Temp"
		$ImportCVS = "{0}\{1}.csv" -f $ImportPath, $ImportFile
		$AppToRemove = Import-Csv $ImportCVS
		
	} #end BEGIN
	
	PROCESS {
		
		Switch ($PRODUCTION) {
			LIVE {
				ForEach ($SearchApp in $($AppToRemove.PackageFullName)) {
					
					Remove-AppxPackage $RemoveApps.PackageFullName -Verbose
				}
			} # end LIVE
			REVIEW {
				
				ForEach ($SearchApp in $($AppToRemove.PackageFullName)) {
					
					$RemoveApps = Get-AppxPackage -AllUsers | where { $_.PackageFullName -like "*$SearchApp*" }
					$RemoveApps | fl
				} #end ForEach
				
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Remove-ARSAppxPackage