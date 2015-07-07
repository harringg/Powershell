function Set-SmartCardLoginRequired {
	<#
	.SYNOPSIS
		Sets the SmartcardLogonRequired flag to True (checked)
	
	.DESCRIPTION
        Sets the SmartcardLogonRequired flag to True (checked) programatically
        In the GUI, this setting can be found here:
        First.Last-adm > Properties > Account > Account options: > Smart card is required for interactive login [checked]
        	
	.PARAMETER param1
		param1 Description
	
	.EXAMPLE
				PS C:\> Get-Function -param1 'Value1'
	
	.NOTES
		    NAME:  Set-SmartCardLoginRequired
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 7/7/2015 6:39 AM
			LASTEDIT: 7/7/2015 8:58 AM
            KEYWORDS: ADUC, Lincpass
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

		$SetLoginRequiredADM = Get-ADUser -Filter { samaccountname -like "*-adm" }
		$DomainAdmin = "Fargo\Administrator" 
        $Password = Read-Host "Enter Admin Password" -AsSecureString
        $DomainCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $DomainAdmin, $Password 
		
	} #end BEGIN
	
	PROCESS {

		foreach ($LoginRequired in $SetLoginRequiredADM) {
			
			Switch ($PRODUCTION) {
				LIVE { Set-ADUser -Identity $($LoginRequired.sAMAccountName) -SmartcardLogonRequired:$true -Credential $DomainCredential }
				REVIEW {
                    $($LoginRequired.sAMAccountName)
				}
			} #end Switch PRODUCTION
		} #end foreach

	} #end PROCESS
	
	END {
		
	} #end END
} #end Set-SmartCardLoginRequired
