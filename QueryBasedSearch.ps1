<#
    .DESCRIPTION
        Stop all the VM's based on the query search result using the Run As Account (Service Principle). We are using Log Analytics workspae
        for query based search. 
        
    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Jan 31, 2019
#>

[OutputType("PSAzureOperationResponse")]
param
(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData
)
$ErrorActionPreference = "stop"
#Write-Output ("Webhook data: "+ $WebhookData)

Write-Output "This is log search query-based alert parsing..." -Verbose
if ($WebhookData)
{
    # Get the data object from WebhookData
    $WebhookBody = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)

    # Get the info needed to identify the VM (depends on the payload schema)
    $schemaId = $WebhookBody.schemaId
    Write-Verbose "schemaId: $schemaId" -Verbose
    if ($schemaId -eq "azureMonitorCommonAlertSchema") {
        # This is the common Metric Alert schema (released March 2019)
        $Essentials = [object] ($WebhookBody.data).essentials
        $AlertContext = [object] ($WebhookBody.data).alertContext
        # Get the first target only as this script doesn't handle multiple
         $AffectedConfigurationItems = ($AlertContext.AffectedConfigurationItems)
         $AffectedConfigurationItemsArray = $AffectedConfigurationItems.split("/")
         $ResourceName = $AffectedConfigurationItemsArray[8]
         $ResourceGroupName = $AffectedConfigurationItemsArray[4]
         Write-Output ("Virtual Machine Name :" + $ResourceName)
         Write-Output ("Resource Group Name :" + $ResourceGroupName)
           
        $connectionName = "AzureRunAsConnection"
        try {
            # Get the connection "AzureRunAsConnection "
            $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName     
            
            "Logging in to Azure..."
            Add-AzureRmAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
                 Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $ResourceName -Force
                 Write-Output ($ResourceName + " : Virtual Machine stoppped successfully!")
        }
        catch {
            if (!$servicePrincipalConnection) {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            }
            else {
                Write-Error -Message $_.Exception
                throw $_.Exception
            }
}
  


  
   }   

}
