$zabbixInstallPath = 'C:\Program Files\Zabbix Agent\' #Location where you want the agent to be installed. Include trailing \
$zabbixConfFile = $zabbixInstallPath+'zabbix_agentd.conf'
$zabbixAgentVersion = '4.4.10.2400'
$zabbixInstallFiles = $PSScriptRoot+'.\Zabbix Version\'+$zabbixAgentVersion+'\'


$service = Get-Service -Name 'Zabbix Agent' -ErrorAction SilentlyContinue
if ($null -ne $service)  #Checks if Zabbix service already installed, if it is - exit script.
{
    Write-Host 'Zabbix Service Already Installed... Exiting'
    Start-Sleep -Seconds 5
    Exit
}

$installPathExists = Test-Path $zabbixInstallPath
if ($installPathExists -eq 'True' ) {

    Write-Host 'Zabbix Service Not Installed, But Folder Path Exists... Exiting'
    Start-Sleep -Seconds 5
    Exit

}

$firewallRule = Get-NetFireWallRule -DisplayName 'Zabbix Agent listen port' -ErrorAction SilentlyContinue
if ($null -ne $firewallRule)  #Checks if Zabbix firewall exception exists
{
    Write-Host 'Windows Firewall Exception for Zabbix Agent (10050 TCP) Already Set... Continuing...'
}
else #sets firewall exception if it doesn't
{
    Write-Host 'Creating Windows Firewall Exception for Zabbix Agent (10050 TCP)...'
    New-NetFirewallRule -DisplayName "Zabbix Agent listen port" -Profile Any -Action Allow -LocalPort 10050 -Protocol TCP
}

Write-Host 'Zabbix Agent installing...'

New-Item $zabbixInstallPath -ItemType Directory #Creates service foler
Get-ChildItem $zabbixInstallFiles | Copy-Item -Destination $zabbixInstallPath  #Copies service files to service folder

$binaryPathName = '"'+$zabbixInstallPath+'zabbix_agentd.exe'+'"'+' --config '+'"'+$zabbixConfFile+'"' #Installs Service
$serviceInstall = @{
  Name = "Zabbix Agent"
  BinaryPathName = $binaryPathName
  DisplayName = "Zabbix Agent"
  StartupType = "Auto"
  Description = "Provides System Monitoring"
}
New-Service @serviceInstall

### Modifies config file for this server
$hostname = 'Hostname='+$env:computername
$zabbixConfPath = 'Include='+$zabbixConfFile+'.d'
(Get-Content $zabbixConfFile) | ForEach-Object {
    $_.replace('Hostname=SetHostnameHere', $hostname).
    replace('Include=C:\Program Files\Zabbix Agent\zabbix_agentd.conf.d',$zabbixConfPath)
} | Set-Content $zabbixConfFile

New-Item $zabbixInstallPath'\zabbix_agentd.conf.d' -ItemType Directory

Start-Service -Name 'Zabbix Agent' #Starts Zabbix Service
