function Set-LogHistoryMode {
    [CmdletBinding()]
    param(
        # Log history mode.
        # Simple - create timestamped log files in the configured path
        # StructuredFolder - create subfolders for log history by day and week
        [Parameter(Mandatory = $false,
                   Position = 0)]
        [ValidateSet('Simple','StructuredFolder')]
        [String] $Mode = 'Simple'
    )
        
    begin {
        $p = Get-ModulePrivateData
    }
    
    process {
        if (-not $p.History) {
            $p.History = @{}
        }
        
        $p.History.Mode = $Mode
    }
    
    end {
        Set-ModulePrivateData -PrivateData $p
    }
}
