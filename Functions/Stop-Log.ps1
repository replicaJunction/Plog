function Stop-Log {
    [CmdletBinding()]
    param()
    
    begin {
        if (-not $script:logWriter) {
            throw 'Log file does not appear to be open. You must call Start-Log before using Stop-Log.'
        }
    }
    
    process {
        try {
            [void] $script:logWriter.Close()
            $script:logWriter = $null
        }
        catch {
            $err = $_
            Write-Debug "Stop-Log: An exception was thrown"
            throw "Error closing log file: $err"
        }
    }
}