function Run-Git {
    param (
        [string]$Description,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$GitArgs
    )

    git @GitArgs 1>$null 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error during: $Description (exit code $LASTEXITCODE)"
        exit 1
    }
}

function Normalize-ProjectName {
    param (
        [string]$RawName
    )

    $normalized = $RawName.ToLower() `
        -replace '[ _]', '-' `
        -replace '[^a-z0-9\-]', ''

    return $normalized
}
