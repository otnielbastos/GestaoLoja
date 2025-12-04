# Script para criar uma segunda instancia do Supabase local com copia exata
# Execute: .\supabase\scripts\criar_instancia_copia.ps1
#
# Este script:
# 1. Faz backup do banco atual
# 2. Cria um novo projeto Supabase com project_id diferente
# 3. Restaura o backup no novo projeto
# 4. Configura portas diferentes para evitar conflitos

param(
    [string]$NovoProjectId = "GestaoLoja-Prod_Local",
    [string]$BackupFile = ""
)

Write-Host "Criar Instancia Copia do Supabase Local" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Usar nome padrão se não fornecido
if ([string]::IsNullOrEmpty($NovoProjectId)) {
    $NovoProjectId = "GestaoLoja-Prod_Local"
}

Write-Host ""
Write-Host "Configuracao:" -ForegroundColor Cyan
Write-Host "   Projeto atual: GestaoLoja" -ForegroundColor Gray
Write-Host "   Novo projeto: $NovoProjectId" -ForegroundColor Gray
Write-Host ""

# Verificar se o projeto atual esta rodando
Write-Host "Verificando projeto atual..." -ForegroundColor Yellow
$status = npx supabase status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Projeto atual nao esta rodando. Iniciando..." -ForegroundColor Yellow
    npx supabase start --ignore-health-check
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   Erro ao iniciar projeto atual" -ForegroundColor Red
        exit 1
    }
}

# Passo 1: Fazer backup do banco atual
Write-Host ""
Write-Host "PASSO 1: Fazendo backup do banco atual..." -ForegroundColor Yellow

if ([string]::IsNullOrEmpty($BackupFile)) {
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $BackupFile = "backup_instancia_copia_$timestamp.sql"
}

$backupDir = ".\backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$BackupPath = Join-Path $backupDir $BackupFile

Write-Host "   Criando backup: $BackupFile" -ForegroundColor Gray

# Fazer dump do banco atual
docker exec supabase_db_GestaoLoja pg_dump -U postgres -d postgres -F p > $BackupPath 2>&1

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $BackupPath) -or (Get-Item $BackupPath).Length -eq 0) {
    Write-Host "   Erro ao criar backup" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $BackupPath).Length / 1MB
Write-Host "   Backup criado: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green

# Passo 2: Criar novo diretorio para o novo projeto
Write-Host ""
Write-Host "PASSO 2: Preparando novo projeto..." -ForegroundColor Yellow

