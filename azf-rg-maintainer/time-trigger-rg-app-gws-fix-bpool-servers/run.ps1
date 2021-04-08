# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"


#######################################################################################################
#### Begin
#######################################################################################################
Set-StrictMode -Version Latest

# How to AZ QUERY: 
# https://docs.microsoft.com/en-us/cli/azure/query-azure-cli
# VERY NICE:
# pip install jmespath-terminal
# az vm list --output json | jpterm
# exit: F5, execute: <automatic>

# Official workaround about changing private ip of ACI allocated to APP GW Backend Pool
# https://github.com/MicrosoftDocs/azure-docs/issues/65128

# Stackoverflow NO SOLUTION: https://stackoverflow.com/questions/63780008/networking-between-container-groups-in-a-virtual-network-without-ip-addresses

# This works only for VMs - dont use it
# https://docs.microsoft.com/en-us/azure/dns/private-dns-autoregistration

# SDK
# https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest
# https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/address-pool?view=azure-cli-latest#az_network_application_gateway_address_pool_update

. .\Remove-AzAppGwBackendPoolUnhealthyServers.ps1

########################################################################################################
#### Read env variables
########################################################################################################
$AZF_NAME=(dir env:WEBSITE_SITE_NAME).Value
# $ARG_NAME="myresourcegroup"

echo ">>> Execute Azure Function App ${AZF_NAME} from Resource group ${ARG_NAME}"

########################################################################################################
#### Loop over APP GWs
########################################################################################################
Get-AzApplicationGateway -ResourceGroupName ${ARG_NAME} | ForEach {

  $APP_GW = $_
  $APP_GW_NAME=$APP_GW.Name

  ######################################################################################################
  #### Get app gw backend pool health status of servers (container group)
  ######################################################################################################
  $BACKEND_POOLS_APP_GW=(Get-AzApplicationGatewayBackendHealth `
      -ResourceGroupName $ARG_NAME  `
      -Name $APP_GW_NAME
  ).BackendAddressPools

  ######################################################################################################
  #### Loop over APP GW Backend Pools
  ######################################################################################################
  $BACKEND_POOLS_APP_GW | ForEach {
    Remove-AzAppGwBackendPoolUnhealthyServers  $_ $APP_GW_NAME
  }
}