# What is Plog?

Plog is a simple PowerShell module designed to make logging easy, once and for all.

## Seriously, another logging framework?

Yes!

Plog started out as a personal project born out of my own needs. I needed a better way to log some of the long-running tasks I'd been working on, and Start-Transcript wasn't cutting it any more.  I was tired of researching every time I needed to remember the syntax for writing to the Event Log, or re-creating a logging function every time I needed the ability to log in another task. 

I wasn't able to find a single, all-in-one module that met my needs exactly, so I decided to write one.

## Plog goals

* **Simplicity.** Plog provides a simple, drop-in logging framework for PowerShell scripting without extra hassle. 
* **Flexibility.** Plog can write to a configurable log file or a Windows event log.
* **Readability**. Plog produces log files designed for CMTrace, taking full advantage of the same logging methods used by System Center Configuration Manager. Log files include timestamps and script line number.
* **Performance**. Plog uses persistent script variables to increase performance wherever possible.

# How do I use Plog?

1. Install Plog to your PSModulePath. I will add Plog to the PowerShell Gallery if there is sufficient demand for it.
2. In a script where you'd like to use Plog, use Set-LogMode to define how you'd like Plog to log output:
3. Anywhere you'd like to log output, simply use Write-Log instead of Write-Verbose or similar.

# Examples

```powershell
# Log to a file and display output in the console
Set-LogMode -FilePath C:\Logs\mylog.log

# Log to the Windows PowerShell event log without displaying console output
Set-LogMode -EventLog -WriteHost $false

# Write a log entry. This is the simplest way to use Plog.
Write-Log "MyVar value is $myVar"

# Write an error log entry (red in CMTrace, or an Error event in the event viewer)
Write-Log "Something broke!" -Severity Error
```

# Credits

Plog would not be possible without some of the great posts from #PSBlogWeek 2016. I'd especially like to thank Adam Bertram for information on CMTrace's logging template, as well as the method for logging the script line number. 