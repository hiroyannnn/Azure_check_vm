##############################################
# 定数設定
##############################################
$ErrorActionPreference = "Stop"
$fullpath=$MyInvocation.MyCommand.path								# 編集用
$ScriptID =[System.IO.Path]::GetFileNameWithoutExtension($fullpath)	# スクリプト名をファイル名から取得
$LogPath = Split-Path $MyInvocation.MyCommand.Path  -Parent
$LogFile = $ScriptID + ".log"

##############################################
# 変数設定
############################################## 
##############################################
# 関数設定
##############################################  

function Write-Log ($Message){
    $Output = "{0} {1}" -f (Get-Date), $Message
    Write-Output $Output
    $output | Out-File (Join-Path $LogPath -ChildPath $LogFile) -Append -Encoding utf8
}
##############################################
# メイン処理
##############################################  
try{
    Write-Log "[INFO] Script start"
	# Azureへのログイン
	$azaccount = Login-AzureRmAccount
    $Subscription_array =@(Get-AzureRmSubscription)
    # サブスクリプションごとのループ
    foreach($subscription in $Subscription_array){


        # サブスクリプションを切り替え
        Select-AzureRmSubscription -SubscriptionId $subscription.Id
        # リソースグループの取得
        $RG_array = @((Get-AzureRmResourceGroup).Resourcegroupname)

        # RGのループ
        foreach($RG in $RG_array){
             $VM_array = @(Get-AzureRmVM -ResourceGroupName $RG)
            # VMごとのループ
             foreach($VM in $VM_array){
                 $VMNAME=$VM.name
                 $VMsize= $VM.HardwareProfile.VmSize
                 $St = ($VM | Get-AzureRmVM -Status).Statuses.item(1).code
                 $Result=$subscription.Name + "," + $RG + "," + $VMNAME + "," + $VMsize + "," +$St
                # 結果の出力
                 Write-Log $Result
            }
        }
    }
    Write-Log "[INFO] Script end"
}catch{
    Write-Log $_
    Write-Log "[ERROR] Error end"
}