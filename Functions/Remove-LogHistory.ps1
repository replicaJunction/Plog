function Remove-LogHistory {
    [CmdletBinding()]
    param()
    
    begin {
        # Constants
        if (-not $script:regexDate) {
            # Regex to get the date out of a log file name
            $script:regexDate = '^.*_(?<date>\d{8}-\d{4})\.log$'
        }
        
        if (-not $script:fileDateFormat) {
            $script:fileDateFormat = 'yyyyMMdd-HHmm'
        }
        
        $p = Get-ModulePrivateData
        
        # Daily files must be newer than x days old
        $dateDailyCutoff = [DateTime]::Today.AddDays(-$p.History.Days)
        
        # Weekly files must be newer than x weeks old AND must be from the
        # configured day of the week. 
        $dateWeeklyCutoff = [DateTime]::Today.AddDays(-$p.History.Weeks * 7)
        
        # Monthly files must be newer than x months old AND must be from the
        # configured day of the month.
        # This is an average for days of the month. There may be a few fringe
        # cases that this will miss.
        $dateMonthlyCutoff = [DateTime]::Today.AddDays(-$p.History.Months * 30)
        
        $currentLogFile = Get-LogFileName -ScriptName (Split-Path -Path $MyInvocation.ScriptName -Leaf)
        $logDir = Split-Path -Path $currentLogFile -Parent
        $logBaseName = ((Split-Path -Path $currentLogFile -Leaf) -split '_')[0] # Remove the date stamp
        
        if ($p.History.Mode -eq 'StructuredFolder') {
            $dirDaily = Join-Path -Path $logDir -ChildPath 'daily'
            $dirWeekly = Join-Path -Path $logDir -ChildPath 'weekly'
            $dirMonthly = Join-Path -Path $logDir -ChildPath 'monthly'
            
            try {
                $dirDaily, $dirWeekly, $dirMonthly | % {
                    if (-not (Test-Path -Path $_)) {
                        [void] (New-Item -Path $_ -ItemType Directory -Force)
                    }
                }
            }
            catch [System.IOException] {
                $err = $_
                Write-Debug "Plog encountered an exception creating log archives"
                throw $err
            }
        }
    }
    
    process {
        $rootLogFiles = Get-ChildItem -Path $logDir -Filter "$logBaseName*.log"
        foreach ($file in $rootLogFiles) {
            Write-Debug "Remove-LogHistory: processing file $($file.FullName)"
            
            # Get the date out of the filename using a named group in the regex
            # and PowerShell's automatic $Matches variable
            if ($file.Name -match $script:regexDate) {
                # Parse the text date as a DateTime
                $thisDate = [DateTime]::ParseExact($Matches.date, $script:fileDateFormat, [System.Globalization.CultureInfo]::CurrentCulture)
                
                if ($thisDate -ge $dateDailyCutoff) {
                    Write-Debug "Remove-LogHistory: file is less than $($p.History.Days) days old; copying to Daily directory"
                    Copy-Item -Path $file.FullName -Destination $dirDaily                    
                }
                
                if ($thisDate -ge $dateWeeklyCutoff -and [int] $thisDate.DayOfWeek -eq $p.History.DayOfWeek) {
                    Write-Debug "Remove-LogHistory: file is from $($thisDate.DayOfWeek); copying to Weekly directory"
                    Copy-Item -Path $file.FullName -Destination $dirWeekly
                }
                
                if ($thisDate -ge $dateMonthlyCutoff -and [int] $thisDate.Day -eq $p.History.DayOfMonth) {
                    Write-Debug "Remove-LogHistory: file is from day $($thisDate.Day) of the month; copying to Monthly directory"
                    Copy-Item -Path $file.FullName -Destination $dirMonthly
                }
                
                if ($thisDate -ge [DateTime]::Today) {
                    Write-Debug "Remove-LogHistory: file is from today. No action will be taken."
                }
                else {
                    Write-Debug "Remove-LogHistory: removing original file"
                    Remove-Item -Path $file.FullName -Force
                }
            }
            else {
                Write-Debug "Remove-LogHistory: unknown file [$file] will be removed"
                Remove-Item -Path $file.FullName -Force
            }
        }
        
        # Clean daily files
        
        $dailyLogFiles = Get-ChildItem -Path $dirDaily
        foreach ($file in $dailyLogFiles) {
            if ($file.Name -match $script:regexDate) {
                # Parse the text date as a DateTime
                $thisDate = [DateTime]::ParseExact($Matches.date, $script:fileDateFormat, [System.Globalization.CultureInfo]::CurrentCulture)
                
                if ($thisDate -lt $dateDailyCutoff) {
                    Write-Debug "Remove-LogHistory: daily file [$file] is past the cutoff date and will be removed"
                    Remove-Item -Path $file.FullName -Force
                }             
            }
            else {
                Write-Debug "Remove-LogHistory: unknown file [$file] will be removed"
                Remove-Item -Path $file.FullName -Force
            }
        }
        
        # Clean weekly files
        $weeklyLogFiles = Get-ChildItem -Path $dirWeekly
        foreach ($file in $weeklyLogFiles) {
            if ($file.Name -match $script:regexDate) {
                # Parse the text date as a DateTime
                $thisDate = [DateTime]::ParseExact($Matches.date, $script:fileDateFormat, [System.Globalization.CultureInfo]::CurrentCulture)
                
                if ($thisDate -lt $dateWeeklyCutoff) {
                    Write-Debug "Remove-LogHistory: weekly file [$file] is past the cutoff date and will be removed"
                    Remove-Item -Path $file.FullName -Force
                }             
            }
            else {
                Write-Debug "Remove-LogHistory: unknown file [$file] will be removed"
                Remove-Item -Path $file.FullName -Force
            }
        }
        
        # Clean monthly files
        $monthlyLogFiles = Get-ChildItem -Path $dirMonthly
        foreach ($file in $monthlyLogFiles) {
            if ($file.Name -match $script:regexDate) {
                # Parse the text date as a DateTime
                $thisDate = [DateTime]::ParseExact($Matches.date, $script:fileDateFormat, [System.Globalization.CultureInfo]::CurrentCulture)
                
                if ($thisDate -lt $dateMonthlyCutoff) {
                    Write-Debug "Remove-LogHistory: weekly file [$file] is past the cutoff date and will be removed"
                    Remove-Item -Path $file.FullName -Force
                }             
            }
            else {
                Write-Debug "Remove-LogHistory: unknown file [$file] will be removed"
                Remove-Item -Path $file.FullName -Force
            }
        }
    }
}
