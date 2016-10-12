FUNCTION Audit-ADUser {
<#
            .SYNOPSIS 
            This queries AD and reports on the common parameters for a given user.  To be used with
            "P:\IT\Shared Knowledge\Forms\AuditForms\AUDIT_AD_CHANGE.xsn"

            .DESCRIPTION
            NAME: Audit-ADUser
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            LASTEDIT: 9/29/2016 11:76 AM
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
		[Parameter(Mandatory = $TRUE)]
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

        $ScriptName = 'Audit-ADUser'
        $LastEdit = '9/29/2016 11:76 AM'

	} #end BEGIN

	PROCESS {
		$FilterName = "sAMAccountName -like `"*{0}*`"" -f $SearchUser
		
		#This will gather the AD User name		
		$global:GetUser = Get-ADUser -SearchBase $EAD_PA3060 -filter $FilterName -Properties *
		foreach ($GU in $GetUser) {
			
			$ObjAccountReviewResults = [ordered]@{
				"Script Name" = $ScriptName
				"Script Last Edit Date" = $LastEdit
				"Data Collected" = get-date
				"Full Name" = $GU.CN
				"First Name" = $GU.GivenName
				"Initials" = $GU.Initials
				"Last Name" = $GU.Surname
				"Display Name" = $GU.DisplayName
				"Description" = $GU.Description
				"Office" = $GU.Office
				"Office Phone" = $GU.OfficePhone
				"E-Mail Address" = $GU.EmailAddress
				"REE Web Page" = $GU.wWWHomePage
				"Login Name (UserPrincipalName)" = $GU.UserPrincipalName
				"SamAccountName" = $GU.SamAccountName
				"LogonWorkstations" = $GU.LogonWorkstations
				"Password Never Expires Setting: " = $GU.PasswordNeverExpires
				"Home Drive Letter" = $GU.HomeDrive
				"Home Directory" = $GU.HomeDirectory
				"Information" = $GU.info
				"Title" = $GU.Title
				"Department (RU)" = $GU.Department
				'Manager (Supervisor)' = ($GU.Manager | ForEach-Object {
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
				'DirectReports (Supervisees)' = ($GU.DirectReports | ForEach-Object {
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
				"Member Of" = ($GU.MemberOf | ForEach-Object { ([regex]"CN=(.*?),").match($_).Groups[1].Value }) -join ","
				"Distinguished Name" = $GU.DistinguishedName
				"Account enabled (T/F)" = $GU.Enabled
				"Created" = $GU.Created
				"Modified" = $GU.Modified
				"Last Login" = $GU.LastLogonDate
				"PasswordLastSet" = $GU.PasswordLastSet
				"Last Bad Password Attempt" = $GU.LastBadPasswordAttempt
				"Security ID" = $GU.SID
				"Lincpass/RSA Status" = $GU.extensionAttribute1
			} #end ObjAccountReviewResults
			
			$Global:ObjAccountReview = New-Object -TypeName PSObject -Property $ObjAccountReviewResults
			Write-Output $ObjAccountReview
			
			$ObjAccountReview | clip.exe
		} #end foreach
	} #end PROCESS
} #end Audit-ADUser