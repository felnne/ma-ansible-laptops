Write-Host "Ensuring OpenSSH server capability is installed"
$cap = Get-WindowsCapability -Online -Name OpenSSH.Server* -ErrorAction SilentlyContinue
if ($cap -and $cap.State -ne 'Installed') {
    Add-WindowsCapability -Online -Name $cap.Name
}

Write-Host "Ensuring OpenSSH service exists and is set to automatic"
if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
    Set-Service -Name sshd -StartupType Automatic
}

Write-Host "Ensuring OpenSSH firewall rule exists and is enabled."
$rule = Get-NetFirewallRule -Name 'sshd' -ErrorAction SilentlyContinue
if (-not $rule) {
    New-NetFirewallRule -Name 'sshd' -DisplayName 'OpenSSH Server (sshd)' -Action Allow -Direction Inbound -Enabled True -Profile Domain,Private -Protocol TCP -LocalPort 22
} else {
    Set-NetFirewallRule -Name 'sshd' -Profile Domain,Private -Enabled True -Action Allow -Direction Inbound
}

Write-Host "Ensuring OpenSSH default shell is expected PowerShell version"
$desiredShell = 'C:\Program Files\PowerShell\7\pwsh.exe'
$currentShell = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -ErrorAction SilentlyContinue).DefaultShell
$shellChanged = $false
if ($currentShell -ne $desiredShell) {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $desiredShell -PropertyType String -Force | Out-Null
    $shellChanged = $true
}
if ($shellChanged) {
    Restart-Service -Name sshd -Force
} else {
    if ($svc -and $svc.Status -ne 'Running') { Start-Service -Name sshd }
}

Write-Host "Ensuring OpenSSH service is running"
$svc = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -ne 'Running') {
    Start-Service -Name sshd
}

Write-Host "Bootstrap script exiting normally." -ForegroundColor Blue
