$global:DomainAdmin = "Administrator"
$global:Password = Read-Host "Enter Admin Password" -AsSecureString
$global:DomainCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $DomainAdmin, $Password

function Move-ADGroupMembers {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
	.PARAMETER SourceGroup
        This is the existing ADUC Security Group you want to review

    .PARAMETER SourceGroup
        This is the existing ADUC Security Group you want to move users to

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Move-ADGroupMembers -SourceGroup 'G_RU_ALL' -DestGroup 'ARSGNDFAR-RU-GROUP-ALL' -PRODUCTION REVIEW
	            PS C:\> Move-ADGroupMembers -SourceGroup 'G_RU_ALL' -DestGroup 'ARSGNDFAR-RU-GROUP-ALL' -PRODUCTION LIVE
	.NOTES
		    NAME: Move-ADGroupMembers
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 2/22/2016 6:00 PM
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
		[string]$SourceGroup,
		[Parameter(Mandatory = $TRUE)]
		[string]$DestGroup,
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
				# This gets the group members sAMAccountNames as an array
				$SourceGroupMembers = Get-ADGroupMember $SourceGroup | select sAMAccountName
				
				# Loops through the sAMAccountName array of the SourceGroupMembers
				foreach ($SourceMember in $SourceGroupMembers) {
					
					# Loops through the sAMAccountName array of the DestGroup
					foreach ($DestMember in $DestGroup) {
						
						$DestGroupMembers = Get-ADGroupMember $DestMember | select sAMAccountName
						
						IF ($DestGroupMembers.sAMAccountName -match $SourceMember.sAMAccountName) {
							Write-Output "$($SourceMember.sAMAccountName) exists in $DestGroup and will be skipped"
						} #end IF
						ELSE {
							Write-Output "$($SourceMember.sAMAccountName) does not exist does not exist in $DestGroup and will be added now...."
							Add-ADGroupMember $DestGroup -Members $SourceMember
						} #end ELSE
					} #end foreach $DestGroup
				} #end foreach $SourceGroupMembers
			} # end LIVE
			
			REVIEW {
				# This gets the group members sAMAccountNames as an array
				$SourceGroupMembers = Get-ADGroupMember $SourceGroup | select sAMAccountName
				
				# Loops through the sAMAccountName array of the SourceGroupMembers
				foreach ($SourceMember in $SourceGroupMembers) {
					
					# Loops through the sAMAccountName array of the DestGroup
					foreach ($DestMember in $DestGroup) {
						
						$DestGroupMembers = Get-ADGroupMember $DestMember | select sAMAccountName
						
						IF ($DestGroupMembers.sAMAccountName -match $SourceMember.sAMAccountName) {
							Write-Output "$($SourceMember.sAMAccountName) exists in $DestGroup and will be skipped"
						} #end IF
						ELSE {
							Write-Output "$($SourceMember.sAMAccountName) does not exist does not exist in $DestGroup and will be added now...."
							Add-ADGroupMember $DestGroup -Members $SourceMember -WhatIf
						} #end ELSE
					} #end foreach $DestGroup
				} #end foreach $SourceGroupMembers
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Move-ADGroupMembers
