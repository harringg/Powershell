#Requires -RunAsAdministrator
#Requires -Version 3

function Set-UPNtoHSPDPID {
	<#
	.SYNOPSIS
		Updates users UPN to 1200+HSPDPID
	
	.DESCRIPTION
        Using a CSV that contains sAMAccountName and the 10 digit HSPDPID to update the UPN in ADUC
        	
	.PARAMETER PRODUCTION
		This will enable a switch that will either give you a preview of
        the results (REVIEW), or run the script in production (LIVE)
	
	.EXAMPLE
				PS C:\> Set-UPNtoHSPDPID -PRODUCTION REVIEW
	
	.NOTES
		    NAME: Set-UPNtoHSPDPID
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 6/28/2015 7:57 PM
			LASTEDIT: 9/36/2016 12:36 PM
            KEYWORDS: ADUC

	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[string]$sAMAccountName,
		[Parameter(Mandatory = $TRUE)]
		[string]$HSPDPID,
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {

	    	
	} #end BEGIN
	
	PROCESS {
			
			$SetADUserIdentity = $sAMAccountName
			$SetADUserUserPrincipalName = "1200{0}@FEDIDCARD.GOV" -f $HSPDPID
			
			$SetADUserSamUPNParams = @{
				'Identity' = $SetADUserIdentity;
				'UserPrincipalName' = $SetADUserUserPrincipalName;
                'Replace' = @{ extensionAttribute1 = 'PIV - NON-EP' }
                
			} #end SetADUserSamUPNParams
			
			Switch ($PRODUCTION) {
				LIVE { Set-ADUser @SetADUserSamUPNParams }
				REVIEW {
						get-aduser $SetADUserIdentity
						$SetADUserUserPrincipalName
				    	}
				} #end Switch-Production

		} #end PROCESS
		
		END {
			
		} #end END
	} #end Set-UPNtoHSPDPID


#Get-aduser -Filter * -Properties * | where {$_.UserPrincipalName -like "1200*"} | select Samaccountname,UserPrincipalName,department | export-csv "C:\temp\cert\upn.csv" -NoTypeInformation
