Import-Module ActiveDirectory
function Reset-EADUserPassword {
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
				PS C:\> Export-GPOReports -ReportType HTML -PRODUCTION REVIEW
	            PS C:\> Export-GPOReports -ReportType HTML -PRODUCTION LIVE
	.NOTES
		    NAME: Reset-EADUserPassword
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 10/18/2016 11:12 AM
			LASTEDIT: 11/22/2016 4:01 PM
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
		[string]$SearchUser,
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
        $ImportedPW = Import-Csv 'C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\USER\DefaultPassword.csv'
		# DefaultPassword.csv
        # DefaultPassword
        # <YourChosenDefaultPassword>
        $DefaultPassword = ConvertTo-SecureString -string $ImportedPW.DefaultPassword -AsPlainText -force
		$UserAccount = Get-ADUser $SearchUser -Properties Description,Enabled,PasswordLastSet
	} #end BEGIN
	
	PROCESS {
		
		
		Switch ($PRODUCTION) {
			LIVE {
				Set-ADAccountPassword $UserAccount -NewPassword $DefaultPassword –Reset
			} # end LIVE
			REVIEW {
                $UserAccount
                $ImportedPW.DefaultPassword
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Reset-EADUserPassword