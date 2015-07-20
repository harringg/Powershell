function Get-ADUC_AllFields {
<#
            .SYNOPSIS 
            Creates a CSV file that contains the selected Active Directory (AD) Fields based on $SELECT<param>
            NOTE: This only returns results if the $_.Department field is filled in with a properly formated RU name
            See Update-ADDepartment.ps1 to batch update the $_.Department field

            .DESCRIPTION
            NAME: Get-ADUC_AllFields
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 4/6/2015 3:51 PM
            LASTEDIT: 7/20/2015 9:24 AM
            KEYWORDS: ADUC

            The $SELECT<param> variables in the BEGIN section of the function are used to create varibles that match
            specific tabs in the ADUC GUI.  SamAccountName is included in all examples, so if you need to take the data
            and update AD records using CSV, you will have a constant variable to ensure you are targeting the proper User.

            Change | Select $SelectAll | to | Select $SelectProfile | to get a report with just Profile Tab information
            for example 

            .PARAMETER Name
            OU = animal OR cereal OR director OR insect OR sunflower OR sugarbeet

            .EXAMPLE
            C:\PS> Get-ADGeneral -OU ANS
            Creates C:\temp\150129-AllADFields-ANS.csv

            .LINK
            https://ems-mysites.usda.gov/Person.aspx?accountname=ARSNET%5CGrant%2EHarrington

            #>
    [CMDLETBINDING(SupportsPaging = $true,
                SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory=$TRUE,ParameterSetName='OU')]
        [string]$OU
        )
    
    BEGIN {
        $Today = Get-Date -Format 'yyMMdd'

        $SELECTGeneral = "SamAccountName","GivenName","Initials","Surname","DisplayName","Description","Office","telephoneNumber","EmailAddress","wWWHomePage"
    
        $SELECTAddress = "SamAccountName","StreetAddress","POBox","City","State","PostalCode","Country"

        $SELECTAccount = "UserPrincipalName","SamAccountName"
   
        $SELECTProfile = "SurName","SamAccountName","ProfilePath","ScriptPath","HomeDrive","HomeDirectory"

        $SELECTTelephones = "SamAccountName","HomePhone","pager","MobilePhone","Fax","ipPhone","info"
   
        $SELECTOrganization = "SamAccountName","Title","Department","Company","Manager"

        $SELECTAll = "SamAccountName","GivenName","Initials","Surname","DisplayName","Description","Office","telephoneNumber","EmailAddress","wWWHomePage",
                     "StreetAddress","POBox","City","State","PostalCode","Country",
                     "UserPrincipalName",
                     "ProfilePath","ScriptPath","HomeDrive","HomeDirectory",
                     "HomePhone","pager","MobilePhone","Fax","ipPhone","info",
                     "Title","Department","Company","Manager","DistinguishedName"
        
        $SELECT_AC02_3 = 
        "PasswordLastSet","LastLogonDate","SamAccountName","GivenName","Initials","Surname","DisplayName","Description","Office","telephoneNumber","EmailAddress","wWWHomePage",
                     "StreetAddress","POBox","City","State","PostalCode","Country",
                     "UserPrincipalName",
                     "ProfilePath","ScriptPath","HomeDrive","HomeDirectory",
                     "HomePhone","pager","MobilePhone","Fax","ipPhone","info",
                     "Title","Department","Company","Manager","DistinguishedName"
                     
        $SELECTTitle = "SamAccountName","Surname","Title"

        $SELECT_EAD = "SamAccountName","GivenName","Initials","Surname","DisplayName", "UserPrincipalName", "DistinguishedName", "HomeDrive", "HomeDirectory","Created","LastLogonDate","LastBadPasswordAttempt"

        $SELECT_AgLearn = "GivenName","Surname", "Description", "Department"

        $SELECT_DisplayName = "GivenName","Surname", "DisplayName", "Department"

        $SELECT_Phone_Email_For_SMTP_VM = "DisplayName", "Office","telephoneNumber","EmailAddress"

        $SELECT_LincPass_Overview = "SamAccountName", "UserPrincipalName","Department","SmartcardLogonRequired","LockedOut"

        Switch ($OU) {
            "ANS" {$RU = "Animal"}
            "CER" {$RU = "Cereal"}
            "IGB" {$RU = "Insect"}
            "OCD" {$RU = "Office"}
            "SUG" {$RU = "Sugarbeet"}
            "SPB" {$RU = "Sunflower"}
            "ALL" {$RU = "Animal","Cereal","Insect","Office","Sugarbeet","Sunflower"}
            } <# END Switch-OU #>

    } <# END BEGIN #>
    
    PROCESS {<# BEGIN PROCESS #>

        foreach ($StrOU in $RU) {<# BEGIN foreach #>

            Switch ($StrOU) {<# BEGIN Switch-StrOU #>
                "Animal" {$CSVRU = "ANS"<#$RUEmail = "PSA @ ars.usda.gov"#>}
                "Cereal" {$CSVRU = "CER"<#$RUEmail = "PSA @ ars.usda.gov"#>}
                "Insect" {$CSVRU = "IGB"<#$RUEmail = "PSA @ ars.usda.gov"#>}
                "Office" {$CSVRU = "OCD"<#$RUEmail = "PSA @ ars.usda.gov"#>}
                "Sugarbeet" {$CSVRU = "SUG"<#$RUEmail = "PSA @ ars.usda.gov"#>}
                "Sunflower" {$CSVRU = "SPB"<#$RUEmail = "PSA @ ars.usda.gov"#>}
                } <# END Switch-StrOU #>

        get-aduser -Filter * -Properties * |
        where { $_.Department -like "*$StrOU*" } |
        Select $SELECT_LincPass_Overview |
        sort Surname |
        export-Csv "c:\temp\$Today-LINCPASS-$($CSVRU<#[0]#>).csv" -NoTypeInformation

        <#
        
        $Sender = 'ITSPEC @ ars.usda.gov'
        $Recipients = 'ITSPEC @ ars.usda.gov',$($CSVRU[1])
        $MessageSubject = 'AD Quarterly Reports'
        $Relay = 'ENTER_RELAY_HERE'

        $email = @{
                From = $Sender
                To =$Recipients
                Subject = $MessageSubject
                SMTPServer = $Relay
                Attachments = "c:\temp\$Today-SELECT_AC02_3-TEST-$StrOU.csv"
                } #end emailparams

        #send-mailmessage @email
        #>

        } <# END foreach #>

    } <# END PROCESS #>

    END {
    
    } <# END END #>

} #end Get-ADUC_AllFields
