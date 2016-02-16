# http://www.adamtheautomator.com/building-logs-for-cmtrace-powershell/
function Write-Log {
    [CmdletBinding()]
    param(
        # The message to be logged.
        [Parameter(Mandatory = $true,
                   Position = 0,
                   ValueFromPipeline = $true,
                   ValueFromRemainingArguments = $true)]
        [String] $Message,
        
        [ValidateSet('Information','Warning','Error')]
        [String] $Severity = 'Information'
    )

    begin {
        $p = Get-ModulePrivateData
        
        switch ($Severity) {
            'Information' { $severityInt = 1 }
            'Warning'     { $severityInt = 2 }
            'Error'       { $severityInt = 3 }
        }
        
        $scriptLineNumber = "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)"
    }

    process {
        switch ($p.Mode) {
            'File' {
                if (-not $p.FilePath) {
                    throw "Unable to write log entry. You must call Start-Log first."
                }
                
                if (-not $script:linetemplate) {
                    # Template for a CMTrace log line.
                    $script:linetemplate = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="{4}" type="{5}" thread="" file="">'
                }

                if (-not $script:currentUser) {
                    $script:currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
                }
                
                $timestamp = "$(Get-Date -Format 'HH:mm:ss').$((Get-Date).Millisecond)+000"
                
                $lineFormat = $Message, $timestamp, (Get-Date -Format MM-dd-yyyy), $scriptLineNumber, $script:currentUser, $severityInt
                
                Add-Content -Value ($script:linetemplate -f $lineFormat) -Path $p.FilePath
            }
            'EventLog' {
                $eventID = 1000 + $severityInt
                Write-EventLog -LogName $p.LogName -Source $p.Source -EventID $eventID -EntryType $Severity -Message "$scriptLineNember :: $Message" 
            }
            default {
                throw 'Logging options are undefined. You must call Set-LogMode first.'
            }
        }
        
        if ($p.WriteHost) {
            if (-not $script:hostTemplate) {
                $script:hostTemplate = '[{0}] :: {1}'
            }
            
            $timestamp = "$(Get-Date -Format 'hh:mm:ss')"
            switch ($severityInt) {
                1 {
                    $fg = $host.PrivateData.VerboseForegroundColor
                    $bg = $host.PrivateData.VerboseBackgroundColor
                }
                
                2 {
                    $fg = $host.PrivateData.WarningForegroundColor
                    $bg = $host.PrivateData.WarningBackgroundColor
                }
                
                3 {
                    $fg = $host.PrivateData.ErrorForegroundColor
                    $bg = $host.PrivateData.ErrorBackgroundColor
                }
            }
            $hostFormat = $timestamp, $Message
            Write-Host -Object ($script:hostTemplate -f $hostFormat) -ForegroundColor $fg -BackgroundColor $bg
        }
    }
}