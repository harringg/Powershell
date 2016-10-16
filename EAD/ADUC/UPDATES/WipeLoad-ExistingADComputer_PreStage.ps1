function Wipe-ADComputerLogging {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
        This function gather's the existing PC's OU, Membership and Description
        It places the existing PC's name into a Global Variable (RemovePC)
        It logs the values to a CSV file for import later in the script and for 
        historical logging/records
	
    .PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Wipe-ADComputerLogging -PRODUCTION LIVE -WipeLoadPC ARSNDFAR4MYTEST
	.NOTES
		    NAME: Wipe-ADComputerLogging
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 9/28/2016 5:03 PM
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
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW',
		[Parameter(Mandatory = $TRUE)]
		[string]$WipeLoadPC
		
	)
	
	BEGIN {
		
		$Date = Get-Date -format yyMMdd
		$ComputerProperties = 'whenCreated', 'Description', 'IPv4Address', 'MemberOf','Name'
		$CSVPath = 'C:\Temp'
		$Global:RemovePC = $WipeLoadPC
	
	} #end BEGIN
	
	PROCESS {
		
		Switch ($PRODUCTION) {
			LIVE {
				$global:ADUCComputersWipeLoadAll_Array = @()
				
				Get-ADComputer $RemovePC -Properties $ComputerProperties |
				ForEach-Object {
					
					$ADUCComputersWipeLoadProperties = [ORDERED]@{
						'sAMAccountName' = ($_.SamAccountName)
						'Name' = ($_.Name)
						'whenCreated' = ($_.whenCreated)
						'Description' = ($_.Description)
						'DistinguishedName' = ($_.DistinguishedName)
						'IPv4Address' = ($_.IPv4Address)
						'MemberOf' = ($_.MemberOf | ForEach-Object { ([regex]"CN=(.*?),").match($_).Groups[1].Value }) -join ","
						'SID' = ($_.SID)
					}
					
					# New PSCustomObject using Properties from HashTable
					$ADUCComputersWipeLoadAll = New-Object -TypeName PSCustomObject -Property $ADUCComputersWipeLoadProperties
					
					$global:ADUCComputersWipeLoadAll_Array += $ADUCComputersWipeLoadAll
					
					$CSVFile = "{0}_{1}_WipeLoad.csv" -f $date, $RemovePC.ToUpper()
					$global:WipeLoadCSV = "{0}\{1}" -f $CSVPath, $CSVFile
					$ADUCComputersWipeLoadAll_Array | Export-Csv $WipeLoadCSV -NoTypeInformation
					
				}
				
				$ADUCComputersWipeLoadAll_Array
				
			} # end LIVE
			REVIEW {
            $global:ADUCComputersWipeLoadAll_Array = @()
				
				Get-ADComputer $RemovePC -Properties $ComputerProperties |
				ForEach-Object {
					
					$ADUCComputersWipeLoadProperties = [ORDERED]@{
						'sAMAccountName' = ($_.SamAccountName)
						'Name' = ($_.Name)
						'whenCreated' = ($_.whenCreated)
						'Description' = ($_.Description)
						'DistinguishedName' = ($_.DistinguishedName)
						'IPv4Address' = ($_.IPv4Address)
						'MemberOf' = ($_.MemberOf | ForEach-Object { ([regex]"CN=(.*?),").match($_).Groups[1].Value }) -join ","
						'SID' = ($_.SID)
					}
					
					# New PSCustomObject using Properties from HashTable
					$ADUCComputersWipeLoadAll = New-Object -TypeName PSCustomObject -Property $ADUCComputersWipeLoadProperties
					
					$global:ADUCComputersWipeLoadAll_Array += $ADUCComputersWipeLoadAll
					
				}
				
				$ADUCComputersWipeLoadAll_Array
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Wipe-ADComputerLogging

function Remove-ADComputerDelete {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	    
        This function will delete the PC stored in $RemovePC from Wipe-ADComputerLogging
        Enterprise Active Directory

	.PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Remove-ADComputerDelete -PRODUCTION LIVE

	.NOTES
		    NAME: Remove-ADComputerDelete
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 9/28/2016 5:03 PM
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
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
		
	} #end BEGIN
	
	PROCESS {
		
		
		Switch ($PRODUCTION) {
			LIVE {
				Remove-ADComputer -Identity $RemovePC -Verbose
			} # end LIVE
			REVIEW {
				Remove-ADComputer -Identity $RemovePC -whatif
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Remove-ADComputerDelete

function New-ADComputerAdd {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
        This function creates a new PC Object in EAD
        Creates variables from the $WipeLoadCSV variable created in Wipe-ADComputerLogging
        Places the existing description value back to the New PC
        Places the NewPC in the Security Groups (assuming write permission to the groups) the RemovePC was in

	.PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> New-ADComputerAdd -PRODUCTION REVIEW
	            PS C:\> New-ADComputerAdd -PRODUCTION LIVE
	.NOTES
		    NAME: New-ADComputerAdd
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 9/28/2016 5:03 PM
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
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
		
		$Date = Get-Date -format yyMMdd
		# CSV created in Wipe-ADComputerLogging.ps1
		$Load = Import-Csv $WipeLoadCSV
		# CSV Headers		
		# sAMAccountName,Name,whenCreated,Description,DistinguishedName,IPv4Address,MemberOf,SID
		
	} #end BEGIN
	
	PROCESS {
		
		Switch ($PRODUCTION) {
			LIVE {
				$computerInstance = new-object Microsoft.ActiveDirectory.Management.ADcomputer
				$SAMAccountName = $Load.sAMAccountName
				$Name = $Load.Name
				$Description = $Load.Description
				#This converts the DistinguishedName and extracts the OU path in order to place the new PC in the same OU
				$Path = $Load.DistinguishedName -replace 'CN=[A-Z0-9]{15},', ''
				
				New-ADComputer -Name $Name -SAMAccountName $SAMAccountName -Instance $computerInstance -Path $Path -Description $Description
				
				# Takes Group1,Group2 and converts to:
				# Group1
				# Group2
				$LoadGroups = $Load.MemberOf -split ','
				
				# This will add back the PC to the security groups it was already a member of			
				$Load.sAMAccountName | Add-ADPrincipalGroupMembership -MemberOf $LoadGroups
			} # end LIVE
			REVIEW {
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end New-ADComputerAdd

function Set-ADComputerACLs {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
        This will assign the same USDA\Domain User ACL's as if performed in the GUI
        GUI
            Select Destination OU
            Right-click > New > Computer
            Enter Computer Name: ARSNDFAR4MYTEST
            Change User or Group: Change... Domain Users (Check Names) > OK
            OK (to Save)
        Requires ACLCLI_DomainUsers.csv file for input

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Set-ADComputerACLs -PRODUCTION REVIEW
				PS C:\> Set-ADComputerACLs -PRODUCTION LIVE
	.NOTES
		    NAME: Set-ADComputerACLs
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 9/28/2016 5:03 PM
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
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
		
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
		$DomainUserACLs = Import-CSV "C:\Temp\ACLCLI_DomainUsers.csv"
		$PCName = $RemovePC
		
	} #end BEGIN
	
	PROCESS {
		
		Switch ($PRODUCTION) {
			LIVE {
				foreach ($UserACL in $DomainUserACLs) {
					
					$ComputerDistinguishedName = Get-ADComputer $PCName | select -ExpandProperty DistinguishedName
					$ACL = (Get-Acl "AD:\$ComputerDistinguishedName")
					
					# $USDADomainUsersSID = (Get-ADGroup ("ARSGNDFAR-ALL-GROUP-ALL-EMPLOYEES")).SID
					# USDA\Domain Users SID = S-1-5-21-DOMAIN-513
					# 'S-1-5-21-2443529608-3098792306-3041422421-513'
					$USDADomainUsersSID = 'S-1-5-21-2443529608-3098792306-3041422421-513'
					$ObjectType = $UserACL.ObjectType
					$ActiveDirectoryRights = $UserACL.ActiveDirectoryRights
					$AccessControlType = $UserACL.AccessControlType
					
					$SID = New-Object System.Security.Principal.SecurityIdentifier $USDADomainUsersSID
					$ObjectGUID = New-Object GUID $ObjectType
					$ADRights = [System.DirectoryServices.ActiveDirectoryRights]"$ActiveDirectoryRights"
					$ACEType = [System.Security.AccessControl.AccessControlType]"$AccessControlType"
					
					$ACE = new-object System.DirectoryServices.ActiveDirectoryAccessRule $sid, $ADRights, $ACEType, $objectguid
					$ACL.AddAccessRule($ACE)
					
					Set-Acl -aclobject $ACL -Path $ACL.Path
					# OR Try this
					#$ACL | set-acl "AD:$ComputerDistinguishedName.distinguishedName"
				}
			} # end LIVE
			REVIEW {
				foreach ($UserACL in $DomainUserACLs) {
					
					$ComputerDistinguishedName = Get-ADComputer $PCName | select -ExpandProperty DistinguishedName
					$ACL = (Get-Acl "AD:\$ComputerDistinguishedName")
					
					# $USDADomainUsersSID = (Get-ADGroup ("ARSGNDFAR-ALL-GROUP-ALL-EMPLOYEES")).SID
					
					$USDADomainUsersSID = 'S-1-5-21-2443529608-3098792306-3041422421-513'
					$ObjectType = $UserACL.ObjectType
					$ActiveDirectoryRights = $UserACL.ActiveDirectoryRights
					$AccessControlType = $UserACL.AccessControlType
					
					$SID = New-Object System.Security.Principal.SecurityIdentifier $USDADomainUsersSID
					$ObjectGUID = New-Object GUID $ObjectType
					$ADRights = [System.DirectoryServices.ActiveDirectoryRights]"$ActiveDirectoryRights"
					$ACEType = [System.Security.AccessControl.AccessControlType]"$AccessControlType"
					
					$ACE = new-object System.DirectoryServices.ActiveDirectoryAccessRule $sid, $ADRights, $ACEType, $objectguid
					$ACL.AddAccessRule($ACE)
					
					Set-Acl -aclobject $ACL -Path $ACL.Path -WhatIf
					# OR Try this
					#$ACL | set-acl "AD:$ComputerDistinguishedName.distinguishedName"
				}
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Set-ADComputerACLs