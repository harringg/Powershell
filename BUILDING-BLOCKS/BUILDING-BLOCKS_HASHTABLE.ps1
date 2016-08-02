$os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName localhost
$cs = Get-WmiObject -Class Win32_ComputerSystem -ComputerName localhost
$bios = Get-WmiObject -Class Win32_Bios -ComputerName localhost
$proc = Get-WmiObject -Class Win32_Processor -ComputerName localhost |
Select -First 1

$props = [ordered]@{OSVersion=$os.version
            Model=$cs.model
            Manufacturer=$cs.manufacturer
            BIOSSerial=$bios.serialnumber
            ComputerName=$os.CSName
            }
$obj = New-Object -TypeName PSObject -Property $props
Write-Output $obj