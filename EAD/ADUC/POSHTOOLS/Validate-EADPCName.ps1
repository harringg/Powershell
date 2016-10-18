function Validate-EADPCName {
<#
	.SYNOPSIS
		
	Validate that PC
	.DESCRIPTION
		
	
	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
		REVIEW run the script to review results before running live in production enviroment
		Verb-Noun -PRODUCTION REVIEW
		LIVE Will run the script live in production enviroment
		Verb-Noun -PRODUCTION LIVE
	
	.PARAMETER REPORTTYPE
		
	
	.EXAMPLE
		PS C:\> Export-GPOReports -ReportType HTML -PRODUCTION REVIEW
		PS C:\> Export-GPOReports -ReportType HTML -PRODUCTION LIVE
	
	.OUTPUTS
		System.Array
	
	.NOTES
		NAME: Validate-EADPCName
		AUTHOR: Grant Harrington
		EMAIL: grant.harrington@ars.usda.gov
		CREATED: 2/11/2016 7:48 PM
		LASTEDIT: 9/29/2016 2:52 PM
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
		[ValidateSet('FAR', 'EGF')]
		[string]$DeviceLocation = 'FAR',
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('DESKTOP', 'LAPTOP')]
		[string]$DeviceType,
		[Parameter(Mandatory = $TRUE)]
		[string]$SerialNumber
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
		
		switch ($DeviceLocation) {
			FAR {
				$Location = 'ARSNDFAR'
			} #end FAR
			EGF {
					$Location = 'ARSMNEGF'
			} #end EGF
		} #end Switch
		
		switch ($DeviceType) {
			DESKTOP {
				$Device = '4'
			} #end DESKTOP
			LAPTOP {
				$Device = '5'
			} #end LAPTOP
		} #end Switch
		
	} #end BEGIN
	
	PROCESS {
		
		
		Switch ($PRODUCTION) {
			LIVE {
                # Builds PC Name based on Location (FAR/EGF), Device Type (DESKTOP/LAPTOP), and last six of Device Serial Number
                # if statement checks that value entered in SerialNumber variable is six charcters or more
                # if True, extracts only last six charcters and converts them to all UPPER case
                # if False, ignores conversion of True statement, re: 1,2,3,4 or 5 minus 6 results in negative number
                if ($SerialNumber.Length -ge 6) {
                $SerialNumber = ($SerialNumber.substring($SerialNumber.length - 6, 6)).ToUpper()
                } #end if
                $global:EADName = "{0}{1}{2}" -f $Location, $Device, $SerialNumber
                # Checks that name equals 15 charachters ((ARSNDFAR = 8) + (4 = 1) + (123456 = 6) = 15)
				if ($EADName.length -eq '15') {
					Write-Host "This PC, $EADName, is properly named to meet EAD Naming Standards" -ForegroundColor White -BackgroundColor Green
                    # If PC name is correct, check is ran to see if it's located in EAD
                    $EADCheck = Get-ADComputer -Identity $EADname -ErrorAction Ignore
                        # IF PC name is correct and is located in EAD, "Do Something"
                        if ($EADCheck -like "*DC=USDA*") {
                            $EADCheck
                            $EADCheck = $ExistingPC
                            $ExistingPC
                        } else {
                            Write-Host "$EADName does not exist in Enterprise Active Directory"
                        } #end if ($EADCheck -like "*DC=USDA*")
                    
				} else {
                    Write-Host "This PC, $EADName, does not meet EAD Naming Standards, it is $($EADName.length) characters and requires 15" -ForegroundColor White -BackgroundColor DarkRed
                    BREAK
                } #end if ($EADName.length -eq '15')
			} # end LIVE
			REVIEW {
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Validate-EADPCName