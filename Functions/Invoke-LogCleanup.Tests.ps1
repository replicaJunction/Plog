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
            
            $output = Invoke-LogCleanup
            
            It 'Produces no output' {
                $output | Should Be $null
            }
            
            It 'Calls Invoke-LogCleanupSimple' {
                Assert-MockCalled -CommandName Invoke-LogCleanupSimple -Scope Context -Exactly -Times 1
            }
            
            It 'Does not call Invoke-LogCleanupStructuredFolder' {
                Assert-MockCalled -CommandName Invoke-LogCleanupStructuredFolder -Scope Context -Exactly -Times 0
            }
            
            It 'Throws no errors' {
                { Invoke-LogCleanup } | Should Not Throw
            }
        }
        
        Context 'StructuredFolder history mode' {
            $privateData.History.Mode = 'StructuredFolder'
            
            $output = Invoke-LogCleanup
            
            It 'Produces no output' {
                $output | Should Be $null
            }
            
            It 'Does not call Invoke-LogCleanupSimple' {
                Assert-MockCalled -CommandName Invoke-LogCleanupSimple -Scope Context -Exactly -Times 0
            }
            
            It 'Calls Invoke-LogCleanupStructuredFolder' {
                Assert-MockCalled -CommandName Invoke-LogCleanupStructuredFolder -Scope Context -Exactly -Times 1
            }
            
            It 'Throws no errors' {
                { Invoke-LogCleanup } | Should Not Throw
            }
        }
        
        Context 'Error checking' {
            $privateData.History.Mode = 'NotSupported'
            
            It 'Throws an exception if an undefined or null history mode is set' {
                { Invoke-LogCleanup } | Should Throw 'Unsupported log history mode [NotSupported]'
            }
        }
        
        Context 'Event Log logging mode' {
            Mock Write-Warning {}
            $privateData.Mode = 'EventLog'
            
            $output = Invoke-LogCleanup
            
            It 'Produces no output' {
                $output | Should Be $null
            }
            
            It 'Takes no action' {
                Assert-MockCalled -CommandName Invoke-LogCleanupSimple -Scope Context -Exactly -Times 0
                Assert-MockCalled -CommandName Invoke-LogCleanupStructuredFolder -Scope Context -Exactly -Times 0
            }
            
            It 'Produces a warning message' {
                Assert-MockCalled -CommandName Write-Warning -Scope Context -Exactly -Times 1
            }
        }
    }
}