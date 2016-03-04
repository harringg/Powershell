#Requires -Version 3
function EAD-UpdateUPN {
            <#
            .SYNOPSIS 
            Renames AD User's SAM and UPN names to match email address
            .DESCRIPTION
            Using the Department field (to filter by individual Research Unit), and the Email Address,
            a new sAMAccountName and UserPrincipleName will be created based on the user's
            Email address syntax
           
            NAME: EAD-UpdateUPN
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 4/20/2015 9:58 PM
            LASTEDIT: 3/4/2016 2:26 PM
            KEYWORDS: ADUC
            .PARAMETER Name
            Specifies the Research Unit
            .NOTES
            .EXAMPLE
            C:\PS> EAD-SetADUserSamUPN -RU ANS -PRODUCTION REVIEW
            This will output the data on screen
            Current UserPrincipleName: harringg@fargo.local
            Current sAMAccountName: harringg
            Email address: grant.harrington@ars.usda.gov
            New UserPrincipleName: grant.harrington@fargo.local
            New sAMAccountName: grant.harrington
            .EXAMPLE
            C:\PS> EAD-SetADUserSamUPN -RU ANS -PRODUCTION LIVE
            This will perform the rename of SAM/UPN and produce a text log of changes made
            #>
	
	[CMDLETBINDING(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet("REVIEW", "LIVE")]
		[string]$PRODUCTION
	)
	
	BEGIN {
		
        <# Change for your environment:
            $ExportPath
            $UPNDomain

         #>
		$Date = get-date -f yyMMdd
		$ExportPath = "L:\IT-Networking Projects\2015-EAD MIGRATION\SamAccountName"
		$ImportPath = "C:\Temp\TEMP FILES"
		$ImportFile = "Sam_UPN-Import"
		
        <# Creates AD Object to modify.  Criteria, existing sAMAccountName is not first.last, Department matches RU, Email address if filled in and is ARS.USDA address #>
		$ImportCSVFile = "{0}\{1}.csv" -f $ImportPath, $ImportFile
		$UpdateUPN = Import-Csv $ImportCSVFile
		
	} #end BEGIN
	
	PROCESS {
        <# Loops through the individuals contained in the $UpdateUPN variable #>
		foreach ($UPN in $UpdateUPN) {
            <# Creates a variable that is the first.last part of the email address to pass onto the $NewSam and $NewUPN variables #>
			$SAM = $UPN.sAMAccountName
			$NewUPN = $UPN.HSPDPID
			
            <# Sets the values for the Set-ADUser parameters #>
			$SetADUserIdentity = "$($SAM)"
			$SetADUserUserPrincipalName = $NewUPN
			
			$SetADUserParams = @{
				'Identity' = $SetADUserIdentity;
				'sAMAccountName' = $SetADUserIdentity;
				'UserPrincipalName' = $SetADUserUserPrincipalName
			} #end SetADUserParams
			
            <# Creates a new custom Object to provide an onscreen list and archival log of the Old,New,Email Address and Department #>
			$props = [ordered]@{
				'sAMAccountName' = "$SetADUserIdentity"
				'New UPN' = "$SetADUserUserPrincipalName"
			}
			
			$obj = New-Object -TypeName PSObject -Property $props
			
            <# This takes existing sAMAccountName to find the AD Object, and updates the sAMAccountName and  UserPrincipalName #>
			
			switch ($PRODUCTION) {
				LIVE {
					Set-ADUser @SetADUserParams;
					$obj | export-csv "$ExportPath\$Date-EAD-SAMAccountNames-$ImportFile.csv" -NoTypeInformation -Append
				}
				REVIEW { Write-output $obj }
			} #end Switch Production
			
		} #end FOREACH 
		
	} #end PROCESS
	
} #end EAD-UpdateUPN
