function Set-SmartCardLoginRequired {
	<#
	.SYNOPSIS
		Sets the SmartcardLogonRequired flag to True (checked)
	
	.DESCRIPTION
        	Sets the SmartcardLogonRequired flag to True (checked) programatically
        	In the GUI, this setting can be found here:
        	First.Last-adm > Properties > Account > Account options: > Smart card is required for interactive login [checked]
        	
	.PARAMETER PRODUCTION
		This will enable a switch that will either give you a preview of
        	the results (REVIEW), or run the script in production (LIVE)
	
	.EXAMPLE
		PS C:\> Set-SmartCardLoginRequired -PRODUCTION REVIEW
	
	.NOTES
		    NAME:  Set-SmartCardLoginRequired
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 7/7/2015 6:39 AM
			LASTEDIT: 8/4/2015 4:50 PM
            KEYWORDS: ADUC, Lincpass
	.LINK
		EAD Scripts
		https://github.com/harringg/Powershell/edit/master/CAServer-SET-ADUSER_SmartCardLoginRequired.ps1
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
		# This will place all first.last-adm accounts into an array
		# All users will have the SmartcardLogonRequired attribute set to True (when run Live)
		#$SetLoginRequiredADM = Get-ADUser -Filter { sAMAccountName -like "*-adm" }
		$SetLoginRequiredADM = Get-ADUser -Filter { UserPrincipalName -like "1200*" -and Department -like "*RU*"} -Properties * | select *
		#This will store the credentials as Secure Text on the client PC running the script
		$DomainAdmin = "Fargo\Administrator"
		$Password = Read-Host "Enter Admin Password" -AsSecureString
		$DomainCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $DomainAdmin, $Password
		$date = get-date -f yyMMddHHmm
	} #end BEGIN
	
	PROCESS {
		$ListUsers = @() 
		foreach ($LoginRequired in $SetLoginRequiredADM) {
			
			Switch ($PRODUCTION) {
				LIVE { Set-ADUser -Identity $($LoginRequired.sAMAccountName) -SmartcardLogonRequired:$true -Credential $DomainCredential }
				REVIEW {
					$LoginRequiredProps = [ordered]@{
						sAMAccountName = $LoginRequired.sAMAccountName
                        UserPrincipalName = "1200xxxxxxxxxx@fedidcard.gov"
						Department = $LoginRequired.Department
						LastLogonDate = $LoginRequired.LastLogonDate
						SmartcardLogonRequired = $LoginRequired.SmartcardLogonRequired
                        ReportRun = $date
						
					} #end Win32_tpmProps

					$LoginRequiredObj = New-Object -TypeName PSObject -Property $LoginRequiredProps
					$ListUsers += $LoginRequiredObj
				}
			} #end Switch PRODUCTION
		} #end foreach
		
	} #end PROCESS
	
	END {
		$ListUsers | sort sAMAccountName | ft
        $ListUsers | Export-csv "C:\temp\CER-PreMFAEnforce-$date.csv" -NoTypeInformation
	} #end END
} #end Set-SmartCardLoginRequired
