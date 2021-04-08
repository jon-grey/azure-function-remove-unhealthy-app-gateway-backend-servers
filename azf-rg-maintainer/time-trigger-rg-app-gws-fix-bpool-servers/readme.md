# TimerTrigger - PowerShell

The `TimerTrigger` makes it incredibly easy to have your functions executed on a schedule. This sample demonstrates a simple use case of calling your function every 5 minutes.

## How it works

For a `TimerTrigger` to work, you provide a schedule in the form of a [cron expression](https://en.wikipedia.org/wiki/Cron#CRON_expression)(See the link for full details). A cron expression is a string with 6 separate expressions which represent a given schedule via patterns. The pattern we use to represent every 5 minutes is `0 */5 * * * *`. This, in plain text, means: "When seconds is equal to 0, minutes is divisible by 5, for any hour, day of the month, month, day of the week, or year".

## Learn more

<TODO> Documentation

## Local dev

To execute function in VCode: F5.

### On ubuntu

Install dotnet 3.1

```sh
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-3.1

sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-3.1

sudo apt-get install -y dotnet-runtime-3.1
```

## Usefull commands

## Check state of container instance behind public ip of app gw

```sh
$ARG_NAME = "myResourceGroup"

Get-AzApplicationGateway -ResourceGroupName ${ARG_NAME} | ForEach {
    $PUBLIC_IP_NAME_APP_GW = ($APP_GW.FrontendIpConfigurations.PublicIPAddress.Id | split-path -leaf)

    $PUB_IP=(Get-AzPublicIpAddress `
    -Name ${PUBLIC_IP_NAME_APP_GW} `
    -ResourceGroupName ${ARG_NAME}).IpAddress

    $PUB_IP_STATUS_CODE=(curl -s -o /dev/null -w "%{http_code}" $PUB_IP)

    echo ">>> Connected to APP GW $APP_GW_NAME public IP $PUB_IP with status code $PUB_IP_STATUS_CODE"
}
```

