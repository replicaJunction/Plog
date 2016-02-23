$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe 'Invoke-LogCleanup' {
        
        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{
                Mode       = 'Simple'
                Days       = 1 # Days before today (so this is today and the day before)
            } 
        }
        Mock Get-ModulePrivateData { $privateData }
        
        Mock Invoke-LogCleanupSimple -Verifiable {}
        Mock Invoke-LogCleanupStructuredFolder -Verifiable {}
        
        Context 'Simple history mode' {
            It 'Throws no errors' {
                { Invoke-LogCleanup } | Should Not Throw
            }
            
            It 'Calls Invoke-LogCleanupSimple' {
                Assert-MockCalled -CommandName Invoke-LogCleanupSimple -Scope Context -Exactly -Times 1
            }
            
            It 'Does not call Invoke-LogCleanupStructuredFolder' {
                Assert-MockCalled -CommandName Invoke-LogCleanupStructuredFolder -Scope Context -Exactly -Times 0
            }
        }
        
        Context 'StructuredFolder history mode' {
            $privateData.History.Mode = 'StructuredFolder'
            
            It 'Throws no errors' {
                { Invoke-LogCleanup } | Should Not Throw
            }
            
            It 'Does not call Invoke-LogCleanupSimple' {
                Assert-MockCalled -CommandName Invoke-LogCleanupSimple -Scope Context -Exactly -Times 0
            }
            
            It 'Calls Invoke-LogCleanupStructuredFolder' {
                Assert-MockCalled -CommandName Invoke-LogCleanupStructuredFolder -Scope Context -Exactly -Times 1
            }
        }
    }
}