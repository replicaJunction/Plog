$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {    
    Describe 'Set-LogMode' {
        
        Mock Get-ModulePrivateData {
            Write-Output @{}
        }
        
        Context 'LogToFile' {
            $filePath = "TestDrive:\dir\temp.log"
            
            Mock Set-ModulePrivateData {
                # Export what would be set to the PrivateData FilePath variable
                $PrivateData.FilePath
            }
        
            It 'Creates the log file if it does not exist' {
                { Set-LogMode -FilePath $filePath } | Should Not Throw
                $filePath | Should Exist
            }
            
            It 'Updates the module PrivateData with file path and settings' {
                $output = Set-LogMode -FilePath $filePath
                $output | Should BeExactly $filePath
            }
        }
        
        Context 'LogToEventLog' {
            Mock Write-EventLog -Verifiable {}
            
            Mock Set-ModulePrivateData {
                @{
                    Source = $PrivateData.Source
                    LogName = $PrivateData.LogName
                }
            }
            
            It 'Tries to create an example event log entry if -NoTest is not specified' {
                { Set-LogMode -EventLog } | Should Not Throw
                Assert-MockCalled -CommandName Write-EventLog -Scope It -Times 1 -Exactly
                
                # Should not be called a second time
                { Set-LogMode -EventLog -NoTest } | Should Not Throw
                Assert-MockCalled -CommandName Write-EventLog -Scope It -Times 1 -Exactly
            }
            
            It 'Updates the module PrivateData with event source and log name' {
                $output = Set-LogMode -EventLog -LogName 'LogName1' -Source 'Source1' -NoTest
                $output.LogName | Should Be 'LogName1'
                $output.Source | Should Be 'Source1'
            }
        }
    }
}