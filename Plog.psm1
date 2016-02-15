$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$functions = Join-Path -Path $moduleRoot -ChildPath 'Functions'
$internal = Join-Path -Path $moduleRoot -ChildPath 'Functions\Internal'

# Import all .ps1 files that aren't Pester tests, and export the names of each one as a module function
$items = Resolve-Path "$functions\*.ps1" | Where-Object -FilterScript { -not ($_.ProviderPath.Contains(".Tests.")) }
foreach ($i in $items)
{
    Write-Verbose "Importing file '$($i.ProviderPath)'"
    . $i.ProviderPath

    # This folder has public functions, so export them as module members
    $name = Get-Item $i.ProviderPath | Select-Object -ExpandProperty BaseName
    Export-ModuleMember -Function $name
}

# Same logic here, but don't export these. These functions should be private.
if (Test-Path -Path $internal)
{
    $items = Resolve-Path "$internal\*.ps1" | Where-Object -FilterScript { -not ($_.ProviderPath.Contains(".Tests.")) }
    foreach ($i in $items)
    {
        Write-Verbose "Importing file '$($i.ProviderPath)'"
        . $i.ProviderPath
    }
}

## PowerShell only automatically loads format files from modules within PSModulePath.
## This line forces the current PowerShell session to load the module format file, even if the module is saved in an unusual location.
## If this module lives somewhere in your PSModulePath, this line is unnecessary (but it doesn't do any harm either).
#$formatFile = Join-Path -Path $moduleRoot -ChildPath 'PSJira.format.ps1xml'
#Write-Verbose "Updating format data with file '$formatFile'"
#Update-FormatData -AppendPath $formatFile -ErrorAction Continue