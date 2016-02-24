$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe 'Stop-Log' {
        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{
                Mode = 'Simple'
            }
        }
        
        Mock Get-ModulePrivateData { $privateData }
        
        # Initialize the LogWriter
        Start-Log
        
        $output = Stop-Log
        
        It 'Closes and disposes of the StreamWriter object' {
            $script:logWriter | Should Be $null
        }
        
        It 'Clears any file locks on the log file' {
            { Remove-Item -Path (Get-LogFileName) -Force } | Should Not Throw
        }
        
        It 'Produces no output' {
            $output | Should Be $null
        }
    }
}