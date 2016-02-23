function Set-LogHistoryMode {
    [CmdletBinding()]
    param(
        # Log history mode.
        # Simple - create timestamped log files in the configured path
        # StructuredFolder - create subfolders for log history by day and week
        [Parameter(Mandatory = $false,
                   Position = 0)]
        [ValidateSet('Simple','StructuredFolder')]
        [String] $Mode = 'Simple',
        
        # Number of days before today that log files should be preserved
        [Parameter(Mandatory = $false)]
        [int] $Days = 7,
        
        # Number of weeks before today that a log file should be kept. Only
        # one log file will be kept for each week.
        # This setting has no effect in Simple log mode.
        [Parameter(Mandatory = $false)]
        [int] $Weeks = 4,
        
        # Day of the week when a log file should be kept. 1 = Sunday, 2 =
        # Monday, etc.
        # This setting has no effect in Simple log mode. 
        [Parameter(Mandatory = $false)]
        [int] $DayOfWeek = 2,
        
        # Number of months before today that a log file should be kept. Only
        # one log file will be kept for each month.
        # This setting has no effect in Simple log mode.
        [Parameter(Mandatory = $false)]
        [int] $Months = 3,
        
        # Day of the month when a log file should be kept. Note that this
        # should not be set higher than 28 for compatibility with February.
        # This setting has no effect in Simple log mode.
        [Parameter(Mandatory = $false)]
        [ValidateRange(1,28)]
        [int] $DayOfMonth = 1
    )
        
    begin {
        $p = Get-ModulePrivateData
    }
    
    process {
        if (-not $p.History) {
            $p.History = @{}
        }
        
        $p.History = @{
            Mode       = $Mode
            Days       = $Days
            Weeks      = $Weeks
            DayOfWeek  = $DayOfWeek
            Months     = $Months
            DayOfMonth = $DayOfMonth
        }
    }
    
    end {
        Set-ModulePrivateData -PrivateData $p
    }
}
