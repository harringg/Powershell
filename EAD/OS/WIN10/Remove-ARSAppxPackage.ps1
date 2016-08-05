function Remove-ARSAppxPackage {
	<#
	.SYNOPSIS
	    This script is to be used to remove WIN 10 AppxPackages from the base isntall
	.DESCRIPTION
	    Intended to be run on WIN 10 with Powershell v5.0 or greater
        AppxPackages (PackageFullName) are imported from a static text file (this allows the list to be dynamic, without need to update the script)
	.PARAMETER ImportFile
        This is the filename that contains the PackageFullName
        PackageFullName
        king.com.CandyCrushSodaSaga_1.68.500.0_x86__kgqvnymyfvs32
        Microsoft.Advertising.Xaml_8wekyb3d8bbwe

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