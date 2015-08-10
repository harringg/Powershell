$global:DomainAdmin = "Fargo\Administrator"
$global:Password = Read-Host "Enter Admin Password" -AsSecureString
$global:DomainCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $DomainAdmin, $Password

function EAD-RenameRemotePC {
<#
            .SYNOPSIS 
            Renames existing PC's on the Domain to comply with EAD naming conventions

            .DESCRIPTION
            Reads the BIOS SN, determintes machinetype based on chassis type, and builds a pre-defined naming convention and renames PC to new EAD naming strucure.

            .NOTES
            NAME: EAD-RenameRemotePC
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 5/1/2015 08:52 AM
            LASTEDIT: 8/10/2015 4:43 PM
            KEYWORDS: ADUC, EAD 

            .EXAMPLE
            PS C:\> EAD-RenameLocalPC 

            .EXAMPLE
            PS C:\> GET-HELP EAD-RenameLocalPC -ShowWindow
            
            #>
	[CMDLETBINDING(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet("REVIEW", "LIVE")]
		[string]$PRODUCTION
	)
	
	BEGIN {
		
		
	} #end BEGIN
	
	PROCESS {
		
		$PCList = import-csv "C:\Users\grant.harrington\Desktop\rename.csv."
		
		foreach ($PC in $PCList.AssetName) {
     <# Code modified from source: http://poshcode.org/2996 #>
			$system = Get-WMIObject -class Win32_systemenclosure -ComputerName $PC -Credential $DomainCredential
			$type = $system.chassistypes
			
			Switch ($Type) {
				"1" { "$PC Chassis type is: $Type - Other" }
				"2" { "$PC Chassis type is: $type - Virtual Machine" }
				"3" { "$PC Chassis type is: $type - Desktop" }
				"4" { "$PC Chassis type is: $type - Low Profile Desktop" }
				"5" { "$PC Chassis type is: $type - Pizza Box" }
				"6" { "$PC Chassis type is: $type - Mini Tower" }
				"7" { "$PC Chassis type is: $type - Tower" }
				"8" { "$PC Chassis type is: $type - Portable" }
				"9" { "$PC Chassis type is: $type - Laptop" }
				"10" { "$PC Chassis type is: $type - Notebook" }
				"11" { "$PC Chassis type is: $type - Handheld" }
				"12" { "$PC Chassis type is: $type - Docking Station" }
				"13" { "$PC Chassis type is: $type - All-in-One" }
				"14" { "$PC Chassis type is: $type - Sub-Notebook" }
				"15" { "$PC Chassis type is: $type - Space Saving" }
				"16" { "$PC Chassis type is: $type - Lunch Box" }
				"17" { "$PC Chassis type is: $type - Main System Chassis" }
				"18" { "$PC Chassis type is: $type - Expansion Chassis" }
				"19" { "$PC Chassis type is: $type - Sub-Chassis" }
				"20" { "$PC Chassis type is: $type - Bus Expansion Chassis" }
				"21" { "$PC Chassis type is: $type - Peripheral Chassis" }
				"22" { "$PC Chassis type is: $type - Storage Chassis" }
				"23" { "$PC Chassis type is: $type - Rack Mount Chassis" }
				"24" { "$PC Chassis type is: $type - Sealed-Case PC" }
				Default { "Chassis type is: $type - Unknown" }
			} #end Switch Type
			
        <# Source: USDA-EAD-Object Naming Standards-v1.4.4 #>
			Switch ($Type) {
				"3" { $MachineType = '4' <# Desktop#> }
				"4" { $MachineType = '4' <# Low Profile Desktop #> }
				"5" { $MachineType = '4' <# Pizza Box #> }
				"6" { $MachineType = '4' <# Mini Tower #> }
				"7" { $MachineType = '4' <# Tower #> }
				"8" { $MachineType = '5' <# Portable #> }
				"9" { $MachineType = '5' <# Laptop #> }
				"10" { $MachineType = '5' <# Notebook #> }
				"13" { $MachineType = '4' <# All-in-One #> }
				"14" { $MachineType = '5' <# Sub-Notebook #> }
				"15" { $MachineType = '4' <# Space Saving #> }
				"16" { $MachineType = '4' <# Lunch Box #> }
				"17" { $MachineType = '4' <# Main System Chassis #> }
				"24" { $MachineType = '4' <# Sealed-Case PC #> }
				Default { "Chassis type is: $type - Unknown" }
			} #end Switch MachineType    
			
             <# Sets MachineType to a Script Variable, so subsequent functions can "see" it #>
			$script:MachineType = $MachineType
			
        <# Builds the new PC name #>
			$SN = gwmi win32_bios -computername $PC -Credential $DomainCredential | Select SerialNumber
			$NumberOfCharacters = 6;
			$LastSixOfSN = ($($SN.SerialNumber).Substring($($SN.SerialNumber).Length - $NumberOfCharacters, $NumberOfCharacters) | Out-String).Trim()
			
			$A = 'A'
			$RS = 'RS'
			$State = 'ND'
			$city = 'FAR'
			
			$NewComputerName = "{0}{1}{2}{3}{4}{5}" -f $A, $RS, $State, $City, $MachineType, $LastSixOfSN
			
        <# Gets the current PC name and adds it OldComputerName variable #>
			$OldComputerName = $PC
			
			
        <# This IF-ELSE ensures that new PC name has 15 letters, therefore was named properly above,
           and that the new name and old name are not the same, ie, the script hasn't been run
           already on this PC.
        #>
			IF (($NewComputerName.Length -eq 15) -and ($($OldComputerName) -ne $($NewComputerName))) {
				Write-Output "`n
           $NewComputerName has $($NewComputerName.Length) characters
           OldComputerName variable will be $OldComputerName
           NewComputerName variable will be $NewComputerName `n"
				
				switch ($PRODUCTION) {
					LIVE { $Confirm = Read-Host "Type `"Y`" and press Enter to commit changes. You will be prompted for an Admin Password and your PC will reboot" }
					REVIEW { }
				} #end Switch Production
				
				IF ($Confirm -ieq "Y") {
                    <# This converts the password associated with the $DomainCredential and encrypts
                    it before sending it over the network, so it's not sent in plain text #>
					$DomainCredential = "FARGO\ADMINISTRATOR"
					$SecurePW = Read-Host "Enter Password" -AsSecureString
					$SecureStringPW = New-Object System.Management.Automation.PsCredential $DomainCredential, $SecurePW
					$SecureCredential = $SecureStringPW
					
					$RenameComputerParams = @{
						'ComputerName' = $OldComputerName;
						'NewName' = $NewComputerName;
						'DomainCredential' = $SecureCredential;
					} #end $RenameComputerParams
					
                    <# Remove the '#' before Rename-Computer when ready to run in production #>
					#Rename-Computer @RenameComputerParams -ErrorAction Stop -Force -PassThru -Restart
				}
				else {
					Write-Output "You answered no, script will now end"
				} #end IF-ELSE User confirmed/denied script to run
				
			}
			else {
				
				Write-Output "$NewComputerName does not meet new naming standard for one of the following reasons: `n
                1. PC BIOS did not have a properly registered Serial Number`n
                2. Unable to determine chassis type`n
                3. or PC has already been renamed."
				
			} #end IF-ELSE NewComputerName.length = 15
			
		} #end foreach PC in PCNameList
		
	} #end PROCESS
	
	END {
		
		$PCRenameListParams = [ordered]@{
			OldComputerName = $OldComputerName
			NewComputerName = $NewComputerName
		} #end PCRenameListParams
		
		$Script:PCRenameList = New-Object -TypeName PSObject -Property $PCRenameListParams
		$PCRenameList3 += $PCRenameList
		#		Write-Output $PCRenameList | ft -AutoSize
		
		
	} #end END
	
} #end EAD-RenameRemotePC
