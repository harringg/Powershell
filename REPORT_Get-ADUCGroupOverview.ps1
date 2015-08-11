function Get-ADUCGroupOverview {
	<#
	.SYNOPSIS
		Creates a report showing AD Security Group names, creation date, modified date, description and other data.
	
	.DESCRIPTION
		Creates a report showing AD Security Group names, creation date, modified date, description and other data.
	
	.PARAMETER Screen-FullList
		Screen-FullList Outputs a list on-screen

	.PARAMETER Export-CSV
		Export-CSV Outputs a list in .CSV format to the path/file designated in the Begin section of the report
	
	.EXAMPLE
				PS C:\> Get-ADUCGroupOverview -Output Screen-FullList
	
	.NOTES
		    NAME: Get-ADUCGroupOverview
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 8/11/2015 1:32 PM
			LASTEDIT: 8/11/2015 1:48 PM
            KEYWORDS: ADUC, EAD
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet("Screen-FullList", "Export-CSV")]
		[string]$Output
	)
	
	BEGIN {
		$GET_ADGroupAll = Get-ADGroup -LdapFilter "((!member=*))" -properties * | where{ $_.groupCategory -match 'security' } | select *
	    $date = get-date -f yyMMdd_HHmm
		
		$ServerPath = '\\fargo\dfs\Public\IT\Shared Knowledge\IT-Networking Projects'
		$ServerFolder = '2015-EAD MIGRATION'
		$ServerFile = 'ADSecurityGroupOverview'
		
		$OutputListParam = "{0}\{1}\{2}_{3}.csv" -f $ServerPath, $ServerFolder, $date, $ServerFile
		
		
	} #end BEGIN
	
	PROCESS {
		$Output_GetADGroups = @()
		foreach ($GET_ADGroup in $GET_ADGroupAll) {
			
			$GET_ADGroupProps = [ordered]@{
				SamAccountName = $GET_ADGroup.SamAccountName
				whenCreated = $GET_ADGroup.whenCreated
				whenChanged = $GET_ADGroup.whenChanged
				Description = $GET_ADGroup.Description
				DisplayName = $GET_ADGroup.DisplayName
				DistinguishedName = $GET_ADGroup.DistinguishedName
				GroupCategory = $GET_ADGroup.GroupCategory
				GroupScope = $GET_ADGroup.GroupScope
				isCriticalSystemObject = $GET_ADGroup.isCriticalSystemObject
				LastKnownParent = $GET_ADGroup.LastKnownParent
				ManagedBy = $GET_ADGroup.ManagedBy
				ObjectClass = $GET_ADGroup.ObjectClass
				ObjectGUID = $GET_ADGroup.ObjectGUID
				objectSid = $GET_ADGroup.objectSid
				ProtectedFromAccidentalDeletion = $GET_ADGroup.ProtectedFromAccidentalDeletion
				sDRightsEffective = $GET_ADGroup.sDRightsEffective
				SID = $GET_ADGroup.SID
			} #end GET_ADGroupProps
			
			$GET_ADGroupObj = New-Object -TypeName PSObject -Property $GET_ADGroupProps
			$Output_GetADGroups += $GET_ADGroupObj
			
		} #end foreach GET_ADGroup in GET_ADGroupAll
		
		Switch ($OUTPUT) {
			Screen-FullList {
				Write-Output $Output_GetADGroups | sort whenCreated | ft -AutoSize
			} #end Screen-FullList
			
			Export-CSV {
				$Output_GetADGroups | export-csv "$OutputListParam" -NoTypeInformation
			} #end Export-CSV
		} #end Switch OUTPUT
		
	} #end PROCESS
	
	END {
		
		
	} #end END
	
} #end Get-ADUCGroupOverview
