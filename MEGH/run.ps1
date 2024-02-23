using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

#Connect to Az Account with the Managed Identity
Connect-AzAccount -Identity

#Extract the access token from the AzAccount authentication context and use it to connect to Microsoft Graph
$token = (Get-AzAccessToken -ResourceTypeName MSGraph).token
Connect-MgGraph -AccessToken $token

$group = Get-MgGroup -Filter "displayName eq 'ASU_MPIP_Test001'" | Select-Object -Property DisplayName, Id
$groupmembers = Get-MgGroupMember -GroupId $group.Id | Select-Object -Property DisplayName, Id

$body = $groupmembers | ConvertTo-Json

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
