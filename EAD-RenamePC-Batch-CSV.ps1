$global:DomainAdmin = "fargo\administrator"
$global:Password = Read-Host "Enter Admin Password" -AsSecureString
$global:DomainCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $DomainAdmin, $Password

function EAD-RenameComputersBatchCSV {
<#
            .SYNOPSIS 
            Renames existing PC's on the Domain to comply with EAD naming conventions

            .DESCRIPTION
            Imports a .csv file with current PC and a new PC name, renames PC, and reboots to apply new PC name
            
            .PARAMETER PRODUCTION
		    This is used to review your results before actually running the script
            
            REVIEW run the script to review results before running live in production enviroment ("Measure twice, cut once")
            Verb-Noun -PRODUCTION REVIEW
            
            LIVE Will run the script live in production enviroment
            Verb-Noun -PRODUCTION LIVE

            .NOTES
            NAME: EAD-RenameComputersBatchCSV
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 3/16/2015 5:02 PM
            LASTEDIT: 2/24/2016 10:45 AM
            KEYWORDS: ADUC, EAD

            CSV (Launch Excel, Save As, CSV (Comma Delimited) (*.csv)
            Cell A1 = Assetname
            Cell B1 = EADName
            Cell A2 = "Old PC Name"
            Cell B2 = "New PC Name"

            AssetName,EADName
            NP42-PC01,ARSNDFAR4xxxxxx
            NP42-PC02,ARSNDFAR5xxxxxx

            .EXAMPLE
            PS C:\> EAD-RenameComputersBatchCSV -PRODUCTION REVIEW

            .EXAMPLE
            PS C:\> EAD-RenameComputersBatchCSV -PRODUCTION LIVE

            
            #>
       [CMDLETBINDING(SupportsPaging = $true,
                              SupportsShouldProcess = $true)]
       param (
              [Parameter(Mandatory = $TRUE)]
              [ValidateSet('REVIEW', 'LIVE')]
              [string]$PRODUCTION = 'REVIEW'
       )
       
       BEGIN {

    	$ServerPath = '\\10.170.180.2\Public\IT\Shared Knowledge\IT-Networking Projects'
		$ServerFolder = '2015-EAD MIGRATION\ADUC_COMPUTERS'
		$ServerFile = '160129_DHCP_RenamePCs-a'
		
		$SourceListParam = "{0}\{1}\{2}.csv" -f $ServerPath, $ServerFolder, $ServerFile
		$EADNameList = Import-Csv $SourceListParam
              
              
       } #end BEGIN
       
       PROCESS {
              
              FOREACH ($StrEADName in $EADNameList) {
                    
                     $ComputerName = $StrEADName.AssetName
                     $NewName = $StrEADName.EADName
                     $RenameComputerParams = @{
                           'ComputerName' = $ComputerName;
                           'NewName' = $NewName;
                           'DomainCredential' = $DomainCredential;
                     } #end $RenameComputerParams
                     
                     Switch ($PRODUCTION) {
                           LIVE { Rename-Computer @RenameComputerParams -Force -PassThru -Restart } #end LIVE
                           REVIEW {  
                                    IF (($StrEADName.EADName).length -eq '15') {
                                            "$NewName is valid"
                                            Write-Host "Old PC Name: $ComputerName"
                                     Write-Host "New PC Name: $NewName"
                                    } ELSE {
                                        "$NewName is invalid, please rename"
                                        Write-Host "Old PC Name: $ComputerName"
                                        Write-Host "New PC Name: $NewName"
                                    } #end IF-ELSE
                                   } #end REVIEW
                     } #end Switch-Production
                     
              } #end foreach $EADNameList
              
       } #end PROCESS
       
       END {
              
       } #end END
       
} #end EAD-RenameComputersBatchCSV
