#Requires -Module Plog
[CmdletBinding()]
param()

Set-LogMode -Path C:\Logs
Start-Log

Write-Log "Test warning" -Severity Warning

Write-Log "Test error" -Severity Error

Write-Log "Complete"
Stop-Log
