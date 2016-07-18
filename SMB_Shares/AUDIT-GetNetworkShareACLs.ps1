#[Modified, 7/18/2016 8:50 AM, Grant Harrington]
cls
Write-Host
Write-Host "Audit-GetNetworkShareACLs.ps1"
 
#$path = Read-host “Enter a UNC Path: ”
$Path = "\\10.x.x.x\Public\IT"
$pathparts = $path.split("\")
$ComputerName = $pathparts[2]
$ShareName = $pathparts[3]
$SharePath = "{0}\{1}" -f $ComputerName,$ShareName
 
Write-Host "File Sharing Permissions Report - $path"
Write-Host
get-date
Write-Host 
Write-Host "File/NTFS Permissions"
Write-Host
 
Write-Host "Network Path: $Path"
Get-acl $Path | fl
icacls $Path
((Get-Item $Path).GetAccessControl('Access').Access) #This gets the root directory ACL

Write-Host
Write-Host "Share/SMB Permissions"
Write-Host
Write-Host "   Share Path: $SharePath"
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
            Write-Host "   $Domain\$user  $Perm"
        }
    }
Write-Host