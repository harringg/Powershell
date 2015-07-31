function Set-ADUSER_X509_CERT {
	<#
	.SYNOPSIS
		Adds the PIV Cert information to the ADUC EP user using the HSPDPID number
	
	.DESCRIPTION
		Default Description
	
	.PARAMETER param1
		param1 Description
	
	.EXAMPLE
				PS C:\> Get-Function -param1 'Value1'
	
	.NOTES
		    NAME: Set-ADUSER_X509_CERT
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 7/7/2015 6:39 AM
			LASTEDIT: 7/7/2015 10:02 PM
            KEYWORDS: ADUC, PIV, MFA, CERT, HSPDPID
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
		$ImportFileName = "HSPDPID_BB.csv"
		$SamX509Cert = Import-Csv "$ImportFilePath\$ImportFileName"
		$DomainAdmin = "Fargo\Administrator"
		$Password = Read-Host "Enter Admin Password" -AsSecureString
		$DomainCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $DomainAdmin, $Password
	} #end BEGIN
	
	PROCESS {
		foreach ($Identity in $SamX509Cert) {
			
			$ADAdminUserName = "{0}-adm" -f $Identity.sAMAccountName <#Builds the first.last-adm from the first.last name #>
			$X509Name = ($Identity.sAMAccountName).split(".").toupper() -join (" ") <# 8, Builds the Subject CN=FIRST LAST name #>
			$NewX509CertIC = 'C=US' <# 0 #>
            $NewX509CertIO = 'O=Entrust' <# 1 #>
            $NewX509CertIOU01 = 'OU=Certification Authorities' <# 2 #>
            $NewX509CertIOU02 = 'OU=Entrust Managed Services SSP CA' <# 3 #>
            $NewX509CertSC = 'C=US' <# 4 #>
            $NewX509CertSO = 'O=U.S. Government' <# 5 #>
            $NewX509CertSOU ='OU=Department of Agriculture' <# 6 #>
            $NewX509CertSCN01 = 'CN=' <# 7 #>
            $NewX509CertSCN02 = ' OID.0.9.2342.19200300.100.1.1=1200' <# 9, Note: Leading Space before OID #>

            $NewX509Cert = "X509:<I>{0},{1},{2},{3}<S>{4},{5},{6},{7}{8}{9}{10}" -f 
            $NewX509CertIC,
            $NewX509CertIO,
            $NewX509CertIOU01,
            $NewX509CertIOU02,
            $NewX509CertSC,
            $NewX509CertSO,
            $NewX509CertSOU,
            $NewX509CertSCN01,
            $X509Name,
            $NewX509CertSCN02,
            $($Identity.HSPDPID)

			#$NewX509Cert = "X509:<I>C=US,O=Entrust,OU=Certification Authorities,OU=Entrust Managed Services SSP CA<S>C=US,O=U.S. Government,OU=Department of Agriculture,CN=FIRST LAST OID.0.9.2342.19200300.100.1.1=12001234567890"
			
			Switch ($PRODUCTION) {
				LIVE { set-aduser -identity $ADAdminUserName -Add @{ 'altsecurityidentities' = $NewX509Cert } -Credential $DomainCredential }
				REVIEW {
					$ADAdminUserName
					$NewX509Cert
				}
			} #end Switch PRODUCTION
		} #end foreach
	} #end PROCESS
	
	END {
		
	} #end END
} #end Set-ADUSER_X509_CERT
