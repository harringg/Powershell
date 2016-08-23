function AddRemove-SecurityGroupMembership {
	<#
	.SYNOPSIS
	 Add/Remove PC's to ADUC Security Groups

	.DESCRIPTION
	
	.PARAMETER ADGroup
        SmartCardExempt = 'ARSL-SmartCardExempt-PA3060'
		RSASecurID = 'ARSL-RSA-SecurID-Computers-PA3060'

	.PARAMETER AddRemove
        Add = Add's PC to selected ADGroup
        Remove = Removes's PC from selected ADGroup
        		
	.PARAMETER PCName
        PC Name to add/remove from ADGroup
        	
	.EXAMPLE
				PS C:\> AddRemove-SecurityGroupMembership -ADGroup RSASecurID -AddRemove Add -PCName ARSNDFAR4123456
				PS C:\> AddRemove-SecurityGroupMembership -ADGroup RSASecurID -AddRemove Remove -PCName ARSNDFAR4123456
				PS C:\> AddRemove-SecurityGroupMembership -ADGroup SmartCardExempt -AddRemove Add -PCName ARSNDFAR4123456
				PS C:\> AddRemove-SecurityGroupMembership -ADGroup SmartCardExempt -AddRemove Remove -PCName ARSNDFAR4123456

	.NOTES
		    NAME: AddRemove-SecurityGroupMembership
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 8/23/2016 2:12 PM
            KEYWORDS:
	.LINK
		EAD Scripts
#>

	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $True)]
		[string]$PCName,
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('SmartCardExempt', 'RSASecurID','USGCBSleep','USGCBLocalFirewall','USGCBDrobo')]
		[string]$ADGroup,
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('Add', 'Remove')]
		[string]$AddRemove
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
   		Switch ($ADGroup) {
			SmartCardExempt {
				$SecurityGroup = 'ARSL-SmartCardExempt-PA3060'
			} # end SmartCardExempt
			RSASecurID {
				$SecurityGroup = 'ARSL-RSA-SecurID-Computers-PA3060'
			} #end RSASecurID
			USGCBSleep {
				$SecurityGroup = 'ARS-PA-3060-(5)USGCBExempt-Sleep'
			} #end USGCBSleep
			USGCBLocalFirewall {
				$SecurityGroup = 'ARS-PA-3060-(6)USGCBExempt-Local_Rules'
			} #end USGCBLocalFirewall
			USGCBDrobo {
				$SecurityGroup = 'ARS-PA-3060-(4)USGCBExempt-Drobo'
			} #end USGCBDrobo
		} #end Switch-ADGroup
		
	} #end BEGIN
	
	PROCESS {
		
		Switch ($AddRemove) {
			Add {
				foreach ($PC in $PCName) {
					$PCObject = Get-ADComputer -Identity $PC;
                    # Add PC to specific SecurityGroup
					$PCObject.SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $SecurityGroup
				}
				
			} # end Add
			Remove {
				foreach ($PC in $PCName) {
					$PCObject = Get-ADComputer -Identity $PC;
                    # Remove PC from specific SecurityGroup
                    $PCObject.SamAccountName | Remove-ADPrincipalGroupMembership -MemberOf $SecurityGroup
					
				}
			} #end Remove
		} #end Switch-AddRemove
				
	} #end PROCESS
	
	END {

        Get-ADGroupMember $SecurityGroup | Where {$_.Name -eq $PCName} | sort Name | select Name
		
	} #end END
} #end AddRemove-SecurityGroupMembership