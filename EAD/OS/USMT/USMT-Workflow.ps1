function Get-UsersProfileDirectories {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
	.PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Get-UsersProfileDirectories -PRODUCTION LIVE
	
	.NOTES
		    NAME: Get-UsersProfileDirectories
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 9/27/2016 7:42 PM
			LASTEDIT: 9/27/2016 7:42 PM
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
		$Date = Get-Date
        $FunctionName = 'Get-UsersProfileDirectories'
		# Set Profile Path Variable
		$ProfilePath = 'C:\Users'
		
	} #end BEGIN
	
	PROCESS {
		
		
		Switch ($PRODUCTION) {
			LIVE {
				#region List Profile Directories that exist in C:\Users (In Explorer)
				cls				
				# Change Path to ProfilePath
				Set-Location $ProfilePath
				
				# Get All Profiles Installed on this PC
				$UserProfileDirectory = Get-Childitem -path "$ProfilePath\*" | select FullName, BaseName
				
				# Report All Profiles Installed on this PC
                Write-Host "Function name: $ScriptName"
				Write-Host "Function ran: $date"

				$UserProfileDirectory
				#endregion
			} # end LIVE
			REVIEW {
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Get-UsersProfileDirectories

function Get-ProfileListRegistryValue {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
	.PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Get-ProfileListRegistryValue -PRODUCTION LIVE
	
	.NOTES
		    NAME: Get-ProfileListRegistryValue
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 9/27/2016 7:42 PM
			LASTEDIT: 9/27/2016 7:42 PM
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
		[ValidateSet('DELETEProfileList', 'REVIEWProfileList')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
		# Set Profile Path Variable
		$ProfilePath = 'C:\Users'
		
	} #end BEGIN
	
	PROCESS {
		
		
		Switch ($PRODUCTION) {
			DELETEProfileList {
				
				# This will remove all FARGO Domain GUID values that were collected
				foreach ($PSPath in $ProfileLISTAllFARGO_Array.FargoPSPath) {
					#Remove-Item $PSPath -WhatIf
				}
				
			} # end DELETEProfileList
			REVIEWProfileList {
				#region List Registry ProfileList values that exist
				
				# Records the current network path
				Push-Location
				
				# Set Registry ProfileList Path Variable
				$ProfileListPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
				
				# Set Path to $ProfileListPath value
				Set-Location $ProfileListPath
				
				# Gather ProfileListPathAll value, Lists all values in ProfileList Registry entry
				#$ProfileListPathAll = Get-ChildItem -Path $ProfileListPath | % { Get-ItemProperty $_.pspath } | select ProfileImagePath, PSChildName
				$ProfileListPathAll = Get-ChildItem -Path $ProfileListPath | % { Get-ItemProperty $_.pspath }
				
				#$ProfileListPathAll | sort ProfileImagePath
				#$ProfileListPathAll | sort PSChildName
				
				$global:ProfileLISTUSDA_Array = @()
				$global:ProfileLISTFARGO_Array = @()
				$global:ProfileLISTAllOthers_Array = @()
				
				$FargoSIDPattern = 'S-1-5-21-2670568672'
				$USDASIDPattern = 'S-1-5-21-2443529608'
				
				foreach ($ProfileLIST in $ProfileLISTPathAll) {
					
					if ($ProfileLIST -match "$USDASIDPattern*") {
						#region $global:ProfileLISTUSDA_Array
						ForEach ($LIST in $ProfileLIST) {
							
							$ProfileLISTUSDAProperties = [ORDERED]@{
								'USDAProfileImagePath' = ($LIST.ProfileImagePath) -join ','
								'USDAGuid' = ($LIST.Guid) -join ','
								'USDAPSPath' = ($LIST.PSPath) -join ','
								'USDAPSParentPath' = ($LIST.PSParentPath) -join ','
								'USDAPSChildName' = ($LIST.PSChildName) -join ','
							} #end $ProfileLISTUSDAProperties
							
							$ProfileLISTUSDA = New-Object -TypeName PSCustomObject -Property $ProfileLISTUSDAProperties
							$global:ProfileLISTUSDA_Array += $ProfileLISTUSDA
						} #end ForEach ($LIST in $ProfileLIST) $ProfileLISTUSDA_Array
						#endregion  $global:ProfileLISTUSDA_Array	
					} #end if
					elseif ($ProfileLIST -match "$FargoSIDPattern*") {
						#region $global:ProfileLISTFARGO_Array	
						
						ForEach ($LIST in $ProfileLIST) {
							
							$ProfileLISTFARGOProperties = [ORDERED]@{
								'FARGOProfileImagePath' = ($LIST.ProfileImagePath) -join ','
								'FARGOGuid' = ($LIST.Guid) -join ','
								'FARGOPSPath' = ($LIST.PSPath) -join ','
								'FARGOPSParentPath' = ($LIST.PSParentPath) -join ','
								'FARGOPSChildName' = ($LIST.PSChildName) -join ','
							} #end $ProfileLISTUSDAProperties
							
							$ProfileLISTFARGO = New-Object -TypeName PSCustomObject -Property $ProfileLISTFARGOProperties
							$global:ProfileLISTFARGO_Array += $ProfileLISTFARGO
							
						} #end ForEach ($LIST in $ProfileLIST) $ProfileLISTFARGO_Array
						#endregion  $global:ProfileLISTFARGO_Array
					} #end ForEach ($LIST in $ProfileLIST) ProfileLISTFARGO
					
					elseif ($ProfileLIST -notmatch "$FargoSIDPattern*|$USDASIDPattern*") {
						#region $global:ProfileLISTAllOthers_Array
						#"This is neither Fargo nor USDA LIST: $ProfileLIST"
						#$ProfileLIST | select *
						ForEach ($LIST in $ProfileLIST) {
							
							$ProfileLISTAllOthersProperties = [ORDERED]@{
								'OTHERProfileImagePath' = ($LIST.ProfileImagePath) -join ','
								'OTHERGuid' = ($LIST.Guid) -join ','
								'OTHERPSPath' = ($LIST.PSPath) -join ','
								'OTHERPSParentPath' = ($LIST.PSParentPath) -join ','
								'OTHERPSChildName' = ($LIST.PSChildName) -join ','
							} #end $ProfileLISTAllOthersProperties
							
							$ProfileLISTAllOthers = New-Object -TypeName PSCustomObject -Property $ProfileLISTAllOthersProperties
							$global:ProfileLISTAllOthers_Array += $ProfileLISTAllOthers
						} #end $global:ProfileLISTAllOthers_Array foreach
						#endregion  $global:ProfileLISTAllOthers_Array
						
					} #end elseif ($ProfileLIST -notmatch "$FargoSIDPattern*|$USDASIDPattern*")
				}
				
				$ProfileLISTUSDA_Array | fl
				$ProfileLISTAllFARGO_Array | fl
				$ProfileLISTAllOthers_Array | fl
				
				$ProfileLISTUSDA_Array | select USDAProfileImagePath | fl
				$ProfileLISTAllFARGO_Array | select FARGOProfileImagePath | fl
				$ProfileLISTAllOthers_Array | select OTHERProfileImagePath | fl
				#Restores the network path recorded in Push-Location
				Pop-Location
				
				#endregion List Registry ProfileList values that exist
				
			} #end REVIEWProfileList
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Get-ProfileListRegistryValue

#region List Registry ProfileGUID values that exist

# Records the current network path
Push-Location

# Set Registry ProfileGuid Path Variable
$ProfileGuidPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid'

# Set Path to $ProfileGuidPath value
Set-Location $ProfileGuidPath

# Gather ProfileGUIDPathAll value, Lists all values in ProfileGUID Registry entry
$ProfileGUIDPathAll = Get-ChildItem -Path $ProfileGuidPath | % { Get-ItemProperty $_.pspath }
#$ProfileGUIDPathAll = Get-ChildItem -Path $ProfileGuidPath | % { Get-ItemProperty $_.pspath } | select SidString, PSChildname
#$ProfileGUIDPathAll | Sort SidString

$global:ProfileGUIDUSDA_Array = @()
$global:ProfileGUIDFARGO_Array = @()
$global:ProfileGUIDAllOthers_Array = @()

$FargoSIDPattern = 'S-1-5-21-2670568672'
$USDASIDPattern = 'S-1-5-21-2443529608'

foreach ($ProfileGUID in $ProfileGUIDPathAll) {
	
	if ($ProfileGUID -match "$USDASIDPattern*") {
		#$ProfileGUID | select *
		
		#region $global:ProfileGUIDUSDA_Array
		ForEach ($GUID in $ProfileGUID) {
			
			$ProfileGUIDUSDAProperties = [ORDERED]@{
				'USDASIDString' = ($GUID.SidString) -join ','
				'USDAPSPath' = ($GUID.PSPath) -join ','
				'USDAPSParentPath' = ($GUID.PSParentPath) -join ','
				'USDAPSChildName' = ($GUID.PSChildName) -join ','
			} #end $ProfileGUIDUSDAProperties
			
			$ProfileGUIDUSDA = New-Object -TypeName PSCustomObject -Property $ProfileGUIDUSDAProperties
			$global:ProfileGUIDUSDA_Array += $ProfileGUIDUSDA
		} #end $global:ProfileGUIDUSDA_Array foreach
		#endregion  $global:ProfileGUIDUSDA_Array
		
	}
	elseif ($ProfileGUID -match "$FargoSIDPattern*") {
		#$ProfileGUID | select *
		
		#region $global:ProfileGUIDFARGO_Array
		ForEach ($GUID in $ProfileGUID) {
			
			$ProfileGUIDFARGOProperties = [ORDERED]@{
				'FARGOSIDString' = ($GUID.SidString) -join ','
				'FARGOPSPath' = ($GUID.PSPath) -join ','
				'FARGOPSParentPath' = ($GUID.PSParentPath) -join ','
				'FARGOPSChildName' = ($GUID.PSChildName) -join ','
			} #end $ProfileGUIDUSDAProperties
			
			$ProfileGUIDFARGO = New-Object -TypeName PSCustomObject -Property $ProfileGUIDFARGOProperties
			$global:ProfileGUIDFARGO_Array += $ProfileGUIDFARGO
		} #end $global:ProfileGUIDFARGO_Array foreach
		#endregion  $global:ProfileGUIDFARGO_Array
	}
	elseif ($ProfileGUID -notmatch "$FargoSIDPattern*|$USDASIDPattern*") {
		#"This is neither Fargo nor USDA GUID: $ProfileGUID"
		#$ProfileGUID | select *
		#region $global:ProfileGUIDAllOthers_Array
		ForEach ($GUID in $ProfileGUID) {
			
			$ProfileGUIDAllOthersProperties = [ORDERED]@{
				'OTHERSIDString' = ($GUID.SidString) -join ','
				'OTHERPSPath' = ($GUID.PSPath) -join ','
				'OTHERPSParentPath' = ($GUID.PSParentPath) -join ','
				'OTHERPSChildName' = ($GUID.PSChildName) -join ','
			} #end $ProfileGUIDAllOthersProperties
			
			$ProfileGUIDAllOthers = New-Object -TypeName PSCustomObject -Property $ProfileGUIDAllOthersProperties
			$global:ProfileGUIDAllOthers_Array += $ProfileGUIDAllOthers
		} #end $global:ProfileGUIDAllOthers_Array foreach
		#endregion  $global:ProfileGUIDAllOthers_Array
		
	}
}
$ProfileGUIDUSDA_Array | fl
$ProfileGUIDFARGO_Array | fl
$ProfileGUIDAllOthers_Array | fl

$ProfileGUIDUSDA_Array | select USDAPSPath
$ProfileGUIDFARGO_Array | select FargoPSPath
$ProfileGUIDAllOthers_Array | select OthersPSPath

Pop-Location #Restores the network path recorded in Push-Location

# This will remove all FARGO Domain GUID values that were collected
foreach ($PSPath in $ProfileGUIDFARGO_Array.FargoPSPath) {
	#Remove-Item $PSPath -WhatIf
}

#endregion


# Enter profile to migrate (static variable)
$UserToUSMT = 'grant.harrington'
# OR (Allows you to enter text dymnamically)
# $UserToUSMT = Read-Host "Enter Directory To Migrate using USMT"

# Build ProfileImagePath variable
$ProfileImagePath = "{0}\{1}" -f $ProfilePath, $UserToUSMT


$ProfileToRemove = Get-ChildItem -Path $ProfileListPath | % { Get-ItemProperty $_.pspath } | select ProfileImagePath, PSChildName | Where { $_.ProfileImagePath -eq "$ProfileImagePath" }

#Restores the network path recorded in Push-Location
Pop-Location

#endregion




# If PSChildName (aka SID) matches the FARGO SID, we will remove the Registry Value
$FargoSIDPattern = 'S-1-5-21-2670568672'
$USDASIDPattern = 'S-1-5-21-2443529608'
if ($ProfileToRemove.PSChildName -like "$FargoSIDPattern*") {
	"This Profile is FARGO SID and will be removed"
	Remove-Item $_.PSPath -Whatif
}
else {
	"This Profile is a non-FARGO SID and will be ignored"
}


#region ProfileGUID_Array
$global:ProfileGUID_Array = @()

ForEach ($GUID in $ProfileGUIDPathAll) {
	
	
	$ProfileGUIDProperties = [ORDERED]@{
		'MySIDString' = ($GUID.SidString)
		'MyPSPath' = ($GUID.PSPath)
		'MyPSParentPath' = ($GUID.PSParentPath)
		'MyPSChildName' = ($GUID.PSChildName)
	} #end AuditADGroupProperties
	
	$ProfileGUID = New-Object -TypeName PSCustomObject -Property $ProfileGUIDProperties
	$global:ProfileGUID_Array += $ProfileGUID
	
	
}
$ProfileGUID_Array | fl
#endregion


#region ProfileList_Array
$global:ProfileList_Array = @()

ForEach ($LIST in $ProfileListPathAll) {
	
	
	$ProfileListProperties = [ORDERED]@{
		'MyProfileImagePath' = ($LIST.ProfileImagePath)
		'MyGUID' = ($LIST.GUID)
		'MyPSPath' = ($LIST.PSPath)
		'MyPSParentPath' = ($LIST.PSParentPath)
		'MyPSChildName' = ($LIST.PSChildName)
	} #end AuditADGroupProperties
	
	$ProfileList = New-Object -TypeName PSCustomObject -Property $ProfileListProperties
	$global:ProfileList_Array += $ProfileList
	
	
}
$ProfileList_Array | ft -AutoSize
#endregion


$ProfileLISTUSDA_Array.USDAPSChildName | sort
$ProfileLISTFARGO_Array.FARGOPSChildName | sort
$ProfileLISTAllOthers_Array.OTHERPSChildName | sort


$ProfileGUIDUSDA_Array.USDASIDString | sort
$ProfileGUIDFARGO_Array.FARGOSIDString | sort
$ProfileGUIDAllOthers_Array.OTHERSIDString | sort

ForEach-Object
if ($ProfileLISTUSDA_Array.USDAPSChildName -match $ProfileGUIDUSDA_Array.USDASIDString) {
	"Do Something"
}
else {
	"Opps"
}

$MyPSPath = 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid\{7ffa8fa7-433f-4807-ae79-be1285b5a648}'
$MyPSPath2 = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid\{7ffa8fa7-433f-4807-ae79-be1285b5a648}'
Remove-Item $MyPSPath2 -Whatif

#region added 169026
$PC = 'ARSNDFAR42B2700'
$User = 'grant.herges'
$Root = "\\{0}\C`$" -f $PC
$Source = 'Q:\usmt\store\USMT\USMT.MIG'
$Destination = "\\10.170.180.2\public\Software Installers\USMT\{0}" -f $User
New-PSDrive -Name U -PSProvider FileSystem -Root $Root
New-Item 
Copy-Item $Source -Destination $Destination

$dest = "\\10.170.180.2\public\Software Installers\USMT"
Push-Location
cd $dest
Pop-Location

Start-BitsTransfer

Import-Module BitsTransfer
Start-BitsTransfer -Source $Source -Destination $Destination -Description "Backup" -DisplayName "Backup"
#endregion