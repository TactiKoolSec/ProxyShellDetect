
$ProxyShellMon = New-Object System.IO.FileSystemWatcher
$ProxyShellPath = "$env:ExchangeInstallPath\FrontEnd\HttpProxy\owa\auth\"
$ProxyShellFilter = "*.aspx"
$ProxyShellMon.Path = $ProxyShellPath
$ProxyShellMon.Filter = $ProxyShellFilter
$ProxyShellMon.EnableRaisingEvents = $true


$EmailAlert= { 
$details = $event.SourceEventArgs
$EventDetails = $event.SourceEventArgs | out-string
#Send-MailMessage -From 'proxyshellmon@dwyer.net' -To 'jdwyer@dwyer.net' -Subject "ALERT PROXYSHELL DETECTION" -SmtpServer 'EnterSMTPAddressHERE' -Body $EventDetails
Send-MailMessage -From 'EnterFromHere' -To 'EnterToHere' -Subject "ALERT PROXYSHELL DETECTION" -SmtpServer 'EnterSMTPAddressHERE' -Body $EventDetails
}

# Credit to https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/using-filesystemwatcher-correctly-part-2 for the inspirations on how to use 
# handlers correctly
$handlers = . {
    Register-ObjectEvent -InputObject $ProxyShellMon -EventName Changed -Action $EmailAlert -SourceIdentifier AspxFileMod
    Register-ObjectEvent -InputObject $ProxyShellMon -EventName Created -Action $EmailAlert -SourceIdentifier AxpsFileCreate

}

Write-Host "Watching for changes to $ProxyShellPath"

#Credit for ideara for do loop https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/using-filesystemwatcher-correctly-part-2
try
{
    do
    {
        Wait-Event -Timeout 1
        Write-Host "." -NoNewline
        
    } while ($true)
}
finally
{
    #will remove all the watchers and handlers
    Unregister-Event -SourceIdentifier AspxFileMod
    Unregister-Event -SourceIdentifier AxpsFileCreate
    $handlers | Remove-Job
    $ProxyShellMon.EnableRaisingEvents = $false
    $ProxyShellMon.Dispose()
}

