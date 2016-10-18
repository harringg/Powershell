function Get-LocalAdmin {
	<#
	.SYNOPSIS
		Default Synopsis
	
	.DESCRIPTION
		Default Description
	
	.PARAMETER param1
		param1 Description
	
	.EXAMPLE
				PS C:\> Get-Function -param1 'Value1'
	
	.NOTES
		    NAME: Get-LocalAdmin
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 8/10/2016 8:25 PM
			LASTEDIT: 10/18/2016 3:49 PM
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
		[ValidateSet('SinglePC', 'ManualList', 'ImportList')]
		[string]$PCListInput,
		[Parameter(Mandatory = $True)]
		[ValidateSet('Screen', 'ExportCSV')]
		[string]$OutputType
	)
	
	BEGIN {
	
    	switch ($PCListInput) {
			'SinglePC' { $PCList = Read-Host "Enter PC Name" }
			'ManualList' { }
			'ImportList' { }
		} #end Switch PCListInput
		
		$PCList = 'localhost' #, 'ARSNDFAR4806072'
		$LocalGroupFilter = "LocalAccount=True AND SID='S-1-5-32-544'"
	
    } #end BEGIN
	
	PROCESS {
		$PCList |
		ForEach-Object {
			$LocalGroup = Get-WmiObject win32_group -ComputerName $_ -Filter $LocalGroupFilter
			$WMIQuery = "GroupComponent = `"Win32_Group.Domain='{0}'`,Name='{1}'`"" -f $LocalGroup.domain, $LocalGroup.name
			
			$AdminList = Get-wmiobject win32_groupuser -ComputerName $_ -Filter $WMIQuery
			
		} # end ForEach-Object $PCList pipe
		
		$global:AdminGroupMembersAll_Array = @()
		$AdminGroupMembersProperties = @{
			'PCName' = $PCList
			'Objects' = ($AdminList |
			ForEach-Object {
				$_.PartComponent
			} <# end PartComponent#> |
			ForEach-Object {
				$_.substring($_.lastindexof("Domain=") + 7).replace("`",Name=`"", "\")
			} <# end Substring#>) -join ','
		} # end AdminGroupMembersProperties
		
		$AdminGroupMembersAll = New-Object -TypeName PSCustomObject -Property $AdminGroupMembersProperties
		$global:AdminGroupMembersAll_Array += $AdminGroupMembersAll
		
	} #end PROCESS
	
	END {
		switch ($OutputType) {
			'Screen' { $AdminGroupMembersAll_Array | fl }
			'ManualList' { }
			'ImportList' { }
		} #end Switch OutputType
	} #end END
} #end Get-LocalAdmin

#$computername = Read-Host "Computer Name"
#Get-LocalAdmin $computername