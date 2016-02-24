function Start-Log {
    [CmdletBinding()]
    param()
    
    begin {
        $p = Get-ModulePrivateData
        $logFile = Get-LogFileName -ScriptName (Split-Path -Path $MyInvocation.ScriptName -Leaf)
    }
    
    process {
        # Create path if it does not exist
        $logDir = $p.Path
        if (-not (Test-Path -Path $logDir)) {
            Write-Debug "Start-Log: Creating log directory [$logDir]"
            [void] (New-Item -Path $logDir -ItemType Directory -Force)
        }
        
        if (-not (Test-Path -Path $logFile)) {
            Write-Debug "Start-Log: Creating log file [$logFile]"
            [void] (New-Item -Path $logFile -ItemType File -Force)
        }
        
        # Convert path to filesystem path in case we're in a PSDrive
        $cleanedPath = Convert-Path -Path $logFile
        
        if ($script:logWriter -eq $null) {
            $script:logWriter = New-Object -TypeName System.IO.StreamWriter -ArgumentList $cleanedPath
        }
    }
}