$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe 'Invoke-LogCleanupStructuredFolder' {
        
        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{
                Mode       = 'StructuredFolder'
                Days       = 2
                Weeks      = 2
                Months     = 1
                DayOfWeek  = 2 # Monday
                DayOfMonth = 1 # 1st of every month
            } 
        }
    
        Mock Get-ModulePrivateData { $privateData }
        Mock Write-Debug { Write-Host $Message -ForegroundColor Cyan }
        
        $dateFormat = 'yyyyMMdd-HHmm'
        
        # Name of this script file, without the .ps1 extension.
        # MyInvocation.MyCommand.Path and MyInvocation.ScriptName do weird
        # things inside Pester.
        $scriptName = 'Invoke-LogCleanupStructuredFolder.Tests'
        
        # Init some helper variables
        $dateToday = Get-Date
        $dateYesterday = $dateToday.AddDays(-1)
        $dateOneWeekAgo = $dateToday.AddDays(-7)
        $dateFifteenDaysAgo = $dateToday.AddDays(-15)
        $dateFirstOfMonth = New-Object -Type 'System.DateTime' -ArgumentList @(
            $dateToday.Year,
            $dateToday.Month,
            1
        )
        
        $logFileName = Get-LogFileName -Force
        Write-Host "Log file name: $logFileName" -ForegroundColor Yellow
        $logDirectory = Split-Path -Path $logFileName -Parent
        Write-Host "Log file directory: $logDirectory" -ForegroundColor Yellow
        
        # Make a "backup" reference to the real Get-Date so we can do some
        # crazy mocks with it
        $getDateCmdlet = Get-Command -Name Get-Date -CommandType Cmdlet
        
        #####
        
        # Helper function to create a log file from the provided date
        function New-LogFileFromDate([DateTime] $targetDate) {
            Mock Get-Date -ParameterFilter {$Date -eq $null} {
                # Write-Host "    Mocked Get-Date: date=[$($Date)], format=[$($Format)]"
                # Invoke the original Get-Date to format our target date
                & $getDateCmdlet -Date $targetDate -Format $Format
            }
            
            # Get a new log filename
            $filename = Get-LogFileName -Force
            
            # Create a log entry
            Write-Log "Log entry from date $targetDate"
            
            # Write-Host "Created log file from $targetDate at path $filename"
            
            # Modify file attributes
            $file = Get-Item -Path $filename
            $file.CreationTime = $targetDate
            $file.LastWriteTime = $targetDate
            
            # Return a reference to the file
            Write-Output $file
        }
        
        #####
        
        Context 'Sanity checking' {
            $testFile = New-LogFileFromDate $dateOneWeekAgo
                
            It 'New-LogFileFromDate helper function works correctly' {
                $testFile | Should Exist
                $testFile.CreationTime | Should Be $dateOneWeekAgo
                $testFile.LastWriteTime | Should Be $dateOneWeekAgo
            }
        }
        
        # Create some example log files
        $fileToday          = New-LogFileFromDate $dateToday
        $fileYesterday      = New-LogFileFromDate $dateYesterday
        $fileOneWeekAgo     = New-LogFileFromDate $dateOneWeekAgo
        $fileFifteenDaysAgo = New-LogFileFromDate $dateFifteenDaysAgo
        $fileFirstOfMonth   = New-LogFileFromDate $dateFirstOfMonth
        
        # Un-mock the Get-Date function
        Mock Get-Date -ParameterFilter {$Date -eq $null} { & $getDateCmdlet -Format $Format @PSBoundParameters }
        
        # Run the function
        Invoke-LogCleanupStructuredFolder
        
        It 'Creates daily, weekly, and monthly log folders' {
            "$logDirectory\daily" | Should Exist
            "$logDirectory\weekly" | Should Exist
            "$logDirectory\monthly" | Should Exist
        }
        
        It 'Deletes files in the original directory older than today' {
            $fileToday | Should Exist
            $fileYesterday | Should Not Exist
            $fileFifteenDaysAgo | Should Not Exist
            $fileFirstOfMonth | Should Not Exist
        }
        
        It 'Copies files newer than X days into the Daily folder' {
            $fileTodayDaily = $fileYesterdayDaily = Join-Path -Path "$logDirectory\daily" -ChildPath (Split-Path -Path $fileToday.FullName -Leaf)
            $fileTodayDaily | Should Exist
            $fileYesterdayDaily = Join-Path -Path "$logDirectory\daily" -ChildPath (Split-Path -Path $fileYesterday.FullName -Leaf)
            $fileYesterdayDaily | Should Exist
        }
        
        It 'Copies files from the X day of the month into the Monthly folder' {
            $fileFirstOfMonthMonthly = Join-Path -Path "$logDirectory\monthly" -ChildPath (Split-Path -Path $fileFirstOfMonth -Leaf)
            $fileFirstOfMonthMonthly | Should Exist
        }
    }
}
