#This will not create the storage account for use with packer, just the auth
Param (
    $ApplicationName="Packer",
    $AppURL="http://packer.io",
    [Parameter(Mandatory=$true)]$AppPassword,
    $AppRoleAssigned="Owner"
)

$Account = Login-AzureRmAccount
$Subs = Get-AzureRmSubscription
Foreach ($Sub in $Subs) {
    $Sub
    $Answer = Read-Host "Use this subscription? [Y/N]"
    if ($Answer -eq "y") {
        $SubscriptionId = $Sub.SubscriptionId
        Break
    }
}

if (!($SubscriptionId)) {
    Write-Warning "No Subscription was selected"
    Exit 1
}

$App = New-AzureRmADApplication -DisplayName $ApplicationName `
    -HomePage $AppURL -IdentifierUris $AppURL -Password $AppPassword

$SPN = New-AzureRmADServicePrincipal -ApplicationId $App.ApplicationId

Start-Sleep 5

$Role = New-AzureRmRoleAssignment -ServicePrincipalName $AppURL `
    -RoleDefinitionName $AppRoleAssigned

Write-Host "New App auth created, run the following code to export the environment variables (You should copy this into a .ps1 for later use.)`n"

Write-Host "`$ENV:PACKER_ARM_SUBSCRIPTION_ID=`"$($SubscriptionId)`""
Write-Host "`$ENV:PACKER_ARM_CLIENT_ID=`"$($App.ApplicationId.Guid)`""
Write-Host "`$ENV:PACKER_ARM_CLIENT_SECRET=`"$($AppPassword)`""
Write-Host "`$ENV:PACKER_ARM_OBJECT_ID=`"$($Role.ObjectId)`""

$ENV:PACKER_ARM_SUBSCRIPTION_ID=$SubscriptionId
$ENV:PACKER_ARM_CLIENT_ID=$App.ApplicationId.Guid
$ENV:PACKER_ARM_CLIENT_SECRET=$AppPassword
$ENV:PACKER_ARM_OBJECT_ID=$Role.ObjectId

