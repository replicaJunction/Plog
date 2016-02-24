$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe 'Start-Log' {
        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{
                Mode = 'Simple'
            }
        }
        
        Mock Get-ModulePrivateData { $privateData }
        
        $output = Start-Log
        
        It 'Creates a StreamWriter object and saves it in a script variable' {
            $script:logWriter | Should Not Be $null
            (Get-Member -InputObject $script:logWriter).TypeName | Should Be System.IO.StreamWriter
        }
        
        It 'Produces no output' {
            $output | Should Be $null
        }
        
        # Need to safely dispose of the StreamWriter object
        Stop-Log
    }
}