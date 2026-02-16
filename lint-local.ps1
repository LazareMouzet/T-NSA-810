# Script de linter simplifie pour Windows PowerShell
Write-Host "--- Execution des linters locaux ---" -ForegroundColor Green

$ErrorsFound = $false

# 1. YAML Lint
Write-Host "1. YAML Lint..." -ForegroundColor Cyan
try {
    yamllint . --config-data "{extends: default, rules: {line-length: disable}}"
    if ($LASTEXITCODE -ne 0) { $ErrorsFound = $true }
} catch {
    Write-Host "Error: yamllint non trouve." -ForegroundColor Red
    $ErrorsFound = $true
}

# 2. Ansible Lint
Write-Host "2. Ansible Lint..." -ForegroundColor Cyan
try {
    ansible-lint scripts/
    if ($LASTEXITCODE -ne 0) { $ErrorsFound = $true }
} catch {
    Write-Host "Error: ansible-lint non trouve." -ForegroundColor Red
    $ErrorsFound = $true
}

# 3. GitHub Actions Lint
Write-Host "3. GitHub Actions Lint..." -ForegroundColor Cyan
try {
    actionlint
    if ($LASTEXITCODE -ne 0) { $ErrorsFound = $true }
} catch {
    Write-Host "Error: actionlint non trouve." -ForegroundColor Red
    $ErrorsFound = $true
}

# 4. Terraform Lint
Write-Host "4. Terraform Lint..." -ForegroundColor Cyan
try {
    tflint -r
    if ($LASTEXITCODE -ne 0) { $ErrorsFound = $true }
} catch {
    Write-Host "Error: tflint non trouve." -ForegroundColor Red
    $ErrorsFound = $true
}

# 5. Markdown Lint
Write-Host "5. Markdown Lint..." -ForegroundColor Cyan
try {
    markdownlint . --config .markdownlint.json
    if ($LASTEXITCODE -ne 0) { $ErrorsFound = $true }
} catch {
    Write-Host "Error: markdownlint-cli non trouve." -ForegroundColor Red
    $ErrorsFound = $true
}

# Resume
if ($ErrorsFound) {
    Write-Host "Termine avec des erreurs." -ForegroundColor Red
    exit 1
} else {
    Write-Host "Succes : Tous les linters sont OK !" -ForegroundColor Green
    exit 0
}