# [Modified, 7/18/2016 8:50 AM, Grant Harrington]
# [Modified, 7/18/2016 2:08 PM, Grant Harrington]
cls

$DateRun = get-date
$Date = Get-date -f yyMMdd_HHmm

$ScriptName = 'Audit-GetNetworkShareACLs.ps1'
$ScriptPath = 'https://github.com/harringg/Powershell/blob/master/SMB_Shares/AUDIT-GetNetworkShareACLs.ps1'
Write-verbose "Script Name: $ScriptName" -Verbose
#$path = Read-host “Enter a UNC Path: ”
$PathBase = '10.170.180.2'
$PathShare = 'COMMON'
$PathShareNested = 'OCD'

$OutputFilePath= "C:\SCRIPTS"
$OutFileFile = "{0}\Logs\{1}_{2}_Share_ACL_Log.txt" -f $OutputFilePath,$Date,$PathShare

$ScriptName | Out-File $OutFileFile -Append
$ScriptPath | Out-File $OutFileFile -Append

if ($PathShareNested) {
$path = "\\{0}\{1}\{2}" -f $PathBase,$PathShare,$PathShareNested
} else{
$path = "\\{0}\{1}" -f $PathBase,$PathShare
}

$startLog = "Started Processing $Path $DateRun"
$startLog | Out-File $OutFileFile -Append

#$Path = "\\10.170.180.2\COMMON"
$pathparts = $path.split("\")
$ComputerName = $pathparts[2]
$ShareName = $pathparts[3]
$SharePath = "{0}\{1}" -f $ComputerName,$ShareName
 
Write-verbose "File Sharing Permissions Report - $path" -Verbose
"File Sharing Permissions Report - $path" | Out-File $OutFileFile -Append
Write-verbose "File/NTFS Permissions" -Verbose
"File/NTFS Permissions" | Out-File $OutFileFile -Append
Write-Host "Network Path: $Path"
"Network Path: $Path" | Out-File $OutFileFile -Append
$GetACL = Get-acl $Path | fl
Write-Output $GetACL
$icacls = icacls $Path
Write-Output $icacls
$GetItemACL = ((Get-Item $Path).GetAccessControl('Access').Access) #This gets the root directory ACL
Write-Output $GetItemACL
Write-Verbose "Share/SMB Permissions" -Verbose
Write-Verbose "   Share Path: $SharePath" -Verbose

'Get-ACL $Path' | Out-File $OutFileFile -Append
$GetACL | Out-File $OutFileFile -Append
'icacls $Path' | Out-File $OutFileFile -Append
$icacls | Out-File $OutFileFile -Append
'((Get-Item $Path).GetAccessControl(''Access'').Access)' | Out-File $OutFileFile -Append
$GetItemACL | Out-File $OutFileFile -Append

    $Share = Get-WmiObject win32_LogicalShareSecuritySetting -Filter "name='$ShareName'" -ComputerName $ComputerName
    if($Share){
        $obj = @()
        $ACLS = $Share.GetSecurityDescriptor().Descriptor.DACL
        foreach($ACL in $ACLS){
            $User = $ACL.Trustee.Name
            if(!($user)){$user = $ACL.Trustee.SID}
            $Domain = $ACL.Trustee.Domain
            switch($ACL.AccessMask)
            {
                2032127 {$Perm = "Full Control"}
                1245631 {$Perm = "Change"}
                1179817 {$Perm = "Read"}
            }
     #       Write-Host "   $Domain\$user  $Perm"
            Write-verbose "   $Domain\$user  $Perm" -Verbose
            "   $Domain\$user  $Perm" | Out-File $OutFileFile -Append
        }
    }

$enddate = get-date
$endLog = "Completed Processing $Path $enddate"
$endLog | Out-File $OutFileFile -Append