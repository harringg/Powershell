<#
http://stackoverflow.com/questions/22608315/importing-registry-reg-files-fails
$destinationFolder = "C:\Users\Administrator.FARGO\Documents\REGEDIT"
Get-ChildItem $destinationFolder | ? { $_.Extension -eq '.reg' } | % {
  & reg import $_.FullName
}
#>

$destinationFolder = "C:\Users\Administrator.FARGO\Documents\REGEDIT"
$FullRegFile = Get-ChildItem $destinationFolder | Where { $_.Extension -eq '.reg' }

  ForEach ($RegImportItem in $FullRegFile) {
  & reg import $RegImportItem.FullName
    }
