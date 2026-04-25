Write-Host "Ensuring OpenSSH server is installed"
if ([bool](Get-Service -Name sshd -ErrorAction SilentlyContinue)) {
    Write-Verbose "OpenSSH is already installed." -Verbose
}
else {
    Write-Verbose "Installing OpenSSH..." -Verbose
    $openSSHpackages = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Select-Object -ExpandProperty Name

    foreach ($package in $openSSHpackages) {
        Add-WindowsCapability -Online -Name $package
    }

    # Start the sshd service
    Write-Verbose "Starting OpenSSH service..." -Verbose
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'

    # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
    Write-Verbose "Confirm the Firewall rule is configured..." -Verbose
    if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Profile Domain,Private -Action Allow -LocalPort 22
    }
    else {
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' already exists."
    }
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
    Write-Host "sshd_config not found at $sshdConfig. This is temperamental, re-running the script usually fixes issue."
}

Write-Host "Ensuring OpenSSH service is running"
$svc = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -ne 'Running') {
    Start-Service -Name sshd
}

Write-Host "Bootstrap script exiting normally." -ForegroundColor Blue
