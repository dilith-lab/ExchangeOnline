# Name: Enable retention policy on mailbox full users.
# Description: Enable retention policy to archive mailbox full users based on the Mailbox usage.
# Author: Dilith Achalan
# Date: 09/03/2023
# Version: 1.0.0
# Usage: PowerShell.exe -ExecutionPolicy Bypass -File "C:\Scripts\Mailbox_EnableRetention.ps1" -RetentionPolicy [Retention Policy] -MaxUsage [percentage] -UsageReport [csv file] -SkipConnection:[$true|$false(default)]
# Notes: [Any additional information or notes about the script]

# --- BEGIN SCRIPT ---

param (
    [string]$RetentionPolicy,
    [int]$MaxUsage = 90,
    [string]$UsageReport,
    [bool]$SkipConnection = $false
)

if ([string]::IsNullOrEmpty($RetentionPolicy)) {
    Write-Host "Retention Policy is a required argument"
    return
}
if ([string]::IsNullOrEmpty($UsageReport)) {
    Write-Host "Mailbox usage report is a required argument"
    return
}

Start-Transcript -Path "Retention_Policy_log.txt"

# Connect ExchangeOnline Powershell
if (-not $SkipConnection) {
    Connect-ExchangeOnline
}


$UserEmails = Import-Csv -path $UsageReport
$Mailboxfull_Users = @()
$MailBox_Max_Usage = $MaxUsage

# Check if retention Policy is available
try {
    $RetPolicy = Get-RetentionPolicy -Identity $RetentionPolicy -ErrorAction Stop | Select-Object Name
    Write-Host "`nRetention Policy: $($RetPolicy.Name) `n"

}
catch {
    Write-Host "Retention policy is not found" -ForegroundColor Red
    Stop-Transcript
    break
}

# Check if the Mailbox exceed the MaxUsage Limit
foreach ($user in $UserEmails) {
    $MailBox_capacity_GB = [Int64]$user."Storage Used (Byte)" / 1024 / 1024 / 1024

    # Add MailBox full users to a array
    if ($MailBox_capacity_GB -gt $MailBox_Max_Usage) {
        $MailboxFull_Users += $user."User Principal Name"
    }
}

# Loop through user mailboxed and apply the retention policy for selected users if exists.
foreach ($MailUser in $MailboxFull_Users) {

    try {
        # Check if mailbox exists in exchange online
        $User = Get-EXOMailbox -Identity $MailUser -ErrorAction Stop

        # Apply the retention policy
        Set-Mailbox -Identity $User -RetentionPolicy $RetentionPolicy -ErrorAction Stop
        Write-Host "Retention policy enabled | $($MailUser)" -ForegroundColor Green

    }
    catch {
        Write-Host "Mailbox not found | $MailUser" -ForegroundColor Red
    }

}
Write-Host "`n"
Stop-Transcript

# --- END SCRIPT ---