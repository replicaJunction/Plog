function Invoke-LogCleanup {
    [CmdletBinding()]
    param()
    
    begin {
        $p = Get-ModulePrivateData
    }
    
    process {
        if ($p.Mode -eq 'File') {
            switch ($p.History.Mode) {
                'Simple' {
                    Invoke-LogCleanupSimple
                }
                'StructuredFolder' {
                    Invoke-LogCleanupStructuredFolder
                }
                default {
                    throw "Unsupported log history mode [$($p.History.Mode)]"
                }
            }
        }
        else {
            Write-Warning "Plog: log mode is set to [$($p.Mode)]. Log cleanup is not supported in this mode."
        }
    }
}