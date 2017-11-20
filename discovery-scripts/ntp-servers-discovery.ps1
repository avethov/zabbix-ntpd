if (Test-Path "C:\Program Files\NTP\bin")
{
    $ntpq = "C:\Program Files\NTP\bin\ntpq.exe"
}
else
{
    $ntpq = "C:\Program Files (x86)\NTP\bin\ntpq.exe"
}

if ((Get-Command $ntpq -ErrorAction SilentlyContinue) -eq $null) 
{ 
   write-host "Unable to find ntpq"
   exit
}

$lines = & $ntpq "-n" "-p"
$servers = @()
$count = 0

write-host "{"
write-host " `"data`":[`n"
foreach($line in $lines.split("`n"))
{
    $servers += [regex]::Matches($line, '(?:(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)\.){3}(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)') | %{ $_.Groups[0].Value } | select -first 1
}
foreach($server in $servers)
{
    if ($count -lt $servers.Count-1)
    {
        $line= "`t{`n " + "`t`t`"{#NTPSERVER}`":`""+$server+"`""+"`n`t},`n"
        write-host $line
    }
    elseif ($count -ge $servers.Count-1)
    {     
        $line= "`t{`n " + "`t`t`"{#NTPSERVER}`":`""+$server+"`""+"`n`t},`n"
        write-host $line
    }
    $count++;
}
write-host
write-host " ]"
write-host "}"