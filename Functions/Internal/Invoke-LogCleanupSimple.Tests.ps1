$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe 'Invoke-LogCleanupSimple' {
        
        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{
                Mode       = 'Simple'
                Days       = 1 # Days before today (so this is today and the day before)
            } 
        }
    
        Mock Get-ModulePrivateData { $privateData }
        Mock Write-Debug { Write-Host $Message -ForegroundColor Cyan }
        
        $dateFormat = 'yyyy-MM-dd-HHmm'
        
        # Name of this script file, without the .ps1 extension.
        # MyInvocation.MyCommand.Path and MyInvocation.ScriptName do weird
        # things inside Pester.
        $scriptName = 'Invoke-LogCleanupSimple.Tests'
        
        # Init some helper variables
        $dateToday = Get-Date
        $dateYesterday = $dateToday.AddDays(-1)
        $dateTwoDaysAgo = $dateToday.AddDays(-2)
        $dateOneWeekAgo = $dateToday.AddDays(-7)
        
        $logFileName = Get-LogFileName -Force
        $logDirectory = Split-Path -Path $logFileName -Parent
        
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
        $fileTwoDaysAgo     = New-LogFileFromDate $dateTwoDaysAgo
        $fileOneWeekAgo     = New-LogFileFromDate $dateOneWeekAgo
        
        # Un-mock the Get-Date function
        Mock Get-Date -ParameterFilter {$Date -eq $null} { & $getDateCmdlet -Format $Format @PSBoundParameters }
        
        # Run the function
        Invoke-LogCleanupSimple
        
        It 'Ignores files from today' {
            $fileToday | Should Exist
        }
        
        It 'Removes files older than the History.Days setting' {
            $fileYesterday | Should Exist
            $fileTwoDaysAgo | Should Not Exist
            $fileOneWeekAgo | Should Not Exist
        }
    }
}
