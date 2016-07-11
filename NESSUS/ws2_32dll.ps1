# [Modified, 7/11/2016 4:33 PM, Grant Harrington]
# Checks version of ws2_32.dll

get-item "C:\Windows\System32\ws2_32.dll" |
select @{n='ComputerName';e={$env:COMPUTERNAME}},FullName,CreationTime,@{n='Version';e={$_.versioninfo.productversion}} | fl
