function Get-TokenTotalSupply {
  param (
    [Parameter(Mandatory = $true)]
    [string] $ContractAddress
  )

  # Replace with your provider URL (if using BinanceChain.NET.Client)
  $providerUrl = "https://bsc-dataseed1.binance.org/"

  try {
    # Use BinanceChain.NET.Client (if installed)
    if (Get-Module -ListAvailable BinanceChain.NET.Client) {
      $client = New-Object BinanceChain.NET.Client.BlockchainClient -ArgumentList $providerUrl
      $balance = $client.GetBalance($ContractAddress)
      $totalSupply = $balance.Free
    } else {
      # Fallback to curl (if not using BinanceChain.NET.Client)
      $curlResponse = curl -X POST https://bsc-dataseed1.binance.org/ \
        -H 'Content-Type: application/json' \
        -d '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"'+$ContractAddress+'","data":"0x70a08231"},"latest"],"id":1}'
      $totalSupply = ConvertFrom-Json $curlResponse.result
    }

    $response = @{
      "total_supply" = $totalSupply
    }

    ConvertTo-Json $response
  } catch {
    Write-Error $_.Exception
    $error = @{
      "error" = $_.Exception.Message
    }
    ConvertTo-Json $error -StatusCode 500
  }
}

# Example usage (replace with your actual endpoint URL)
http.sys::Listen("/") { &$Get-TokenTotalSupply -ContractAddress "0x1A05EbD6FA3a9fF19e40988F84dbb300abB2b11D" }