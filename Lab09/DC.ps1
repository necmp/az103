# Windows Firewall の無効化
Set-NetFirewallProfile -All -Enabled False

# DC への昇格
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -DomainName "contoso.com" -DomainMode "WinThreshold" -ForestMode "WinThreshold" `
-SafeModeAdministratorPassword (ConvertTo-SecureString "Pa$$w0rd1234" -AsPlainText -Force) -Force:$true
