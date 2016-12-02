<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.3.130
	 Created on:   	12/2/2016 8:07 AM
	 Created by:   	Grant Harrington
	 Organization: 	USDA-ARS
	 Filename:     	Set-ACL_ProtectLabFolder
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
<#
	.SYNOPSIS
		Protect Lab Folder from unathorized access
	
	.DESCRIPTION
		\\COMMON\RU\LAB-SY
		By default, all users of ARSLNDFAR-RU-DFS-MODIFY have read/write/delete access to all folders in \\COMMON\RU
		
		This script performs the following actions:
		1. Remove Include Inheritable permissions setting on LAB-SY folder, setting all Security Properties to <not inherited>
		2. Removes ARSLNDFAR-RU-DFS-MODIFY from Security Tab
		3. Adds ARSLNDFAR-<RU>-DFS-<LAB-SY>-MODIFY to Security Tab with Modify Allow rights and applies them to 'This Folder, Subfolders and Files'
	
	.EXAMPLE
				PS C:\> Set-ACL_ProtectLabFolder
	
	.NOTES
			NAME: Get-ADTitle
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 12/2/2016 8:17 AM
			LASTEDIT: 12/2/2016 8:17 AM
            KEYWORDS:
#>
function Set-ACL_ProtectLabFolder {
	
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet("ANS", "CER", "IGB", "OCD", "SPB", "SUG")]
		[string]$RU,
		[Parameter(Mandatory = $true)]
		[string]$DirToModify,
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
		$ScriptName = 'Script Name: Set-ACL_ProtectLabFolder.ps1'
		$ScriptModifed = 'Script Modified: 12/02/2016 08:48:24'
		$Domain = 'USDA'
		$DFSRootPath = '\\usda.net\ars\pa3060\COMMON'
		$DirToModify = $DirToModify.ToUpper()
		$DirToModifyPath = "{0}\{1}\{2}" -f $DFSRootPath, $RU, $DirToModify
		
		$Date = get-date -f yyMMdd_HHmm
		$OutFilePath = 'C:\SCRIPTS'
		$OutFileFile = "{0}\Logs\{1}_{2}_ProtectLabFolder_Log.txt" -f $OutFilePath, $Date, $DirToModify
		
		$startDate = get-date
		$StartIcacls = icacls $DirToModifyPath
		$StartGetAccessControl = ((Get-Item $DirToModifyPath).GetAccessControl('Access').Access) #This gets the root directory ACL
		$StartLogMessage = "Started processing folder $DirToModifyPath at $startdate"

		#region $IdentityReferenceRemove
		$AccessControlTypeRemove = 'ALLOW'
		$IdentityReferenceRemove = "{0}\ARSLNDFAR-{1}-DFS-MODIFY" -f $Domain, $RU
		$FileSystemRightsRemove = 'Modify, Synchronize'
		$IsInheritedRemove = 'FALSE'
		$InheritanceFlagsRemove = 'ContainerInherit, ObjectInherit'
		$PropagationFlagsRemove = 'None'
		#endregion
		
		#region Action Item 3-Add ARSLNDFAR-<RU>-DFS-<LAB-SY>-MODIFY-$IdentityReferenceAdd
		$AccessControlTypeAdd = 'ALLOW'
		$IdentityReferenceAdd = "{0}\ARSLNDFAR-{1}-DFS-{2}-MODIFY" -f $Domain, $RU, $DirToModify
		$FileSystemRightsAdd = 'Modify, Synchronize'
		$IsInheritedAdd = 'FALSE'
		$InheritanceFlagsAdd = 'ContainerInherit, ObjectInherit'
		$PropagationFlagsAdd = 'None'
		#endregion
		
	} #end BEGIN
	
	PROCESS {
		
		switch ($PRODUCTION) {
			REVIEW {
				
				Write-verbose $StartLogMessage -Verbose
				$StartIcacls
				#Item01 - PathTest
				$PathExist = Test-Path $DirToModifyPath
				
				#region Item01-Test
				if ($PathExist -eq $true)<#Item01 -eq True#> {
					#ScriptContinues - RE: Item01 is True
					#Print Results of Item01
					Write-host "$DirToModifyPath exists"
					#Item02 - RemGroupTest
					$IdentityReferenceRemoveGroup = "ARSLNDFAR-{0}-DFS-MODIFY" -f $RU
					$ADGroupRemove = Get-ADGroup $IdentityReferenceRemoveGroup
					
					#region Item02-Test
					if ($ADGroupRemove -ne $null) <#Item02 -eq True#> {
						#ScriptContinues - RE: Item01 and Item02 are True
						#Print Results of Item02
						write-host "$($ADGroupRemove.name) Exists"
						#Item03 - AddGroupTest
						$IdentityReferenceAddGroup = "ARSLNDFAR-{0}-DFS-{1}-MODIFY" -f $RU, $DirToModify
						$ADGroupAdd = Get-ADGroup $IdentityReferenceAddGroup
						#region Item03-Test
						if ($ADGroupAdd -ne $null) <#Item03 -eq True#> {
							#ScriptContinue - RE: All Items are True
							#Print Results of Item03
							write-host "$($ADGroupAdd.name) Exists"
							Write-host "Script will continue"
							
						} <#end Item03 if#>
						else {
							#ScriptsEnds - RE: Item01 = True, Item02 = True, but Item03 = False
							"$DirToModifyPath does exist, $($ADGroupRemove.name) does exist, but $IdentityReferenceAddGroup does not, script will now exit"
						}<#end Item03 else#>
						#endregion	
					} <#end Item02 if#>
					else {
						#ScriptsEnds - RE: Item01 = True, but Item02 = False
						"$DirToModifyPath does exist, but $($ADGroupRemove.name) does not, script will now exit"
					}<#end Item02 else#>
					#endregion
				} <#end Item01 if#>
				else {
					#ScriptsEnds - RE: Item01 = False
					"$DirToModifyPath Does not exist, script will now exit"
				} <#end Item01 else#>
				#endregion
				
			} #end REVIEW
			LIVE {
				
				#region Capture ACLs To Log-Intial Settings
				#Write-verbose $StartLogMessage
				#Write-verbose $StartIcacls
				#$ScriptName | Out-File $OutFileFile -Append
				#$ScriptModifed | Out-File $OutFileFile -Append
				#$StartLogMessage | Out-File $OutFileFile -Append
				#$StartIcacls | Out-File $OutFileFile -Append
				#$StartGetAccessControl | Out-File $OutFileFile -Append
				#endregion
				
				#region Action Item 1-Remove Include Inheritable permissions setting on LAB-SY folder
				$ACLBreakInheritance = Get-ACL -Path $DirToModifyPath
				$ACLBreakInheritance.SetAccessRuleProtection($True, $True)
				Set-Acl -Path $DirToModifyPath -AclObject $ACLBreakInheritance
				
				#region Capture ACLs To Log-Post Action Item 1
				#$Item1Date = get-date
				#$Item1iCacls = icacls $DirToModifyPath
				#Write-verbose $Item1iCacls -Verbose
				#$Item1Date | Out-File $OutFileFile -Append
				#$Item1iCacls | Out-File $OutFileFile -Append
				#endregion Capture ACLs To Log-Post Action Item 1
				#endregion Action Item 1-Remove Include Inheritable permissions setting on LAB-SY folder
				
				#region Action Item 2-Remove ARSLNDFAR-<RU>-DFS-MODIFY
				$ACLRemoveSecurityGroup = (Get-Item $DirToModifyPath).GetAccessControl('Access')
				$ACERemove = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReferenceRemove, $FileSystemRightsRemove, $InheritanceFlagsRemove, $PropagationFlagsRemove, $AccessControlTypeRemove)
				$ACLRemoveSecurityGroup.removeaccessruleall($ACERemove)
				Set-Acl -Path $DirToModifyPath -AclObject $ACLRemoveSecurityGroup
				
				#region Capture ACLs To Log-Post Action Item 2
				#$Item2Date = get-date
				#$Item2iCacls = icacls $DirToModifyPath
				#Write-verbose $Item2iCacls -Verbose
				#$Item2Date | Out-File $OutFileFile -Append
				#$Item2iCacls | Out-File $OutFileFile -Append
				#endregion Capture ACLs To Log-Post Action Item 2
				#endregion Action Item 2-Remove ARSLNDFAR-<RU>-DFS-MODIFY
				
				#region Action Item 3-Add ARSLNDFAR-<RU>-DFS-<LAB-SY>-MODIFY
				$ACLAddSecurityGroup = (Get-Item $DirToModifyPath).GetAccessControl('Access')
				$ACEAdd = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReferenceAdd, $FileSystemRightsAdd, $InheritanceFlagsAdd, $PropagationFlagsAdd, $AccessControlTypeAdd)
				$ACLAddSecurityGroup.AddAccessRule($ACEAdd) #TODO set vs add, which should be used
				Set-Acl -Path $DirToModifyPath -AclObject $ACLAddSecurityGroup
				
				#$Item3Date = get-date
				#$Item3iCacls = icacls $DirToModifyPath
				#$Item3LogMessage = "Completed Processing $DirToModifyPath at $Item3Date"
				#Write-verbose $EndLogMessage -Verbose
				#$Item3iCacls
				#$Item3iCacls | Out-File $OutFileFile -Append
				#$EndLogMessage | Out-File $OutFileFile -Append
				
				#endregion
				
			} #end LIVE		
		} #end switch $Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Set-ACL_ProtectLabFolder
