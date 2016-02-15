function Set-ModulePrivateData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [Hashtable] $PrivateData
    )

    process {
        $MyInvocation.MyCommand.Module.PrivateData = $PrivateData
    }
}