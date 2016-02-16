$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope "Plog" {
    Describe "Write-Log" {
        $filePath = "TestDrive:\temp.log"

        Context 'Logging to file' {
            Mock Get-ModulePrivateData {
                @{
                    Mode     = 'File'
                    FilePath = $filePath
                }
            }

            It 'Uses Get-ModulePrivateData to obtain a reference to the file path' {
                { Write-Log -Message 'Test' } | Should Not Throw
                Assert-MockCalled -CommandName Get-ModulePrivateData -Scope It -Times 1 -Exactly
            }

            It 'Creates a file if it does not exist' {
                Remove-Item -Path $filePath # Need to remove because it was created in the test above
                { Write-Log -Message 'Test' } | Should Not Throw
                $filePath | Should Exist
            }
            
            It 'Produces no output' {
                Write-Log -Message 'Test' | Should BeNullOrEmpty
            }
        }

        Context 'Logging to event log' {
            Mock Get-ModulePrivateData {
                @{
                    Mode    = 'EventLog'
                    LogName = 'Windows PowerShell'
                    Source  = 'PowerShell' 
                }
            }
            
            Mock Write-EventLog { 
                @{
                    LogName   = $LogName
                    Source    = $Source
                    EventID   = $EventID
                    EntryType = $EntryType
                    Message   = $Message
                }
             }
            
            It 'Uses Write-EventLog to write the log message to the event log' {
                $output = Write-Log -Message 'Test'
                
                $output.LogName | Should Be 'Windows PowerShell'
                $output.Source | Should Be 'PowerShell'
                $output.EventID | Should Be 1001
                $output.EntryType | Should Be 'Information'  
            }
            
            It 'Logs different entry types for different Severity values' {
                (Write-Log -Message 'Test information').EntryType | Should Be 'Information'
                (Write-Log -Message 'Test warning' -Severity Warning).EntryType | Should Be 'Warning'
                (Write-Log -Message 'Test error' -Severity Error).EntryType | Should Be 'Error'
            }
        }
        
        Context 'Write-Host testing' {
            Mock Get-ModulePrivateData {
                @{
                    Mode      = 'File'
                    FilePath  = $filePath
                    WriteHost = $true
                }
            }
            
            Mock Write-Host {
                @{
                    Message         = $Object
                    ForegroundColor = $ForegroundColor
                    BackgroundColor = $BackgroundColor
                }
            }
            
            It 'Produces output to Write-Host if the WriteHost value is set' {
                $output = Write-Log -Message 'Test'
                Assert-MockCalled -CommandName Write-Host -Scope It -Times 1 -Exactly
                $output.ForegroundColor | Should Be $host.PrivateData.VerboseForegroundColor
                $output.BackgroundColor | Should Be $host.PrivateData.VerboseBackgroundColor
            }
        }
        
        Context 'Undefined logging mode' {
            It 'Throws an error if logging options have not been initialized' {
                { Write-Log -Message 'Test' } | Should Throw 'Logging options are undefined. You must call Set-LogMode first.'
            }
        }
    }
}