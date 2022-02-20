$a=get-volume -DriveLetter c

## If space in the volume is lower than 20% he will Create a TXT file. ##
if($a.sizeremaining/$a.size -lt 0.2)
{
$c=($a.sizeremaining/$a.size)*100
$diskinfo= New-Object PSObject
$diskinfo= @()

$env:HostIP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

$diskinfo+= @{IP=$env:HostIP;ComputerName= hostname;DriveLetter= $a.DriveLetter;UsedSize_GB=$a.sizeremaining/1000000000;TotalSize_GB=$a.size/1000000000;SpaceLeft='%'+$c}

Function GetFileName([ref]$fileName)
{
 $invalidChars = [io.path]::GetInvalidFileNamechars() 
 $date = whoami /upn
 $fileName.value = ($date.ToString() -replace "[$invalidChars]","-")+ ".txt"
}
$fileName = $null
GetFileName([ref]$fileName)
$diskinfo| % { new-object PSObject -Property $_} | out-file -filepath X:\$fileName
}
