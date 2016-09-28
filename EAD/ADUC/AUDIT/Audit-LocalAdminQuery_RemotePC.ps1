function Get-Function
{
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
		    NAME: Get-ADTitle
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 8/10/2016 8:25 PM
			LASTEDIT: 8/10/2016 8:25 PM
            KEYWORDS:
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$computerName
	)
	
	BEGIN
	{
		$group = Get-WmiObject win32_group -ComputerName $computerName -Filter "LocalAccount=True AND SID='S-1-5-32-544'"
	} #end BEGIN
	
	PROCESS
	{
		$query = "GroupComponent = `"Win32_Group.Domain='$($group.domain)'`,Name='$($group.name)'`""
        $list = Get-wmiobject win32_groupuser -ComputerName $computerName -Filter $query
        $list | %{$_.PartComponent} | % {$_.substring($_.lastindexof("Domain=") + 7).replace("`",Name=`"","\") }
	} #end PROCESS
	
	END
	{
		
	} #end END
} #end Get-Function

#$computername = Read-Host "Computer Name"
#get-function $computername