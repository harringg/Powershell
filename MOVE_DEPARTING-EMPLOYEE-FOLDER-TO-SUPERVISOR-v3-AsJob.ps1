$FunctionScriptMoveEMPtoSUP = { 
    function Move-EMPtoSUP {
    <#
        .SYNOPSIS 
        Searches for outgoing employee and current supervisor directory and moves employee's folder to supervisor's folder with the name ARCHIVE-employee

        .DESCRIPTION
           
        NAME: Move-EMPtoSUP
        AUTHOR: Grant Harrington
        EMAIL: grant.harrington@ars.usda.gov
        CREATION DATE: 1/28/2015 9:11 PM
        LASTEDIT: 6/15/2015 9:19 PM
        KEYWORDS: DFS, NAS

        .PARAMETER Name
        
        .PARAMETER Extension
        
        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .NOTES
        
        .EXAMPLE
        
    #>
        [CMDLETBINDING(SupportsPaging = $true,
                    SupportsShouldProcess = $true)]
        
        param([Parameter(Mandatory=$TRUE)]
        [ValidateSet("REVIEW","LIVE")]
        [string]$PRODUCTION,
        [Parameter(Mandatory=$TRUE)]
        [string]$Employee_Name,
        [Parameter(Mandatory=$TRUE)]
        [string]$Supervisor_Name,
        [Parameter(Mandatory=$TRUE)]
        [ValidateSet("NCSL","BRL","DROBO","TEMP")]
        [string]$FileDir

            )
    
        BEGIN {
            <# Step 01. This will establish if the User and Supervisor are present at all #>    
            $RoboCopyOptionsParams =
            '/e', <# copy subdirectories, including Empty ones. #>
            '/move', <# MOVE files AND dirs (delete from source after copying). #>
            '/NFL', <# LOGGING: No File List - don't log file names. #>
            '/NDL' <# LOGGING: No Directory List - don't log directory names. #>
            $LogDrivePath = "\\np42-ssanncsl\it\Backups\LOGS\ROBOCOPY" #"C:\Temp\Logs" # 
    
            [int]$i = 0
            $Employee_DirectoryToMove = @()
            $Supervisor_DirectoryDestination = @()
            $Employee_DirectoryToArchive = @()
            $Employee_DoWhileLoopCounter = '4'
            $Supervisor_DoWhileLoopCounter = '4'
            # This is the Emplyee that you are searching for
            #$Employee_Name = 'jonathan.fuller'
            # This is the Supervisor that you are searching for
            #$Supervisor_Name = 'michael.edwards'
            #$FileDir = 'NCSL'
            $Employee_DirectoryPath = $null
            $Supervisor_DirectoryPath = $null
            $Employee_Counter = 0
            $Supervisor_Counter = 0
            $ErrorActionParams = 'Ignore'
            Switch ($FileDir) {
                "NCSL" {$FilePath = "\\np42-ssanncsl\e$\Units";$LogDriveName = "NCSL"}
                "BRL" {$FilePath = "\\np42-ssanbrl\z$\Units";$LogDriveName = "BRL"}
                "DROBO" {$FilePath = "\\np42-ssanbrl\f$\Units";$LogDriveName = "DROBO"}
                "TEMP" {$FilePath = "C:\Temp";$LogDriveName = "TEMP"}
            } #end Switch FILEDIR

            $RUFolder = 'Animals','Cereals','Users','Director','Insects','IT','Plants','Sunflowers','Potatoes','Folder05','Folder04','Folder03','Folder02','Folder01'
            $RUFolderHash = 
            'Animals',
            'Cereals',
            'Users',
            'Director',
            'Insects',
            'IT',
            'Plants',
            'Sunflowers',
            'Potatoes',
            'Folder05',
            'Folder04',
            'Folder03',
            'Folder02',
            'Folder01',
            'Test'
            # testing-delete $RU = 'Folder04'
        } #end BEGIN
    
        PROCESS {
        #region ForEach01-EMPLOYEEpath
        <# Search the directories for the Employee Folder, if more than one exists, add it to a new variable #>
        foreach ($RU in $RUFolderHash) {
            $Employee_DirectoryPath = Get-ChildItem "$FilePath\$RU" -filter $Employee_Name -Directory -ErrorAction $ErrorActionParams | Select FullName,Exists
                if ($Employee_DirectoryPath.Exists -eq $true) {
                        #region ForEach01-EMPLOYEEpath IF01
            
                        $Employee_DirectoryToMove += $($Employee_DirectoryPath).FullName
                        $Employee_DirectoryToArchive += "ARCHIVE-$($Employee_Name)"

                        $Employee_Counter++
                } <# END if userpath.exists eq true #>
                        #endregion
        } <# END foreach RU in RUFOLDER #>
        #endregion

        #region ForEach02-SUPERVISORpath
        foreach ($RU in $RUFolderHash) {
            $Supervisor_DirectoryPath = Get-ChildItem "$FilePath\$RU" -filter $Supervisor_Name -Directory -ErrorAction $ErrorActionParams | Select FullName,Exists
            #region ForEach02-SUPERVISORpath IF01
                if ($Supervisor_DirectoryPath.Exists -eq $true) {
                    $Supervisor_DirectoryDestination += $($Supervisor_DirectoryPath).FullName

                    $Supervisor_Counter++
                } <# END if superrpath.exists eq true #>
                #endregion
        } <# END foreach RU in RUFOLDER #>
        #endregion

        <# Supervisor and Employee both have at least one Directory each#>
        if ($Supervisor_Counter -gt '0' -and $Employee_Counter -gt '0') { <#Bif1#>
            
            <# Supervisor and Employee both have exactly one Directory each #>
            if ($Supervisor_Counter -eq '1' -and $Employee_Counter -eq '1') { <#Bif2#>
                
                <# Determine if Employee_DirectoryToMove exists #>
                if ($Employee_DirectoryToMove -ne $FALSE)  { <#Bif3#>
                    
                    <# Determine if Employee_DirectoryToMove contains any data, or is empty #>
                    $Employee_DirectoryContents = Get-ChildItem $Employee_DirectoryToMove | select *
                    
                    <# If Employee_DirectoryToMove contains no data, delete the unused directory #>
                    if ($Employee_DirectoryContents.count -eq 0) { <#Bif4#>
                        Write-Verbose "Folder $Employee_DirectoryToMove is empty and will be removed"
                       # Remove-Item -Path $Employee_DirectoryToMove -Force
                        #$FolderGone = Test-Path $Employee_DirectoryToMove 
                         #   if ($FolderGone -eq $FALSE) {
                          #      Write-Verbose "$Employee_DirectoryToMove was successfully removed"
                           #     }

                    <# Else Employee_DirectoryToMove contains data, move it to Supervisor's folder #>             
                    } <#Eif4#> else { <#Belse1#>
                        Write-Verbose "Folder $Employee_Name (Employee) contains data"
                        Write-Verbose "A single directory for each $Supervisor_Name (Supervisor) and $Employee_Name (Employee) was found`n
                        Employee's $Employee_Name directory $Employee_DirectoryToMove will be moved to
                        Supervisor's $Supervisor_Name directory $Supervisor_DirectoryDestination\$Employee_DirectoryToArchive"
                        Switch ($PRODUCTION) {
                            LIVE {robocopy "$Employee_DirectoryToMove" "$Supervisor_DirectoryDestination\$Employee_DirectoryToArchive" @RoboCopyOptionsParams /log:"$LogDrivePath\$Employee_Name-$LogDriveName.log" /TEE}
                            REVIEW {}
                            } #end Switch PRODUCTION

                        #ii "$LogDrivePath\$Employee_Name-$LogDriveName.log"
                    } <#Eelse01#>
                
                } <#Eif3#>

                <# Else there is more than one Folder of either Supervisor or Employee, list all Folders #>
            } <#Eif2#> else { <#Belse2#>
                Write-Verbose "$Supervisor_Name (Supervisor) has $Supervisor_Counter directories"
     
                $Supervisor_DirectoryDestination_Counter = 0
                    DO {
                        $Supervisor_DirectoryDestination[$Supervisor_DirectoryDestination_Counter]
                        $Supervisor_DirectoryDestination_Counter++
                    } <# END DO-WHILE SUPorEMPgt1_SUP  #>
                    WHILE ($Supervisor_DirectoryDestination_Counter -lt $Supervisor_DoWhileLoopCounter)

                Write-Verbose "$Employee_Name (Employee) has $Employee_Counter directories"

                $Employee_DirectoryToMove_Counter = 0
                    DO {
                        $Employee_DirectoryToMove[$Employee_DirectoryToMove_Counter]
                        $Employee_DirectoryToMove_Counter++
                    } <# END DO-WHILE SUPorEMPgt1_EMP  #>
                    WHILE ($Employee_DirectoryToMove_Counter -lt $Employee_DoWhileLoopCounter)

                Remove-Variable Supervisor_DirectoryDestination -ErrorAction $ErrorActionParams
                Remove-Variable Employee_DirectoryToMove -ErrorAction $ErrorActionParams
                Remove-Variable Employee_ArchiveDirectory -ErrorAction $ErrorActionParams
            } <#Eelse2#>
          
          <# At least one (or both) Supervisor or Employee Folder does not exist #>
        } <#Eif1#> else { <#Belse3#>

            <# Neither Supervisor or Employee Folder exists #>
            if ($Supervisor_Counter -eq '0' -and $Employee_Counter -eq '0') {
                Write-Verbose "Supervisor named $Supervisor_Name was not found."
                Write-Verbose "Employee named $Employee_Name was not found."
                Remove-Variable Supervisor_DirectoryDestination -ErrorAction $ErrorActionParams
                Remove-Variable Employee_DirectoryToMove -ErrorAction $ErrorActionParams
                Remove-Variable Employee_ArchiveDirectory -ErrorAction $ErrorActionParams
        
            <# Supervisor Folder exists, but Employee Folder does not exist #>
            } elseif ($Supervisor_Counter -gt '0' -and $Employee_Counter -eq '0') {
                Write-Verbose "Supervisor named $Supervisor_Name was found"

                $Supervisor_DirectoryDestination_Counter = 0
                    DO {
                        $Supervisor_DirectoryDestination[$Supervisor_DirectoryDestination_Counter]
                        $Supervisor_DirectoryDestination_Counter++
                    } <# END DO-WHILE SUPorEMPgt1_SUP  #>
                    WHILE ($Supervisor_DirectoryDestination_Counter -lt $Supervisor_DoWhileLoopCounter)

                Write-Verbose "Employee named $Employee_Name was not found"
                Remove-Variable Supervisor_DirectoryDestination -ErrorAction $ErrorActionParams
                Remove-Variable Employee_DirectoryToMove -ErrorAction $ErrorActionParams
                Remove-Variable Employee_ArchiveDirectory -ErrorAction $ErrorActionParams
        
            <# Supervisor Folder does not exist, but Employee Folder does exist #>
            } elseif ($Supervisor_Counter -eq '0' -and $Employee_Counter -gt '0') {
                Write-Verbose "Supervisor named $Supervisor_Name was not found"
                Write-Verbose "Employee named $Employee_Name was found"

                $Employee_DirectoryToMove_Counter = 0
                    DO {
                        $Employee_DirectoryToMove[$Employee_DirectoryToMove_Counter]
                        $Employee_DirectoryToMove_Counter++
                    } <# END DO-WHILE SUPorEMPgt1_EMP  #>
                    WHILE ($Employee_DirectoryToMove_Counter -lt $Employee_DoWhileLoopCounter)

                Remove-Variable Supervisor_DirectoryDestination -ErrorAction $ErrorActionParams
                Remove-Variable Employee_DirectoryToMove -ErrorAction $ErrorActionParams
                Remove-Variable Employee_ArchiveDirectory -ErrorAction $ErrorActionParams
            } <# END elseif COUNTEMP gt 0 COUNTSUP eq 0 #>

        } <#Eelse3#> <# END else COUNTEMP -and COUNTSUP -gt 0 #>

        } #end PROCESS

        END {
    
        } #end END

    } #end Move-EMPtoSUP
} #end $FunctionScriptMoveEMPtoSUP

start-job -InitializationScript $FunctionScriptMoveEMPtoSUP -ScriptBlock {
            Move-EMPtoSUP -Verbose
        } <# END START-JOB SCRIPTBLOCK #>

#start-transcript -path c:\Temp\Logs\transcript0.txt -noclobber
