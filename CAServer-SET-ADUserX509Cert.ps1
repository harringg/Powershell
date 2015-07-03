function Set-ADUserX509Cert {
	<#
	.SYNOPSIS
		Takes the first.last.cer certificate and adds it to the AD first.last-adm altsecurityidentities Attribute
	
	.DESCRIPTION
		This is the Powershell equivilent of ADUC > first.last-adm > Right-Click > Name Mapping... > Add
        Collects a folder full of Lincpass Certificates (*.cer) and adds them to the Elevated Privelage AD account
	
	.PARAMETER param1
		param1 Description
	
	.EXAMPLE
				PS C:\> Set-ADUserX509Cert -PRODUCTION REVIEW
	
	.NOTES
		    NAME: Set-ADUserX509Cert
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 7/2/2015 5:34 PM
			LASTEDIT: 7/2/2015 8:01 PM
            KEYWORDS: ADUC, MultiFactorAuthentication
	.LINK
		Some code modified from:
        https://social.technet.microsoft.com/Forums/lync/en-US/e021e05f-a3b4-43ea-aeb9-487d648477eb/set-ad-user-security-identity-mapping-of-x509-certificate-from-cer-file?forum=winserverpowershell

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

		$CertificateSourcePath = "C:\Temp\Cert"
        $Certificates = Get-ChildItem -Path $CertificateSourcePath | Select *
		
	} #end BEGIN
	
	PROCESS {
		
		foreach ($PIVCert in $Certificates) {
			
            $X509Cert = New-Object system.security.cryptography.X509Certificates.X509Certificate $($PIVCert.FullName)
			$X509CertIssuerPath = [Regex]::Replace($X509Cert.Issuer, ',\s*(CN=|OU=|O=|DC=|C=)', '!$1') -split "!"
			$X509CertSubjectPath = [Regex]::Replace($X509Cert.subject, ',\s*(CN=|OU=|O=|DC=|C=)', '!$1') -split "!"
			$ADAdminUserName = "{0}-adm" -f $($PIVCert.BaseName)
			
            $X509CertIssuer = ""
			# Reverse the path and save as $issuer
			for ($i = $X509CertIssuerPath.count - 1; $i -ge 0; $i--) {
				$X509CertIssuer += $X509CertIssuerPath[$i]
				if ($i -ne 0) {
					$X509CertIssuer += ","
				}
			} #end for $X509CertIssuer
						
			$X509CertSubject = ""
			# Reverse the path and save as $issuer
			for ($i = $X509CertSubjectPath.count - 1; $i -ge 0; $i--) {
				$X509CertSubject += $X509CertSubjectPath[$i]
				if ($i -ne 0) {
					$X509CertSubject += ","
				}
			} #end for $X509CertSubject
			
			# Format as required for altSecurityIdentities
			$NewX509Cert = "X509:<I>{0}<S>{1}" -f $X509CertIssuer,$X509CertSubject

            Switch ($PRODUCTION) {
				LIVE { <# Set the AD user's Cert #> set-aduser -identity $ADAdminUserName -Add @{ 'altsecurityidentities' = $NewX509Cert } }
				REVIEW { <# Review $NewX509Cert #> "$ADAdminUserName `n $NewX509Cert" }
				} #end Switch-Production

			
		}
	} #end PROCESS
	
	END {
		
	} #end END
} #end Set-ADUserX509Cert
