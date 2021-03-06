Write-Host ''
Write-Host '----- 演習2 準備スクリプト -----'
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
$Vnetname = 'VNet' + $number + '-1'
$Subnetname1 = 'Frontend'
$Subnetname2 = 'Backend'

#仮想ネットワークの作成
Write-Host '仮想ネットワーク' $Vnetname 'を' $Location 'に作成しています...' -foregroundcolor yellow
$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName $RGname -Location $Location -Name $Vnetname -AddressPrefix 10.0.0.0/16
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $Subnetname1 -AddressPrefix 10.0.0.0/24 -VirtualNetwork $virtualNetwork -WarningAction SilentlyContinue
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $Subnetname2 -AddressPrefix 10.0.1.0/24 -VirtualNetwork $virtualNetwork -WarningAction SilentlyContinue
$virtualNetwork | Set-AzVirtualNetwork | Out-Null

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
