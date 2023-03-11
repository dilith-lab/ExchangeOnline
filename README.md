# ExchangeOnline
Scripts related to Exchange Online
## Retention Policy
### Enable Retention Policy on mailbox full users
The following PowerShell script can be used to enable retention policy on mailbox full users in Exchange Online. You can download the script from Github.
[Mailbox_EnableRetention.ps1]([https://github.com/dilith-lab/ActiveDirectory/blob/master/Groups/ViewMembers.ps1](https://github.com/dilith-lab/ExchangeOnline/blob/main/EnableRetentionPolicy/Mailbox_EnableRetention.ps1)) 
```
PowerShell.exe -ExecutionPolicy Bypass -File .\Mailbox_EnableRetention.ps1 -RetentionPolicy "1 Year move to Archive" -UsageReport .\MailboxUsageDetail3_9_2023_10_41_31_AM.csv -MaxUsage 80  -SkipConnection:$false
```
By providing below arguments:

- **-RetentionPolicy** *[Retention policy]* | **required**
- **-UsageReport** *[Mailbox usage report]* | **required**
- **-MaxUsage** *[percentage]* | default value: 90. So if the user skipped it, the script will use the default value when considering mailbox usage
- **-SkipConnection:** *[$true or $false]* | default value: $false. So that user has to authenticate as an privilege user every time script it running. User has the option to pass this value as $true to skip re-authentication.

The script will identify the mailboxes exceeded the max usage and apply retention policy for all required users. In the next version of this script, I’m planning to even more simplify by skipping importing mailbox usage report.
