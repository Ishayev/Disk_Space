$a=get-volume -DriveLetter c

if(1-$a.sizeremaining/$a.Size -gt 0.6)
{
$c=(1-$a.sizeremaining/$a.Size)*100
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
$diskinfo| % { new-object PSObject -Property $_} | out-file -filepath c:\test\$fileName
}
