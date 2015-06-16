#REQUIRES -Version 3
function Get-PCChassisType {
<#
            .SYNOPSIS 
            Converts WMI Class win32_systemenclosure to a value to create new PC name for EAD rename

            .DESCRIPTION
            Converts WMI Class win32_systemenclosure to a value to create new PC name for EAD rename

            .NOTES
            NAME: Get-PCChassisType
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 5/1/2015 08:52 AM
            LASTEDIT: 5/1/2015 11:10 AM
            KEYWORDS: ADUC, EAD 

            .EXAMPLE
            PS C:\> Get-PCChassisType

            .EXAMPLE
            PS C:\> GET-HELP Get-PCChassisType -ShowWindow
            
            #>
    [CMDLETBINDING(SupportsPaging = $true,
                SupportsShouldProcess = $true)]
    param(
        )
    
    BEGIN {

       <# Code modified from source: http://poshcode.org/2996 #>
        $system = Get-WMIObject -class Win32_systemenclosure
        $type = $system.chassistypes

         Switch ($Type)
            {
                "1" {"Chassis type is: $Type - Other"}
                "2" {"Chassis type is: $type - Virtual Machine"}
                "3" {"Chassis type is: $type - Desktop"}
                "4" {"Chassis type is: $type - Low Profile Desktop"}
                "5" {"Chassis type is: $type - Pizza Box"}
                "6" {"Chassis type is: $type - Mini Tower"}
                "7" {"Chassis type is: $type - Tower"}
                "8" {"Chassis type is: $type - Portable"}
                "9" {"Chassis type is: $type - Laptop"}
                "10" {"Chassis type is: $type - Notebook"}
                "11" {"Chassis type is: $type - Handheld"}
                "12" {"Chassis type is: $type - Docking Station"}
                "13" {"Chassis type is: $type - All-in-One"}
                "14" {"Chassis type is: $type - Sub-Notebook"}
                "15" {"Chassis type is: $type - Space Saving"}
                "16" {"Chassis type is: $type - Lunch Box"}
                "17" {"Chassis type is: $type - Main System Chassis"}
                "18" {"Chassis type is: $type - Expansion Chassis"}
                "19" {"Chassis type is: $type - Sub-Chassis"}
                "20" {"Chassis type is: $type - Bus Expansion Chassis"}
                "21" {"Chassis type is: $type - Peripheral Chassis"}
                "22" {"Chassis type is: $type - Storage Chassis"}
                "23" {"Chassis type is: $type - Rack Mount Chassis"}
                "24" {"Chassis type is: $type - Sealed-Case PC"}
                Default {"Chassis type is: $type - Unknown"}
             }

        <# Source: USDA-EAD-Object Naming Standards-v1.4.4 #>
         Switch ($Type)
            {
                "3" {$MachineType = '4' <# Desktop#>}
                "4" {$MachineType = '4' <# Low Profile Desktop #>}
                "5" {$MachineType = '4' <# Pizza Box #>}
                "6" {$MachineType = '4' <# Mini Tower #>}
                "7" {$MachineType = '4' <# Tower #>}
                "8" {$MachineType = '5' <# Portable #>}
                "9" {$MachineType = '5' <# Laptop #>}
                "10" {$MachineType = '5' <# Notebook #>}
                "13" {$MachineType = '4' <# All-in-One #>}
                "14" {$MachineType = '5' <# Sub-Notebook #>}
                "15" {$MachineType = '4' <# Space Saving #>}
                "16" {$MachineType = '4' <# Lunch Box #>}
                "17" {$MachineType = '4' <# Main System Chassis #>}
                "24" {$MachineType = '4' <# Sealed-Case PC #>}
                Default {"Chassis type is: $type - Unknown"}
             }
       
        
    } #end BEGIN
    
    PROCESS {
        <# Sets MachineType to a Script Variable, so subsequent functions can "see" it #>
        $script:MachineType = $MachineType

    } #end PROCESS

    END {
    
    } #end END

} #end Get-PCChassisType


function EAD-RenameLocalPC {
<#
            .SYNOPSIS 
            Renames existing PC's on the Domain to comply with EAD naming conventions

            .DESCRIPTION
            Reads the BIOS SN, determintes machinetype based on chassis type, and builds a pre-defined naming convention and renames PC to new EAD naming strucure.

            .NOTES
            NAME: EAD-RenamePC-LocalPC
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 5/1/2015 08:52 AM
            LASTEDIT: 5/1/2015 12:14 PM
            KEYWORDS: ADUC, EAD 

            .EXAMPLE
            PS C:\> EAD-RenameLocalPC 

            .EXAMPLE
            PS C:\> GET-HELP EAD-RenameLocalPC -ShowWindow
            
            #>
    [CMDLETBINDING(SupportsPaging = $true,
                SupportsShouldProcess = $true)]
    param([Parameter(Mandatory=$TRUE)]
        [ValidateSet("REVIEW","LIVE")]
        [string]$PRODUCTION
        )
    
    BEGIN {
        <# Builds the new PC name #>
        $SN = gwmi win32_bios | Select SerialNumber
        $NumberOfCharacters = 6;
        $LastSixOfSN = ($($SN.SerialNumber).Substring($($SN.SerialNumber).Length - $NumberOfCharacters,$NumberOfCharacters) | Out-String).Trim()

        $A = 'A'
        $RS = 'RS'
        $State = 'ND'
        $city = 'FAR'
        Get-PCChassisType <# Calls Get-PCChassisType Funciton to popluate EAD MachineType value #>
        
        $NewComputerName = "{0}{1}{2}{3}{4}{5}" -f $A,$RS,$State,$City,$MachineType,$LastSixOfSN

        <# Gets the current PC name and adds it OldComputerName variable #>
        $OldComputerName = Get-Content env:COMPUTERNAME
        
    } #end BEGIN
    
    PROCESS {
    
        <# This IF-ELSE ensures that new PC name has 15 letters, therefore was named properly above,
           and that the new name and old name are not the same, ie, the script hasn't been run
           already on this PC.
        #>
        IF (($NewComputerName.Length -eq 15) -and ($($OldComputerName) -ne $($NewComputerName))) {
           Write-Output "`n
           $NewComputerName has $($NewComputerName.Length) characters
           OldComputerName variable will be $OldComputerName
           NewComputerName variable will be $NewComputerName `n"
           
           $Confirm = Read-Host "Type `"Y`" and press Enter to commit changes. You will be prompted for an Admin Password and your PC will reboot"

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
                    SWITCH ($PRODUCTION) {
                        LIVE {Rename-Computer @RenameComputerParams -ErrorAction Stop -Force -PassThru -Restart}
                        REVIEW {}
                        } #end Switch PRODUCTION

                } else {
                    Write-Output "You answered no, script will now end"
                } #end IF-ELSE User confirmed/denied script to run

           } else {
                
                Write-Output "$NewComputerName does not meet new naming standard for one of the following reasons: `n
                1. PC BIOS did not have a properly registered Serial Number`n
                2. Unable to determine chassis type`n
                3. or PC has already been renamed."
           
        } #end IF-ELSE NewComputerName.length = 15
       
    } #end PROCESS

    END {
    
    } #end END

} #end EAD-RenameLocalPC

cls
EAD-RenameLocalPC -PRODUCTION REVIEW
