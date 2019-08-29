$servers = "server-01", "server-02", "server-03"

function sendEmail($server, $message) {

$From = "EMAIL"
$To = "EMAIL"

$Subject = "ALERT: $($server) may be in a hung state"
$Body = $message
$SMTPServer = "smtp-mail.outlook.com"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($From,$To,$Subject,$Body)
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("USERNAME", "PASSWORD")
$SMTPClient.Send($SMTPMessage)

}

Foreach($s in $servers) {
If (Test-Connection -ComputerName $s -Count 4 -Quiet) { $ping=0 }
If ($? -eq $false) { $ping=1 }

# If (New-Object System.Net.Sockets.TCPClient -ArgumentList $s,3389) { $rdp=0}
# If ($? -eq $false) { $rdp=1 }

Try {
    $service_check = Get-Service -ComputerName $s -Name Winmgmt
    If ($service_check.Status -eq "Running") {
        Write-Host $service_check.Status
        $checkpoint = 0
    } Else {
        Write-Host $service_check.Status
        $checkpoint = 1
    }

} Catch {
    Write-Host "Component unknown."
    $checkpoint = 1
}

If ($ping -eq 0 -And $checkpoint -eq 0) { 
    $message = "Server $($s) is pingable and running normally." 
    Write-Host $message }
ElseIf ($ping -eq 0 -And $checkpoint -eq 1) { 
    $message = "Server $($s) is pingable but may be in a hung state." 
    Write-Host $message

    sendEmail $s $message
    Write-Host "Email sent!" 
    }
Else  { 
    $message = "Something went wrong while checking for Server $($s)" 
    Write-Host $message

    SendEmail $s $message
    Write-Host "Email sent!" 
    }
}
