function Get-ModulePrivateData {
    [CmdletBinding()]
    param()

    process {
        $p = $MyInvocation.MyCommand.Module.PrivateData
        if ($p) {
            Write-Output $p
        }
        else {
            # Return an empty hashtable so we don't cause any errors
            Write-Output @{}
        }
    }
}