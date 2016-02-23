$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {    
    Describe 'Set-LogMode' {
        Mock Get-ModulePrivateData {
            Write-Output @{}
        }
        
        Mock Set-ModulePrivateData {
            # Output contents so it can be tested
            $PrivateData
        }
        
        $filePath = "TestDrive:\dir\temp.log"
        $logPath = 'TestDrive:\dir'
        
        Context 'LogToFile' {
        
            It 'Creates the log file if it does not exist' {
                { Set-LogMode -Path $logPath } | Should Not Throw
                $logPath | Should Exist
            }
            
            It 'Updates the module PrivateData with all expected properties' {
                $output = Set-LogMode -Path $logPath
                
                $output.Mode | Should BeExactly 'File'
                $output.Path | Should BeExactly $logPath
                
                # History hashtable
                $output.History | Should Not BeNullOrEmpty
            }
        }
        
        Context 'LogToEventLog' {
            Mock Write-EventLog -Verifiable {}
            
            It 'Tries to create an example event log entry if -NoTest is not specified' {
                { Set-LogMode -EventLog } | Should Not Throw
                Assert-MockCalled -CommandName Write-EventLog -Scope It -Times 1 -Exactly
                
                # Should not be called a second time
                { Set-LogMode -EventLog -NoTest } | Should Not Throw
                Assert-MockCalled -CommandName Write-EventLog -Scope It -Times 1 -Exactly
            }
            
            It 'Updates the module PrivateData with all expected properties' {
                $output = Set-LogMode -EventLog -LogName 'LogName1' -Source 'Source1' -NoTest
                $output.LogName | Should Be 'LogName1'
                $output.Source | Should Be 'Source1'
            }
        }
        
        Context 'Write-Host testing' {
            
            It 'Updates the WriteHost parameter in module PrivateData' {    
                $output = Set-LogMode -Path $logPath -WriteHost $false
                $output.WriteHost | Should Be $false
                
                $output = Set-LogMode -Path $logPath -WriteHost $true
                $output.WriteHost | Should Be $true
            }
            
            It 'Defaults to WriteHost = $true' {
                $output = Set-LogMode -Path $logPath
                $output.WriteHost | Should Be $true
            }
        }
    }
}