$novoProjetoDir = ".\supabase-$NovoProjectId"
if (Test-Path $novoProjetoDir) {
    Write-Host "   Diretorio ja existe. Deseja sobrescrever? (s/N)" -ForegroundColor Yellow
    $confirm = Read-Host
    if ($confirm -ne "s" -and $confirm -ne "S") {
        Write-Host "   Operacao cancelada" -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $novoProjetoDir -Recurse -Force
}

# Criar estrutura do novo projeto
New-Item -ItemType Directory -Path $novoProjetoDir | Out-Null
New-Item -ItemType Directory -Path "$novoProjetoDir\supabase" | Out-Null
New-Item -ItemType Directory -Path "$novoProjetoDir\supabase\migrations" | Out-Null

# Copiar config.toml e modificar (sem BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$configOriginal = [System.IO.File]::ReadAllText(".\supabase\config.toml", $utf8NoBom)
$configNovo = $configOriginal -replace 'project_id = "GestaoLoja"', "project_id = `"$NovoProjectId`""

# Ajustar portas para evitar conflitos
$portas = @{
    "54321" = "54331"  # API
    "54322" = "54332"  # DB
    "54323" = "54333"  # Studio
    "54324" = "54334"  # Mailpit
    "54329" = "54339"  # Pooler
    "54320" = "54330"  # Shadow DB
}

foreach ($portaAntiga in $portas.Keys) {
    $portaNova = $portas[$portaAntiga]
    $configNovo = $configNovo -replace "port = $portaAntiga", "port = $portaNova"
    $configNovo = $configNovo -replace "shadow_port = $portaAntiga", "shadow_port = $portaNova"
}

# Salvar sem BOM
[System.IO.File]::WriteAllText("$novoProjetoDir\supabase\config.toml", $configNovo, $utf8NoBom)

Write-Host "   Estrutura criada em: $novoProjetoDir" -ForegroundColor Green
Write-Host "   Portas configuradas:" -ForegroundColor Gray
Write-Host "      API: 54331 (era 54321)" -ForegroundColor Gray
Write-Host "      DB: 54332 (era 54322)" -ForegroundColor Gray
Write-Host "      Studio: 54333 (era 54323)" -ForegroundColor Gray

# Passo 3: Criar estrutura completa do projeto
Write-Host ""
Write-Host "PASSO 3: Criando estrutura do projeto..." -ForegroundColor Yellow

Push-Location $novoProjetoDir

try {
    # Criar estrutura do Supabase manualmente (sem init para evitar problemas de encoding)
    if (-not (Test-Path ".\supabase\migrations")) {
        New-Item -ItemType Directory -Path ".\supabase\migrations" -Force | Out-Null
    }
    if (-not (Test-Path ".\supabase\seeds")) {
        New-Item -ItemType Directory -Path ".\supabase\seeds" -Force | Out-Null
    }
    
    # Garantir que config.toml esta sem BOM e correto
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    if (Test-Path ".\supabase\config.toml") {
        # Ler o config que foi criado no Passo 2
        $configAtual = [System.IO.File]::ReadAllText(".\supabase\config.toml", $utf8NoBom)
        # Salvar sem BOM
        [System.IO.File]::WriteAllText(".\supabase\config.toml", $configAtual, $utf8NoBom)
    }
    
    Write-Host "   Estrutura criada" -ForegroundColor Green
} catch {
    Write-Host "   Erro ao criar estrutura: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Passo 4: Iniciar novo projeto
Write-Host ""
Write-Host "PASSO 4: Iniciando novo projeto..." -ForegroundColor Yellow

npx supabase start --ignore-health-check

if ($LASTEXITCODE -ne 0) {
    Write-Host "   Erro ao iniciar novo projeto" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "   Aguardando servicos ficarem prontos (30 segundos)..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Passo 5: Restaurar backup
Write-Host ""
Write-Host "PASSO 5: Restaurando backup no novo projeto..." -ForegroundColor Yellow

# Voltar ao diretorio original para resolver o caminho do backup
Pop-Location
$backupPathAbsoluto = (Resolve-Path $BackupPath).Path
Push-Location $novoProjetoDir

# Restaurar backup usando Docker
Get-Content $backupPathAbsoluto | docker exec -i supabase_db_$NovoProjectId psql -U postgres -d postgres 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   Backup restaurado com sucesso" -ForegroundColor Green
} else {
    Write-Host "   Aviso: Pode ter havido erros na restauracao, mas continuando..." -ForegroundColor Yellow
}

Pop-Location

# Passo 6: Criar bucket de storage se necessario
Write-Host ""
Write-Host "PASSO 6: Configurando storage..." -ForegroundColor Yellow

$sqlStorage = @"
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'uploads',
  'uploads',
  true,
  52428800,
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY IF NOT EXISTS "Acesso publico para leitura (desenvolvimento)"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'uploads');

CREATE POLICY IF NOT EXISTS "Acesso publico para upload (desenvolvimento)"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'uploads');
"@

$sqlStorage | docker exec -i supabase_db_$NovoProjectId psql -U postgres -d postgres 2>&1 | Out-Null

Write-Host "   Storage configurado" -ForegroundColor Green

# Resumo
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Instancia Copia Criada com Sucesso!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Projeto Original (GestaoLoja):" -ForegroundColor Cyan
Write-Host "   API: http://127.0.0.1:54321" -ForegroundColor Gray
Write-Host "   Studio: http://127.0.0.1:54323" -ForegroundColor Gray
Write-Host "   DB: postgresql://postgres:postgres@127.0.0.1:54322/postgres" -ForegroundColor Gray
Write-Host ""
Write-Host "Nova Instancia ($NovoProjectId):" -ForegroundColor Cyan
Write-Host "   API: http://127.0.0.1:54331" -ForegroundColor Gray
Write-Host "   Studio: http://127.0.0.1:54333" -ForegroundColor Gray
Write-Host "   DB: postgresql://postgres:postgres@127.0.0.1:54332/postgres" -ForegroundColor Gray
Write-Host ""
Write-Host "Diretorio do novo projeto: $novoProjetoDir" -ForegroundColor Gray
Write-Host ""
Write-Host "Para usar o novo projeto:" -ForegroundColor Yellow
Write-Host "   1. Entre no diretorio: cd $novoProjetoDir" -ForegroundColor White
Write-Host "   2. Inicie/pare: npx supabase start/stop" -ForegroundColor White
Write-Host "   3. Atualize .env.local com as novas portas" -ForegroundColor White
Write-Host ""

