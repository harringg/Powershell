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
			LASTEDIT: 6/28/2015 9:15 PM
            KEYWORDS: ADUC

            NOTES: Change column headers in .csv file to
                   'sAMAccountName','HSPDPID' before import 
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
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {

		$ImportFilePath = "C:\Temp"
		$ImportFileName = "HSPDPID.csv"
		$SamUPN = Import-Csv "$ImportFilePath\$ImportFileName"
		
	} #end BEGIN
	
	PROCESS {
		
		foreach ($Identity in $SamUPN) {
			
			$SetADUserIdentity = $Identity.sAMAccountName
			$SetADUserUserPrincipalName = "1200{0}@fedidcard.gov" -f $Identity.HSPDPID
			
			$SetADUserSamUPNParams = @{
				'Identity' = $SetADUserIdentity;
				'UserPrincipalName' = $SetADUserUserPrincipalName
			} #end SetADUserSamUPNParams
			
			Switch ($PRODUCTION) {
				LIVE {Set-ADUser @SetADUserSamUPNParams }
				REVIEW {
						$SetADUserIdentity
						$SetADUserUserPrincipalName
				    	}
				} #end Switch-Production
			} #end foreach
		} #end PROCESS
		
		END {
			
		} #end END
	} #end Set-UPNtoHSPDPID
