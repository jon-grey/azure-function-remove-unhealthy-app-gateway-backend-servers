Set-StrictMode -Version Latest

Function Remove-AzAppGwBackendPoolUnhealthyServers
{

  [CmdletBinding()]
  Param
  (
      [Parameter(Mandatory=$true, Position=0)]
      $TMP,

      [Parameter(Mandatory=$true, Position=1)]
      [string]$APP_GW_NAME
  )

  $POOL_NAME = $TMP.BackendAddressPool.Id | split-path -leaf

  echo ">>> Check if App GW $APP_GW_NAME backend pool ${POOL_NAME} has servers."
  $HAS_SERVERS=($TMP.BackendHttpSettingsCollection | Select-Object Servers)

  if (-not $HAS_SERVERS.Servers){
    ######################################################################################################################################
    #### No backend servers - Abort
    ######################################################################################################################################
    echo ">>> App GW $APP_GW_NAME backend pool ${POOL_NAME} do not have servers. Abort."

  } else {
    ######################################################################################################################################
    #### Has some backend servers
    ######################################################################################################################################
    echo ">>> Get App GW $APP_GW_NAME backend pool ${POOL_NAME} list of servers."
    $SERVERS = $TMP.BackendHttpSettingsCollection.Servers | Select-Object Address,Health

    echo ">>> Check if App GW $APP_GW_NAME backend pool ${POOL_NAME} is healthy."
    $SERVERS_UNHEALTHY=($SERVERS | Where-Object {$_.Health -eq "Unhealthy"})
    $SERVERS_HEALTHY=($SERVERS | Where-Object {$_.Health -eq "Healthy"})

    if (-Not $SERVERS_UNHEALTHY ) {
      ######################################################################################################################################
      #### No servers unhealthy - Abort
      ######################################################################################################################################
      echo ">>> All of app GW $APP_GW_NAME backend pool ${POOL_NAME} servers $SERVERS are healthy. Abort."

    } elseif (-Not $SERVERS_HEALTHY ) {
      ######################################################################################################################################
      #### All servers unhealthy - remove from backend pool
      ######################################################################################################################################
      echo ">>> All of app GW $APP_GW_NAME backend pool ${POOL_NAME} servers $SERVERS `
            are unhealthy. Set backend pool $POOL_NAME servers list to empty."

      $APP_GW =(Set-AzApplicationGatewayBackendAddressPool `
      -Name $POOL_NAME `
      -ApplicationGateway $APP_GW)
      
      $APP_GW =(Set-AzApplicationGateway -ApplicationGateway $APP_GW)

    } else {
      ######################################################################################################################################
      #### Some servers unhealthy - remove some from backend pool
      ######################################################################################################################################
      $SERVERS_UNHEALTHY=$SERVERS_UNHEALTHY.Address
      $SERVERS_HEALTHY= $SERVERS_HEALTHY.Address
    
      echo ">>> Unhealthy APP GW $APP_GW_NAME backend pool ${POOL_NAME} servers $SERVERS detected: $SERVERS_UNHEALTHY "
      echo ">>> Set APP GW $APP_GW_NAME backend pool ${POOL_NAME} servers $SERVERS as: $SERVERS_HEALTHY"

      $APP_GW=(Set-AzApplicationGatewayBackendAddressPool `
      -Name $POOL_NAME `
      -ApplicationGateway $APP_GW `
      -BackendIPAddresses $SERVERS_HEALTHY)

      $APP_GW =(Set-AzApplicationGateway -ApplicationGateway $APP_GW)

      $UPDATED_SERVERS=(Get-AzApplicationGatewayBackendAddressPool `
      -Name $POOL_NAME `
      -ApplicationGateway $APP_GW)

      echo ">>> New APP GW $APP_GW_NAME backend pool ${POOL_NAME} servers $SERVERS updated to: ${SERVERS_HEALTHY}"
    }

  }
}
