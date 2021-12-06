#Only change $tempLocation if you wish to install elsewhere
$token = '' #Set this to your access token
$uri = 'http://gitlabURL/projects/416/repository/archive.zip?ref=master&access_token='+$token #set this too your gitlab project
$tempLocation = 'C:\Temp\'

#Downloads Zip
$zipPath = $tempLocation+'\Zabbix-Files\Zabbix Files.zip'
Invoke-RestMethod -uri $uri  -Method 'GET' -ContentType 'application/zip' -OutFile ( New-Item -Path $zipPath -Force)

#Extracts Zip
$unzipPath = $tempLocation+'Zabbix-Files' 
Expand-Archive $zipPath -DestinationPath $unzipPath -Force
Get-ChildItem $unzipPath -Filter *zabbix-agent-installer-master-* | Rename-Item -NewName 'zabbix-agent-installer-master' #Renames the folder that is downloaded to remove random characters

#Runs install script
$installPath = $unzipPath + '\zabbix-agent-installer-master\ZabbixAgentInstall.ps1'
Invoke-Expression -Command $installPath

#Cleans up
Remove-item $zipPath -Recurse
Remove-Item $unzipPath -Recurse
