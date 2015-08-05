#Requires -RunAsAdministrator
#Requires -Version 3

function Get-MFAAccountStatus {
	<#
	.SYNOPSIS
		Reports the compliance for MFA in local AD
	
	.DESCRIPTION
		Reports the compliance for MFA in local AD in the following categories
		Standard Users, MFA Not Enforced
		EP Users, MFA Not Enforced
		Standard Users, MFA Enforced
		EP Users, MFA Enforced
		Standard Users, No Lincpass
	
	.PARAMETER Output
		Output Screen-FullList Displays all accounts and their status (MFA Enforced)
	.PARAMETER Output
		Output Screen-Counts Categorizes the total accounts types and their totals
	
	.PARAMETER Output
		Output Export-CSV Creates a .csv file containing the sAMAccountName, UserPrincipalName, and SmartcardLogonRequired setting for each category
	
	.NOTES
		    NAME: Get-MFAAccountStatus
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 7/29/2015 3:45 PM
			LASTEDIT: 8/5/2015 12:45 PM
            KEYWORDS: ADUC, MFA
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet("Screen-FullList", "Screen-Counts", "Export-CSV")]
		[string]$Output
	)
	
	BEGIN {
		$date = get-date -f yyMMddHHmm
		$ExportPath = "C:\Temp"
		
		$MFA = get-aduser -Filter * -Properties * -credential 'fargo\administrator'
		$MFAStdUserNotEnforced = $MFA | where { $_.SmartcardLogonRequired -eq $False -and $_.UserPrincipalName -like "*1200*" } | Select sAMAccountName, UserPrincipalName, SmartcardLogonRequired
		$MFAEPUserNotEnforced = $MFA | where { $_.SmartcardLogonRequired -eq $False -and $_.UserPrincipalName -like "*-ad*" } | Select sAMAccountName, UserPrincipalName, SmartcardLogonRequired
		
		$MFAStdUserEnforced = $MFA | where { $_.SmartcardLogonRequired -eq $True -and $_.UserPrincipalName -like "*1200*" } | Select sAMAccountName, UserPrincipalName, SmartcardLogonRequired
		$MFAEPUserEnforced = $MFA | where { $_.SmartcardLogonRequired -eq $True -and $_.UserPrincipalName -like "*-ad*" } | Select sAMAccountName, UserPrincipalName, SmartcardLogonRequired
		
		$StdUserNonMFA = $MFA | where { $_.SmartcardLogonRequired -eq $False -and $_.UserPrincipalName -like "*fargo*" } | Select sAMAccountName, UserPrincipalName, SmartcardLogonRequired
		
	} #end BEGIN
	
	PROCESS {
		
		Switch ($OUTPUT) {
			Screen-FullList {
				$MFAStdUserNotEnforced
				$MFAEPUserNotEnforced
				$MFAStdUserEnforced
				$MFAEPUserEnforced
				$StdUserNonMFA
			}
			Screen-Counts {
                $Total = $($MFAStdUserNotEnforced.Count) + $($MFAEPUserNotEnforced.Count) + $($MFAStdUserEnforced.Count) + $($MFAEPUserEnforced.Count) + $($StdUserNonMFA.Count)
				Write-host "Standard Users, Not MFA Enforced = $($MFAStdUserNotEnforced.Count), ($($MFAStdUserNotEnforced.Count)/$($total)) "
				Write-host "EP Users, Not MFA Enforced = $($MFAEPUserNotEnforced.Count), ($($MFAEPUserNotEnforced.Count)/$($total))"
				Write-host "Standard Users, MFA Enforced = $($MFAStdUserEnforced.Count), ($($MFAStdUserEnforced.Count)/$($total))"
				Write-host "EP Users, MFA Enforced = $($MFAEPUserEnforced.Count), ($($MFAEPUserEnforced.Count)/$($total))"
				Write-host "Standard Users, No Lincpass = $($StdUserNonMFA.Count), ($($StdUserNonMFA.Count)/$($total))"
				
				Write-Host "Total AD Users = $Total"
                Write-Host "Query Date/Time = $date"
			}
			
			Export-CSV {
				$MFAStdUserNotEnforced | Export-Csv "$ExportPath\$date-MFAStdUserNotEnforced.csv" -NoTypeInformation
				$MFAEPUserNotEnforced | Export-Csv "$ExportPath\$date-MFAEPUserNotEnforced.csv" -NoTypeInformation
				$MFAStdUserEnforced | Export-Csv "$ExportPath\$date-MFAStdUserEnforced.csv" -NoTypeInformation
				$MFAEPUserEnforced | Export-Csv "$ExportPath\$date-MFAEPUserEnforced.csv" -NoTypeInformation
				$StdUserNonMFA | Export-Csv "$ExportPath\$date-StdUserNonMFA.csv" -NoTypeInformation
			}
		} #end Switch-Production
		
	} #end PROCESS
	
	
	END {
		
	} #end END

} #end Get-MFAAccountStatus
