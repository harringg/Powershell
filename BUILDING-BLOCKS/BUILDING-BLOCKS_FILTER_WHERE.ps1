Get-ChildItem | where {$_.Exists -eq $True}

Get-ChildItem -Filter ($_.Attributes -like "Directory")

help Get-ChildItem -ShowWindow
(Get-Service m*).where{$_.status -eq "Stopped"}
Get-ADComputer -Filter {(DistinguishedName -like "CN*OU=Laptops,OU=DomainComputers,DC=Fargo,DC=local")}
$BitlockerPCs = Get-ADComputer -Filter * | where {($_.DistinguishedName -like "CN*OU=Laptops,OU=DomainComputers,DC=Fargo,DC=local")} | select Name
$BitlockerEnabled = $BitlockerPCs.name


Get-AdComputer -filter {(Name -Like "ARSNDFAR5*")} 

### WORKS AS EXPECTED ###
$computername = 'ARSMNEGF4S1FZQ1'
Get-ADComputer -Filter "Name -like '$computername'"

### THIS FORMAT WORKS WITH FILTER ###
Get-ADGroup -Filter "GroupCategory -eq $GroupCategory -AND GroupScope -ne $GroupScope -AND Member -like '*'"

Get-ADComputer -Filter { Name -like $computername }

Get-ADUser -Filter {SN -like "*arrington"}

Get-ADUser -Filter {DistinguishedName -like "*arrington*"}

Get-ADUser -Filter * -SearchBase "OU=Director,OU=Units,DC=Fargo,DC=local" | ? { ($_.distinguishedname -notlike '*Disabled Users*') }