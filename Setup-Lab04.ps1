Write-Host ''
Write-Host '----- 演習4 準備スクリプト ----'
Write-Host ''

# 実行時間の測定開始
$starttime = Get-Date

#プログレスバーの非表示
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

#変数の宣言
$RGname = 'RG' + $number
$VMname = 'Lin' + $number + '-2'
$VMOSimage = 'UbuntuLTS'
$VMsize = 'Standard_B1s'
$VNetname = 'VNet' + $number + '-2'
$IPname = $vmname + '-ip'
$NSGname = $vmname + '-nsg'
$Subnetname = 'Frontend'
$Adminname = 'admin' + $number
$Adminpassword = 'Pa$$w0rd1234'

# 仮想マシンの作成
Write-Host '仮想マシン' $VMname 'を' $Location 'に作成しています...' -foregroundcolor yellow
$SecurePassword = $Adminpassword | ConvertTo-SecureString -AsPlainText -Force
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Adminname,$SecurePassword
New-AzVm `
    -Credential $Cred `
    -ResourceGroupName $RGName `
    -Name $VMname `
    -ImageName $VMOSimage `
    -Size $VMsize `
    -Location $Location `
    -VirtualNetworkName $VNetname `
    -SubnetName $Subnetname `
    -SecurityGroupName $NSGname `
    -PublicIpAddressName $IPName `
    -OpenPorts 22 `
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
