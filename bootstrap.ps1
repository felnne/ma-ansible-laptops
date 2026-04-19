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

Write-Host "Ensuring OpenSSH is configured to allow password authentication for admin users"
Start-Sleep -Seconds 10  # Pause to allow sshd_config to be created if OpenSSH is newly enabled
$sshdConfig = 'C:\ProgramData\ssh\sshd_config'
if (Test-Path $sshdConfig) {
    $orig = Get-Content $sshdConfig -Raw -ErrorAction Stop
    $modified = $orig

    # Ensure PermitRootLogin yes (uncomment or add)
    if ($modified -notmatch '(?m)^\s*PermitRootLogin\s+yes') {
        if ($modified -match '(?m)^\s*#?\s*PermitRootLogin.*$') {
            $modified = [regex]::Replace($modified, '(?m)^\s*#?\s*PermitRootLogin.*$', 'PermitRootLogin yes')
        } else {
            $modified += "`r`nPermitRootLogin yes"
        }
    }

    if ($modified -ne $orig) {
        $backup = "$sshdConfig.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $sshdConfig $backup -Force
        Set-Content -Path $sshdConfig -Value $modified -Force
        Write-Host "Updated $sshdConfig (backup at $backup)"
        Restart-Service -Name sshd -Force
    } else {
        Write-Host "No changes needed in $sshdConfig"
    }
} else {
    Write-Host "sshd_config not found at $sshdConfig"
}

Write-Host "Ensuring OpenSSH service is running"
$svc = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -ne 'Running') {
    Start-Service -Name sshd
}

Write-Host "Bootstrap script exiting normally." -ForegroundColor Blue
