# Run once, then comment out
#."C:\Users\rs.grant.harrington\Documents\POSH\EAD\GPMC\Get-RSGPOAll-FUNCTION.ps1"

function Backup-EADGPO {
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
				PS C:\> Backup-EADGPO -GPOName 3060 -PRODUCTION REVIEW
	            PS C:\> Export-GPOReports -ReportType HTML -PRODUCTION LIVE
	.NOTES
		    NAME: Backup-EADGPO
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 5/27/2016
			LASTEDIT: 6/29/2016 6:36 PM
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
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW',
		[Parameter(Mandatory = $TRUE)]
		[string]$GPOName
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd_HHmm

		#region RunFirst
		$RSGPOQuery = $RSGPOAll | where { $_.DisplayName -like "*$GPOName*" } | select DisplayName
		
		# Base Directory where your exported GPOs and HTML reports will reside
		$BaseDirectory = 'C:\Users\rs.grant.harrington\Documents\EAD\GPOBackup'
		$FolderPath = '{0}\{1}_({2})' -f $BaseDirectory, $Date, $GPOName
		
		#endregion
	} #end BEGIN
	
	PROCESS {
		
		Switch ($PRODUCTION) {
			LIVE {
				#region foreach $Name in $RSComputerGPOPA3060
				
				foreach ($Name in $RSGPOQuery) {
					# This creates a name for a new folder named after the GPO's name
					$GPOFolderPath = "{0}\{1}" -f $FolderPath, $($Name.DisplayName)
					# This creates an HTML file named after the GPO's name
					$GPOReportNamePath = "{0}\{1}.html" -f $GPOFolderPath, $($Name.DisplayName)
					# This creates the folder to store the exported GPO and HTML report
					New-Item -Path $GPOFolderPath -ItemType Directory
					# This backs up the GPO to the $GPOFolderPath and places the GPO name in the Comment field
					Backup-Gpo -Name $($Name.DisplayName) -Path $GPOFolderPath -Comment "$($Name.DisplayName)"
					# This creates an HTML report in the $GPOFolderPath
					Get-GPOReport -Name $($Name.DisplayName) -ReportType Html -Path $GPOReportNamePath
				} #end foreach $Name in $RSComputerGPOPA3060
				#endregion
				
			} # end LIVE
			REVIEW {
                <#foreach ($GPO in $RSGPOQuery.DisplayName) {
                get-gpo -Name $GPO | select *
                }
                #>
                $RSGPOQuery | sort DisplayName | select *

			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Backup-EADGPO
