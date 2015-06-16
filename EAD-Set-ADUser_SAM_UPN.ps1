#Requires -Version 3
function EAD-SetADUserSamUPN {
            <#
            .SYNOPSIS 
            Renames AD User's SAM and UPN names to match email address

            .DESCRIPTION
            Using the Department field (to filter by individual Research Unit), and the Email Address,
            a new sAMAccountName and UserPrincipleName will be created based on the user's
            Email address syntax
           
            NAME: EAD-SetADUserSamUPN
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 4/20/2015 9:58 PM
            LASTEDIT: 6/12/2015 11:28 AM
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
    param(
        [Parameter(Mandatory=$TRUE,ParameterSetName='RU')]
        [ValidateSet("ANS","CER","IGB","SUG","SPB","SIMP")]
        [string]$RU,
        [ValidateSet("REVIEW","LIVE")]
        [string]$PRODUCTION
        )
    
    BEGIN {
        
        <# Change for your environment:
            $ExportPath
            $UPNDomain
            Switch ($RU) values
         #>
        $Date = get-date -f yyMMdd
        $ExportPath = "L:\IT-Networking Projects\2015-EAD MIGRATION\SamAccountName"
        $UPNDomain = "@fargo.local"

        <# Determines the Reserach Unit based on the RU value entered to search Department field of ADUC #>
        Switch ($RU) {
            "ANS" {$RUDEPT = '*animal*'}
            "CER" {$RUDEPT = '*cereal*'}
            "IGB" {$RUDEPT = '*insect*'}
            "SUG" {$RUDEPT = '*sugar*'}
            "SPB" {$RUDEPT = '*sunflower*'}
            "SIMP" {$RUDEPT = '*simps*'}
            } #end Switch

        <# Creates AD Object to modify.  Criteria, existing sAMAccountName is not first.last, Department matches RU, Email address if filled in and is ARS.USDA address #>
        $EADSam = get-aduser -filter {SamAccountName -notlike "*.*" -and Department -like $RUDEPT -and EmailAddress -like "*ars.usda*"} -Properties * |
                select CN,Department,sAMAccountName,EmailAddress

    } #end BEGIN
    
    PROCESS {
        <# Loops through the individuals contained in the $EADSam variable #>
        foreach ($EAD in $EADSam) {
            <# Creates a variable that is the first.last part of the email address to pass onto the $NewSam and $NewUPN variables #>
            $BaseEmail = ($EAD.EmailAddress).replace("@ars.usda.gov","")
            $NewSam = $BaseEmail
            $NewUPN = "{0}{1}" -f $BaseEmail,$UPNDomain

            <# Sets the values for the Set-ADUser parameters #>
            $SetADUserIdentity = "$($EAD.SamAccountName)"
            $SetADUsersAMAccountName = $NewSam
            $SetADUserUserPrincipalName = $NewUPN

            $SetADUserParams = @{
                            'Identity' = $SetADUserIdentity;
                            'sAMAccountName' = $SetADUsersAMAccountName;
                            'UserPrincipalName' = $SetADUserUserPrincipalName
                            } #end SetADUserParams

            <# Creates a new custom Object to provide an onscreen list and archival log of the Old,New,Email Address and Department #>
            $props = [ordered]@{
                    'Old Login'= "$SetADUserIdentity"
                    'New Login' = "$SetADUsersAMAccountName"
                    'Email Address' = $($EAD.EmailAddress)
                    'Department' = $($EAD.Department)
                    }
            
            $obj = New-Object -TypeName PSObject -Property $props
            
            <# This takes existing sAMAccountName to find the AD Object, and updates the sAMAccountName and  UserPrincipalName #>
     
            switch ($PRODUCTION) {
                    LIVE {Set-ADUser @SetADUserParams;
                    $obj | export-csv "$ExportPath\$Date-EAD-SAMAccountNames-$RU.csv" -NoTypeInformation -Append}
                    REVIEW {Write-output $obj}
                    } #end Switch Production

            #Set-ADUser @SetADUserParams

            <# ENABLE THIS DURING PRODUCTION SCRIPT #>
    
        } #end FOREACH 

    } #end PROCESS

}#end EAD-SetADUserSamUPN
