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

        # Log severity. 0 = debug, 1 = note, 2 = warning, 3 = error
        [ValidateRange(0, 3)]
        [Int] $Severity = '1'
    )

    begin {
        $p = Get-ModulePrivateData

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
    }

    process {
        $lineFormat = $Message, $timestamp, (Get-Date -Format MM-dd-yyyy), "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)", $script:currentUser, $Severity
        
        Add-Content -Value ($script:linetemplate -f $lineFormat) -Path $p.FilePath
    }
}