#[Modified, 7/6/2016 12:02 PM, Grant Harrington]
#[Modified, 7/7/2016 11:13 AM, Grant Harrington]
function AUDIT-ADGroupMembership {
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
		    NAME: AUDIT-ADGroupMembership
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 2/11/2016 7:48 PM
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
		[ValidateSet('ALL', 'INDIVIDUAL','INDIVIDUALOU')]
		[string]$ReportType,
		[Parameter(Mandatory = $FALSE)]
		[string]$SearchOU,
		[Parameter(Mandatory = $FALSE)]
		[string]$ADGroupName
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
		
	} #end BEGIN
	
	PROCESS {
		
		
		Switch ($ReportType) {
			ALL {
				foreach ($Group in $PA3060_GROUPS.sAMAccountName) {
					$ADGroupName = $Group
					$ADGroup = Get-ADGroup -Identity $ADGroupName -Properties * | select DistinguishedName, CN, Description, Modified
					$ADGroupMember = Get-ADGroupMember -Identity $ADGroupName | sort DistinguishedName | select DistinguishedName
					
					$AuditADGroupAll_Array = @()
					
					$AuditADGroupProperties = [ORDERED]@{
						'ADGroup_DistinguishedName' = ($ADGroup.DistinguishedName)
						'ADGroup_CN' = ($ADGroup.CN)
						'ADGroup_Description' = ($ADGroup.Description)
						'ADGroup_Modified' = ($ADGroup.Modified)
						'ADGroupMember_Name' = ($ADGroupMember.DistinguishedName | ForEach-Object {
							if (($_ -match [regex]"CN=.*\\") -eq $TRUE) {
								$DN_FIRST = $_ -creplace '(^.*\\,\s|\s-.*$)', ''
								$DN_LAST = $_ -creplace '(CN=|\\.*$)', ''
								$Employee = "{0} {1}" -f $DN_FIRST, $DN_LAST;
								$Employee
							} #end if CN=.*\\
							elseif (($_ -match [regex]"(CN=|,OU.*$)") -eq $TRUE) {
								$_ -replace [regex]"(CN=|,OU.*$)", ''
							} #end elseif (CN=|,OU.*$)
						} #end foreach-object
						) -join ','
					} #end AuditADGroupProperties
					
					$AuditADGroupAll = New-Object -TypeName PSCustomObject -Property $AuditADGroupProperties
					$AuditADGroupAll_Array += $AuditADGroupAll
					
					$AuditADGroupAll_Array
				}
			} # end ALL
			INDIVIDUAL {
				$ADGroup = Get-ADGroup -Identity $ADGroupName -Properties * | select DistinguishedName, CN, Description, Modified,MemberOf
				$ADGroupMember = Get-ADGroupMember -Identity $ADGroupName | sort DistinguishedName | select DistinguishedName
				# Fiter by OU

				$AuditADGroupAll_Array = @()
				
				$AuditADGroupProperties = [ORDERED]@{
					'ADGroup_DistinguishedName' = ($ADGroup.DistinguishedName)
					'ADGroup_CN' = ($ADGroup.CN)
					'ADGroup_Description' = ($ADGroup.Description)
					'ADGroup_Modified' = ($ADGroup.Modified)
                    'ADGroup_MemberOf' = ($ADGroup.MemberOf | ForEach-Object {
						if (($_ -match [regex]"CN=.*\\") -eq $TRUE) {
							$DN_FIRST = $_ -creplace '(^.*\\,\s|\s-.*$)', ''
							$DN_LAST = $_ -creplace '(CN=|\\.*$)', ''
							$Employee = "{0} {1}" -f $DN_FIRST, $DN_LAST;
							$Employee
						} #end if CN=.*\\
						elseif (($_ -match [regex]"(CN=|,OU.*$)") -eq $TRUE) {
							$_ -replace [regex]"(CN=|,OU.*$)", ''
						} #end elseif (CN=|,OU.*$)
					} #end foreach-object
					) -join ','
					'ADGroupMember_Name' = ($ADGroupMember.DistinguishedName | ForEach-Object {
						if (($_ -match [regex]"CN=.*\\") -eq $TRUE) {
							$DN_FIRST = $_ -creplace '(^.*\\,\s|\s-.*$)', ''
							$DN_LAST = $_ -creplace '(CN=|\\.*$)', ''
							$Employee = "{0} {1}" -f $DN_FIRST, $DN_LAST;
							$Employee
						} #end if CN=.*\\
						elseif (($_ -match [regex]"(CN=|,OU.*$)") -eq $TRUE) {
							$_ -replace [regex]"(CN=|,OU.*$)", ''
						} #end elseif (CN=|,OU.*$)
					} #end foreach-object
					) -join ','
				} #end AuditADGroupProperties
				
				$AuditADGroupAll = New-Object -TypeName PSCustomObject -Property $AuditADGroupProperties
				$AuditADGroupAll_Array += $AuditADGroupAll
				
				$AuditADGroupAll_Array
			} #end INDIVIDUAL
			INDIVIDUALOU {
                # This switch is the same as INDIVIDUAL, however, it filters on a specific OU
                $ADGroup = Get-ADGroup -Identity $ADGroupName -Properties * | select DistinguishedName, CN, Description, Modified,MemberOf
                $ADGroupMember = Get-ADGroupMember -Identity $ADGroupName |  select DistinguishedName
                $ADGroupMemberOU = $ADGroupMember | where {$_.DistinguishedName -like "*$SearchOU*"} | sort DistinguishedName

				$AuditADGroupAll_Array = @()
				
				$AuditADGroupProperties = [ORDERED]@{
					'ADGroup_DistinguishedName' = ($ADGroup.DistinguishedName)
					'ADGroup_CN' = ($ADGroup.CN)
					'ADGroup_Description' = ($ADGroup.Description)
					'ADGroup_Modified' = ($ADGroup.Modified)
                    'ADGroup_MemberOf' = ($ADGroup.MemberOf | ForEach-Object {
						if (($_ -match [regex]"CN=.*\\") -eq $TRUE) {
							$DN_FIRST = $_ -creplace '(^.*\\,\s|\s-.*$)', ''
							$DN_LAST = $_ -creplace '(CN=|\\.*$)', ''
							$Employee = "{0} {1}" -f $DN_FIRST, $DN_LAST;
							$Employee
						} #end if CN=.*\\
						elseif (($_ -match [regex]"(CN=|,OU.*$)") -eq $TRUE) {
							$_ -replace [regex]"(CN=|,OU.*$)", ''
						} #end elseif (CN=|,OU.*$)
					} #end foreach-object
					) -join ','
					'ADGroupMember_Name' = ($ADGroupMemberOU.DistinguishedName | ForEach-Object {
						if (($_ -match [regex]"CN=.*\\") -eq $TRUE) {
							$DN_FIRST = $_ -creplace '(^.*\\,\s|\s-.*$)', ''
							$DN_LAST = $_ -creplace '(CN=|\\.*$)', ''
							$Employee = "{0} {1}" -f $DN_FIRST, $DN_LAST;
							$Employee
						} #end if CN=.*\\
						elseif (($_ -match [regex]"(CN=|,OU.*$)") -eq $TRUE) {
							$_ -replace [regex]"(CN=|,OU.*$)", ''
						} #end elseif (CN=|,OU.*$)
					} #end foreach-object
					) -join ','
				} #end AuditADGroupProperties
				
				$AuditADGroupAll = New-Object -TypeName PSCustomObject -Property $AuditADGroupProperties
				$AuditADGroupAll_Array += $AuditADGroupAll
				
				$AuditADGroupAll_Array
			} #end INDIVIDUAL
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end AUDIT-ADGroupMembership


<#
$ADGroup = 'ARSG-PA3060-RSAUsers'
$ADGroupDN = Get-ADGroup $ADGroup | select DistinguishedName

$userObject = '[ADSI]"LDAP://usda.net/{0}"' -f $ADGroupDN.DistinguishedName
$userObject = [ADSI]"LDAP://usda.net/CN=ARSG-PA3060-RSAUsers,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net"

$objectOwner = $userObject.PSBase.get_ObjectSecurity().GetOwner([System.Security.Principal.NTAccount]).Value
$objectOwner = $userObject.PSBase.get_ObjectSecurity().Get

$ObjGroup.PSBase | gm
write-host "Name: $userObject.PSBase.Properties.Name"
write-host "Owner: $userObject.PSBase.ObjectSecurity.Owner"
write-host "Created: $userObject.PSBase.Properties.whencreated"
#>
