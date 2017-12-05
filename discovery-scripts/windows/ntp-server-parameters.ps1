$ntpserver = $args[0]

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

$parametr_names = [regex]::Matches($lines.split("`n")[0], '[^\s]+')

foreach($line in $lines.split("`n"))
{
    $server = [regex]::Matches($line, '(?:(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)\.){3}(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)') | %{ $_.Groups[0].Value } | select -first 1
	if ($server -eq $ntpserver)
	{
		write-host "{"
		write-host "`t`"data`":"
		write-host "`t["
		write-host "`t`t{"
		
	    $parametr_values = [regex]::Matches($line, '[^\s]+')
		for($i = 1; $i -lt $parametr_names.Groups.Count; ++$i)
		{
			if ($i -ge $parametr_names.Groups.Count-1)
			{
				$line= "`t`t`t`"{#" + $parametr_names.Groups[$i] + "}`":`"" + $parametr_values.Groups[$i] + "`""
				write-host $line
			}
			elseif ($i -lt $parametr_names.Groups.Count-1)
			{
				$line= "`t`t`t`"{#" + $parametr_names.Groups[$i] + "}`":`"" + $parametr_values.Groups[$i] + "`","
				write-host $line
			}
		}
		
		write-host "`t`t}"
		write-host "`t]"
		write-host "}"
	}
}
