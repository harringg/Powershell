function Get-LocalAdmin
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
		    NAME: Get-LocalAdmin
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
		[Parameter(Mandatory = $False)]
		[string]$computerName
	)
	
	BEGIN
	{
        $PCList = 'localhost', 'ARSNDFAR4806072'
		#$group = Get-WmiObject win32_group -ComputerName $computerName -Filter "LocalAccount=True AND SID='S-1-5-32-544'"
	} #end BEGIN

	PROCESS
	{
        $PCList |
        ForEach-Object {
        	$group = Get-WmiObject win32_group -ComputerName $_ -Filter "LocalAccount=True AND SID='S-1-5-32-544'"
        $query = "GroupComponent = `"Win32_Group.Domain='{0}'`,Name='{1}'`"" -f $group.domain, $group.name

        $list = Get-wmiobject win32_groupuser -ComputerName $_ -Filter $query
        $list |
        ForEach-Object {
            $_.PartComponent} |
            ForEach-Object {
            $_.substring($_.lastindexof("Domain=") + 7).replace("`",Name=`"","\") 
            }
        }
	} #end PROCESS
	
	END
	{
		
	} #end END
} #end Get-LocalAdmin

#$computername = Read-Host "Computer Name"
#Get-LocalAdmin $computername