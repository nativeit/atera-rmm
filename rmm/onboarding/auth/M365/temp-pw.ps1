#                                                             𝝢 𝝠 𝝩 𝝞 𝗩 𝝣 ⧟ 𝝞 𝝩                                                             
# ⎧ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ⎫
# |                                                                                                                                                 |
# |  This script replaces the details of the Atera agent such that its app name in Apps & Features, services, and menus reflects                    |
# |  your own brand rather than that of Atera's. The stock icon is replaced with one of your own (hosted from a public URL).                        |
# |                                                                                                                                                 |
# |  This script was revised, tested, and approved on 2021-12-15.                                                                                   |
# |                                                                                                                                                 |
# |     NOTES:                                                                                                                                      |
# |       - This script was taken and adapted from https://www.cyberdrain.com/automating-with-powershell-deploying-temporary-access-passwords/      |                                                                                                                            |
# |                                                                                                                                                 |
# ⎩ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ⎭
#       ⧉ desk.nativeit.net                                                                        𝑖 𝑚 𝑎 𝑔 𝑖 𝑛 𝑎 𝑡 𝑖 𝑜 𝑛  ✚  𝑡 𝑒 𝑐 ℎ 𝑛 𝑜 𝑙 𝑜 𝑔 𝑦

######### TAP Settings #########
$MinimumLifetime = "60" #Minutes
$MaximumLifetime = "480" #minutes
$DefaultLifeTime = "60" #minutes
$OneTimeUse = $false
$DefaultLength = "8"
######### Secrets #########
$ApplicationId = 'AppID'
$ApplicationSecret = 'AppSecret'
$TenantID = 'TenantIDForWhichtoEnableTap'
######### Secrets #########
  
 
$TAPSettings = @"
  {"@odata.type":"#microsoft.graph.temporaryAccessPassAuthenticationMethodConfiguration",
  "id":"TemporaryAccessPass",
  "includeTargets":[{"id":"all_users",
  "isRegistrationRequired":false,
  "targetType":"group","displayName":"All users"}],
  "defaultLength":$DefaultLength,
  "defaultLifetimeInMinutes":$DefaultLifeTime,
  "isUsableOnce":false,
  "maximumLifetimeInMinutes":$MaximumLifetime,
  "minimumLifetimeInMinutes":$MinimumLifetime,
  "state":"enabled"}
"@
 
$body = @{
    'resource'      = 'https://graph.microsoft.com'
    'client_id'     = $ApplicationId
    'client_secret' = $ApplicationSecret
    'grant_type'    = "client_credentials"
    'scope'         = "openid"
}
   
foreach ($tenant in $tenants) {
  
    write-host "Working on client $($tenant.defaultdomainname)"
    try {
        $ClientToken = Invoke-RestMethod -Method post -Uri "https://login.microsoftonline.com/$($tenantid)/oauth2/token" -Body $body -ErrorAction Stop
        $headers = @{ "Authorization" = "Bearer $($ClientToken.access_token)" }
        Invoke-RestMethod -ContentType "application/json" -UseBasicParsing -Method Patch -Headers $Headers -body $TAPSettings -uri "https://graph.microsoft.com/beta/policies/authenticationmethodspolicy/authenticationMethodConfigurations/TemporaryAccessPass"
    }
    catch {
        Write-Warning "Could not log into tenant $($tenant.DefaultDomainName) or retrieve policy. Error: $($_.Exception.Message)"
    }
   
}
