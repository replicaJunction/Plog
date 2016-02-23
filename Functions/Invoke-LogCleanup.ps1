function Invoke-LogCleanup {
    [CmdletBinding()]
    param()
    
    begin {
        $p = Get-ModulePrivateData
    }
    
    process {
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
}