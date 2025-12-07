param (
    [Parameter(Mandatory=$true)]
    [string]$InputArg,

    [Parameter(Mandatory=$true)]
    [string]$OutwardKey
)

# Get the directory where the script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "jira_config.properties"

if (-not (Test-Path $ConfigFile)) {
    Write-Error "Error: Config file '$ConfigFile' not found."
    Write-Host "Please create it with the following content:"
    Write-Host "DOMAIN=your-domain.atlassian.net"
    Write-Host "EMAIL=user@email.com"
    Write-Host "TOKEN=api_token"
    exit 1
}

# Parse config file manually to avoid external dependencies
$config = @{}
Get-Content -Path $ConfigFile | ForEach-Object {
    if ($_ -match "^\s*([^=]+?)\s*=\s*(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $config[$key] = $value
    }
}

$Domain = $config["DOMAIN"]
$Email = $config["EMAIL"]
$Token = $config["TOKEN"]

# Validate config
if ([string]::IsNullOrWhiteSpace($Domain) -or [string]::IsNullOrWhiteSpace($Email) -or [string]::IsNullOrWhiteSpace($Token)) {
    Write-Error "Error: Config file must contain DOMAIN, EMAIL, and TOKEN."
    exit 1
}

# Base64 encode the credentials for Basic Auth
$authPair = "$($Email):$($Token)"
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($authPair))
$headers = @{
    "Authorization" = "Basic $encodedCredentials"
    "Content-Type"  = "application/json"
    "Accept"        = "application/json"
}

# Function to link a single pair
function Link-JiraIssue {
    param (
        [string]$InwardKey,
        [string]$OutwardKey
    )

    if ([string]::IsNullOrWhiteSpace($InwardKey)) { return }
    $InwardKey = $InwardKey.Trim()

    Write-Host "Linking $OutwardKey (Outward) to $InwardKey (Inward)..."

    $body = @{
        type = @{
            name = "Test"
        }
        inwardIssue = @{
            key = $InwardKey
        }
        outwardIssue = @{
            key = $OutwardKey
        }
    } | ConvertTo-Json -Depth 3

    try {
        $response = Invoke-RestMethod -Uri "https://$Domain/rest/api/2/issueLink" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -ErrorAction Stop
        
        Write-Host "Success." -ForegroundColor Green
    } catch {
        Write-Error "Failed to link issues. Error: $_"
    }
}

# Main Logic
if (Test-Path $InputArg) {
    Write-Host "Detected file input: $InputArg"
    Write-Host "Iterating through issues..."
    
    Get-Content -Path $InputArg | ForEach-Object {
        Link-JiraIssue -InwardKey $_ -OutwardKey $OutwardKey
    }
} else {
    # Treat as a single issue key
    Link-JiraIssue -InwardKey $InputArg -OutwardKey $OutwardKey
}

Write-Host "Done."
