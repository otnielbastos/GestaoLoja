# Script para copiar Storage (imagens) de producao para local
# Execute: .\supabase\scripts\copiar_storage_producao.ps1
#
# Este script:
# 1. Lista todos os arquivos do bucket de producao
# 2. Baixa cada arquivo
# 3. Faz upload para o Supabase local
# 4. Aplica as mesmas politicas de producao

param(
    [string]$ProdUrl = "",
    [string]$ProdAnonKey = "",
    [string]$LocalUrl = "http://127.0.0.1:54321",
    [string]$LocalAnonKey = "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH",
    [string]$BucketName = "uploads"
)

Write-Host "Copiar Storage de Producao para Local" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar credenciais de producao se nao fornecidas
if ([string]::IsNullOrEmpty($ProdUrl) -or [string]::IsNullOrEmpty($ProdAnonKey)) {
    Write-Host "Informe as credenciais do Supabase de producao:" -ForegroundColor Yellow
    Write-Host ""
    if ([string]::IsNullOrEmpty($ProdUrl)) {
        $ProdUrl = Read-Host "URL do Supabase de producao (ex: https://xxxxx.supabase.co)"
    }
    if ([string]::IsNullOrEmpty($ProdAnonKey)) {
        $ProdAnonKey = Read-Host "Chave ANON do Supabase de producao"
    }
}

Write-Host ""
Write-Host "Configuracao:" -ForegroundColor Cyan
Write-Host "   Producao URL: $ProdUrl" -ForegroundColor Gray
Write-Host "   Local URL: $LocalUrl" -ForegroundColor Gray
Write-Host "   Bucket: $BucketName" -ForegroundColor Gray
Write-Host ""

# Verificar se o bucket existe no local
Write-Host "Verificando bucket local..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$LocalUrl/storage/v1/bucket/$BucketName" `
        -Method GET `
        -Headers @{
            "apikey" = $LocalAnonKey
            "Authorization" = "Bearer $LocalAnonKey"
        } -ErrorAction Stop
    
    Write-Host "   Bucket local encontrado" -ForegroundColor Green
} catch {
    Write-Host "   Bucket local nao encontrado. Criando..." -ForegroundColor Yellow
    
    # Criar bucket no local
    $bucketData = @{
        id = $BucketName
        name = $BucketName
        public = $true
        file_size_limit = 52428800
        allowed_mime_types = @("image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp")
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri "$LocalUrl/storage/v1/bucket" `
            -Method POST `
            -Headers @{
                "apikey" = $LocalAnonKey
                "Authorization" = "Bearer $LocalAnonKey"
                "Content-Type" = "application/json"
            } `
            -Body $bucketData -ErrorAction Stop
        
        Write-Host "   Bucket criado com sucesso" -ForegroundColor Green
    } catch {
        Write-Host "   Erro ao criar bucket: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Tente criar manualmente via Supabase Studio ou execute a migration 02_storage_setup.sql" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "Listando arquivos de producao..." -ForegroundColor Yellow

# Listar todos os arquivos do bucket de producao
$allFiles = @()
$pageSize = 1000
$offset = 0

do {
    try {
        $listUrl = "$ProdUrl/storage/v1/object/list/$BucketName" + 
                   "?limit=$pageSize&offset=$offset&sortBy=name"
        
        $response = Invoke-RestMethod -Uri $listUrl `
            -Method GET `
            -Headers @{
                "apikey" = $ProdAnonKey
                "Authorization" = "Bearer $ProdAnonKey"
            }
        
        if ($response -is [array]) {
            $allFiles += $response
            $offset += $pageSize
            Write-Host "   Encontrados $($allFiles.Count) arquivos..." -ForegroundColor Gray
        } else {
            break
        }
    } catch {
        Write-Host "   Erro ao listar arquivos: $($_.Exception.Message)" -ForegroundColor Red
        break
    }
} while ($response.Count -eq $pageSize)

if ($allFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "Nenhum arquivo encontrado no bucket de producao." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Total de arquivos encontrados: $($allFiles.Count)" -ForegroundColor Green
Write-Host ""

# Criar diretorio temporario para downloads
$tempDir = Join-Path $env:TEMP "supabase_storage_backup"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

$copied = 0
$failed = 0
$skipped = 0

# Copiar cada arquivo
foreach ($file in $allFiles) {
    $filePath = $file.name
    $fileName = Split-Path -Leaf $filePath
    
    Write-Host "Copiando: $filePath" -ForegroundColor Gray -NoNewline
    
    try {
        # Baixar arquivo de producao
        $downloadUrl = "$ProdUrl/storage/v1/object/public/$BucketName/$filePath"
        $localFilePath = Join-Path $tempDir $fileName
        
        # Criar subdiretorios se necessario
        $localFileDir = Split-Path -Parent $localFilePath
        if ($localFileDir -and -not (Test-Path $localFileDir)) {
            New-Item -ItemType Directory -Path $localFileDir -Force | Out-Null
        }
        
        Invoke-WebRequest -Uri $downloadUrl -OutFile $localFilePath -ErrorAction Stop
        
        # Fazer upload para local
        $fileContent = [System.IO.File]::ReadAllBytes($localFilePath)
        $boundary = [System.Guid]::NewGuid().ToString()
        $fileBody = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($fileContent)
        
        $bodyLines = @(
            "--$boundary",
            "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
            "Content-Type: $($file.metadata.mimetype)",
            "",
            [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($fileBody),
            "--$boundary--"
        )
        $body = $bodyLines -join "`r`n"
        $bodyBytes = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($body)
        
        $uploadUrl = "$LocalUrl/storage/v1/object/$BucketName/$filePath"
        
        Invoke-RestMethod -Uri $uploadUrl `
            -Method POST `
            -Headers @{
                "apikey" = $LocalAnonKey
                "Authorization" = "Bearer $LocalAnonKey"
                "Content-Type" = "multipart/form-data; boundary=$boundary"
            } `
            -Body $bodyBytes -ErrorAction Stop
        
        $copied++
        Write-Host " [OK]" -ForegroundColor Green
        
        # Limpar arquivo temporario
        Remove-Item $localFilePath -ErrorAction SilentlyContinue
        
    } catch {
        $failed++
        Write-Host " [ERRO: $($_.Exception.Message)]" -ForegroundColor Red
    }
}

# Limpar diretorio temporario
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Resumo da Copia:" -ForegroundColor Cyan
Write-Host "   Total: $($allFiles.Count)" -ForegroundColor Gray
Write-Host "   Copiados: $copied" -ForegroundColor Green
Write-Host "   Falhas: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

if ($copied -gt 0) {
    Write-Host "Politicas de Storage:" -ForegroundColor Yellow
    Write-Host "   As politicas de producao ja foram aplicadas durante o restore do banco." -ForegroundColor Gray
    Write-Host "   Se precisar ajustar, execute a migration 02_storage_setup.sql" -ForegroundColor Gray
    Write-Host ""
}




