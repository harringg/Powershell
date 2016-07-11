#[Modified, 7/11/2016 4:02 PM, Grant Harrington]
<#

ASLR hardening settings for Internet Explorer in KB3125869
have not been applied. The following DWORD keys must be
created with a value of 1:
  - HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING\iexplore.exe
  - HKLM\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING\iexplore.exe

#>

# Set the HKLM Registry Path
$HKLMPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING',
'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING'

# Check to see if the HKLM Path exists
Foreach ($Path in $HKLMPath) {
Get-Item -Path $path | select Name,@{n='Property';e={($_ | Select -ExpandProperty Property) -join ','}},ValueCount | fl
}

# Create the HKLM Registry Path and then set it's values
Foreach ($Path in $HKLMPath) {
New-Item -Path $Path
$Name = 'iexplore.exe'
$Value = '1' 
$PropertyType = 'DWORD'
New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType
}
