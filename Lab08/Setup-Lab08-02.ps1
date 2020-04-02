Write-Host ''
Write-Host '----- 演習8-2 準備スクリプト -----'
Write-Host ''

# 実行時間の測定開始
$starttime = Get-Date

# プログレスバーの非表示
$ProgressPreference = 'SilentlyContinue'

# 受講者番号の入力
Write-Host ''
$number = Read-Host '受講者番号を入力してください '
Write-Host ''
Write-Host 'あなたが入力した受講者番号は' $number 'です' -ForegroundColor Green
Write-Host ''

# リージョンの選択
$hash = Get-AzLocation | Group-Object DisplayName -AsHashTable
$counter = 0
foreach($key in $($hash.keys)){
    $counter++
    $hash[$key] = $counter
}
$hash | Format-Table -Autosize
Write-Host -NoNewline 'Azure リージョン（番号）を選択してください : ' ; $locationnumber=read-host 
$Location = $hash.Keys | ? { $hash[$_] -eq $locationnumber }
Write-Host ''
Write-Host 'あなたが選択したリージョンは' $Location 'です' -ForegroundColor Green
Write-Host ''

# 変数の宣言
$RGname = 'RG' + $number
$VMname = 'Win' + $number + '-3' 
$VMOSimage = 'Win2019Datacenter'
$VMsize = 'Standard_B2ms'
$HAname = 'HA' + $number
$VNetname = 'VNet' + $number + '-1'
$Subnetname = 'Frontend'
$IPname = $vmname + '-ip'
$NSGname = $vmname + '-nsg'
$Adminname = 'admin' + $number
$Adminpassword = 'Pa$$w0rd1234'

# ストレージアカウントの作成
$Uniquenumber = (Get-Date).Ticks.ToString().Substring(12)
$Storagename = 'temp' + $Uniquenumber + $number
Write-Host "ストレージアカウント" $Storagename "を" $Location "に作成しています..." -foregroundcolor yellow
$storage = New-AzStorageAccount -StorageAccountName $Storagename -Location $Location -ResourceGroupName $RGname -Skuname Standard_LRS -Kind Storage

# 仮想マシンの作成
Write-Host '仮想マシン' $VMname 'を' $Location 'に作成しています...' -foregroundcolor yellow
$SecurePassword = $Adminpassword | ConvertTo-SecureString -AsPlainText -Force
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Adminname,$SecurePassword
New-AzVm `
    -Credential $Cred `
    -ResourceGroupName $RGname `
    -Name $VMname `
    -ImageName $VMOSimage `
    -Size $VMsize `
    -AvailabilitySetName $HAname `
    -Location $Location `
    -VirtualNetworkName $VNetname `
    -SubnetName $Subnetname `
    -SecurityGroupName $NSGname `
    -PublicIpAddressName $IPname `
    -OpenPorts 3389,80 `
| Out-Null

# カスタムスクリプトの実行
Write-Host "仮想マシン" $VMname "に IIS をインストールしています..." -foregroundcolor yellow
$Script = 'IIS.ps1'
$Scriptpath = './clouddrive/az103/Lab08/' + $Script
$Storagekey = (Get-AzStorageAccountKey -Name $Storagename -ResourceGroupName $RGname)[0].Value
$ctx = New-AzStorageContext -StorageAccountName $Storagename -StorageAccountKey $Storagekey
New-AzStorageContainer -Name scripts -Permission Off -Context $ctx  | Out-Null
Set-AzStorageBlobContent -File $Scriptpath -Container scripts  -Context $ctx | Out-Null
Set-AzVMCustomScriptExtension `
    -VMName $VMname `
    -Name $VMname `
    -ResourceGroupName $RGname `
    -Location $Location `
    -ContainerName scripts `
    -FileName $Script `
    -Run $Script `
    -StorageAccountName $Storagename `
    -StorageAccountKey $Storagekey `
| Out-Null

# 実行時間の表示
$endtime = Get-Date
Write-Host ''
Write-Host '開始時間 :' $starttime -ForegroundColor Green
Write-Host '終了時間 :' $endtime -ForegroundColor Green
$elapsed = $endtime - $starttime
If ($elapsed.Hours -ne 0)
	{
	Write-Host '実行時間 :' $elapsed.Hours '時間' $elapsed.Minutes '分' -ForegroundColor Green
	}
Else
	{
	Write-Host '実行時間 :' $elapsed.Minutes '分' -ForegroundColor Green
	}
Write-Host ''
