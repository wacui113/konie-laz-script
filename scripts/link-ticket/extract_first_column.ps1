param (
    [Parameter(Mandatory=$true)]
    [string]$InputFile,

    [Parameter(Mandatory=$false)]
    [string]$OutputFile
)

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Error "Error: File '$InputFile' not found."
    exit 1
}

try {
    # Read the file content
    # Using StreamReader is generally faster for large files, but Get-Content is simpler.
    # We use Get-Content here for readability, but piped to avoid loading everything into memory at once if possible.
    
    $results = Get-Content -Path $InputFile | Select-Object -Skip 1 | ForEach-Object {
        $line = $_
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $commaIndex = $line.IndexOf(',')
            
            if ($commaIndex -gt 0) {
                # Substring from 0 to the comma
                $line.Substring(0, $commaIndex)
            } elseif ($commaIndex -eq -1) {
                # No comma found, take the whole line
                $line
            } else {
                # Comma is at index 0 (empty first column)
                ""
            }
        }
    }

    if ($OutputFile) {
        $results | Set-Content -Path $OutputFile
        Write-Host "Success! First column extracted to '$OutputFile'"
    } else {
        $results
    }

} catch {
    Write-Error "An error occurred: $_"
}
