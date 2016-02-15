$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope "Plog" {
    Describe "Write-Log" {
        $filePath = "TestDrive:\temp.log"

        Context 'FilePath exists' {
            Mock Get-ModulePrivateData {
                @{
                    'FilePath' = $filePath
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
        }

        Context 'FilePath does not exist' {
            It 'Throws an error if the FilePath does not exist' {
                { Write-Log -Message 'Test' } | Should Throw
            }
        }
    }
}