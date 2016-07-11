# [Modified, 7/11/2016 4:33 PM, Grant Harrington]
# Checks version of ws2_32.dll

get-item "C:\Windows\System32\ws2_32.dll" |
select @{n='ComputerName';e={$env:COMPUTERNAME}},FullName,CreationTime,@{n='Version';e={$_.versioninfo.productversion}} | fl

# [Modified, 7/11/2016 5:22 PM, Grant Harrington]
# Modified from reference: https://blogs.technet.microsoft.com/askpfeplat/2014/12/07/how-to-correctly-check-file-versions-with-powershell/
$DLLVersionInfomation = (get-item $env:windir\System32\ws2_32.dll).VersionInfo | select *
$DLLVersionInfomation.FileName
$DLLVersionInfomation.ProductBuildPart
$DLLVersionInfomation.ProductPrivatePart
