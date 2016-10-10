#Get-ADObject -Identity:"CN=EMAIL,OU=_EXT_CONTACTS,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net" -IncludeDeletedObjects:$false -Properties:uSNCreated,description,objectClass,whenCreated,ProtectedFromAccidentalDeletion,whenChanged,canonicalName,systemFlags,uSNChanged,allowedAttributesEffective,isDeleted,displayName -Server:"AAGMOKCC3DC2.usda.net"

#Get-ADObject -Identity:"CN=EMAIL,OU=_EXT_CONTACTS,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net" -Properties * | select * | fl

#cls
#get-adobject -LDAPFilter "(&(objectclass=contact)(name=first.last*))" -properties * | fl
#get-adobject -LDAPFilter "(&(objectclass=contact)()" -properties * | fl

FUNCTION Audit-ADObjectContact {
<#
            .SYNOPSIS 
            This queries AD and reports on the common parameters for a given user.  To be used with
            "P:\IT\Shared Knowledge\Forms\AuditForms\AUDIT_AD_CHANGE.xsn"

            .DESCRIPTION
            NAME: Audit-ADObjectContact
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            LASTEDIT: 10/10/2016 5:42 PM
            KEYWORDS: ADUC

            .PARAMETER Name
            $SearchUser = users first or last name (If multiple results appear, rerun with more specifc values)

            .EXAMPLE
            ACCOUNT-REVIEW -SearchUser harrington

            .LINK
            https://ems-mysites.usda.gov/Person.aspx?accountname=ARSNET%5CGrant%2EHarrington

            #>
	
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $FALSE)]
		[string]$SearchUser,
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('PA3060', 'ARS')]
		[string]$SearchBase
	)
	
	BEGIN {
		
		switch ($SearchBase) {
			PA3060 {
				$EAD_PA3060 = 'OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net'
			} #end Local
			ARS {
				$EAD_PA3060 = 'OU=ARS,OU=Agencies,DC=usda,DC=net'
			} #end ARS
		} #end Switch SearchBase
		
		$ScriptName = 'Audit-ADObjectContact'
		$LastEdit = '10/10/2016 5:42 PM'
		
	} #end BEGIN
	
	PROCESS {
		#		$FilterName = "sAMAccountName -like `"*{0}*`"" -f $SearchUser
		
		#This will gather the AD User name
		#        $global:GetContact = get-adobject -SearchBase $EAD_PA3060 -LDAPFilter "(&(objectclass=contact)(name=$SearchUser*))" -properties *
		
		$global:GetContact = get-adobject -SearchBase $EAD_PA3060 -LDAPFilter "(&(objectclass=contact))" -properties *
		
		$global:AuditADContactsAll_Array = @()
		
		foreach ($GU in $GetContact) {
			
			
			$AuditADContactsProperties = [ordered]@{
				"Script Name" = $ScriptName
				"Script Last Edit Date" = $LastEdit
				"Data Collected" = get-date
				"Full Name" = $GU.CN
				"First Name" = $GU.GivenName
				"Initials" = $GU.Initials
				"Last Name" = $GU.sn
				"Display Name" = $GU.DisplayName
				"Description" = $GU.Description
				"Office" = $GU.physicalDeliveryOfficeName
				"Office Phone" = $GU.telephoneNumber
				"E-Mail Address" = $GU.mail
				"MailNickname" = $GU.mailNickname
				"TargetAddress" = $GU.targetAddress
				"LegacyExchangeDN" = $GU.legacyExchangeDN
				"Title" = $GU.Title
				"Member Of" = ($GU.MemberOf | ForEach-Object { ([regex]"CN=(.*?),").match($_).Groups[1].Value }) -join ","
				"Distinguished Name" = $GU.DistinguishedName
				"Created" = $GU.Created
				"Modified" = $GU.Modified
				"ObjectGUID" = $GU.objectGUID
				"ProxyAddresses" = ($GU.proxyAddresses) -join ','
			} #end ObjAccountReviewResults
			
			$AuditADContactsAll = New-Object -TypeName PSCustomObject -Property $AuditADContactsProperties
			$global:AuditADContactsAll_Array += $AuditADContactsAll
			
		} #end foreach
	} #end PROCESS
	
	END {
		$AuditADContactsAll_Array
	} #end END
} #end Audit-ADObjectContact