FUNCTION Audit-ADUserOrgChart {
<#
            .SYNOPSIS 
            This queries AD and reports Employee, Manager, Direct Reports, Title and Department (as filled out in EAD)

            .DESCRIPTION
            NAME: Audit-ADUserOrgChart
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            LASTEDIT: 9/29/2016 11:55 AM
            KEYWORDS: ADUC

            .PARAMETER Name
            $SearchUser = users first or last name (If multiple results appear, rerun with more specifc values)

            .EXAMPLE
            Audit-ADUserOrgChart -SearchUser grant.harrington -SearchBase ARS

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

        $ExportPath = 'C:\Temp'
        $ExportFileName = 'OCIO_OrgChart'
        $CSVExport = "{0}\{1}.csv" -f $ExportPath, $ExportFileName
		switch ($SearchBase) {
			PA3060 {
				$EAD_PA3060 = 'OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net'
			} #end Local
			ARS {
				$EAD_PA3060 = 'OU=ARS,OU=Agencies,DC=usda,DC=net'
			} #end ARS
		} #end Switch SearchBase

        $ScriptName = 'Audit-ADUserOrgChart'
        $LastEdit = '9/29/2016 11:33 AM'

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
				"Full Name" = "{0} {1}" -f $GU.GivenName,$GU.Surname
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
				"Distinguished Name" = $GU.DistinguishedName
				} #end ObjAccountReviewResults
			
			$ObjAccountReview = New-Object -TypeName PSObject -Property $ObjAccountReviewResults
			Write-Output $ObjAccountReview
            $CSVExport
			$ObjAccountReview | export-csv $CSVExport -NoTypeInformation -Append
			$ObjAccountReview | clip.exe
		} #end foreach
	} #end PROCESS
} #end Audit-ADUserOrgChart