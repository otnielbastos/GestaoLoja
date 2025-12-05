# Script para aplicar a migration de desconto nos pedidos
# Execute este script para adicionar os campos de desconto na tabela pedidos

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Aplicar Migration: Campos de Desconto" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se o Supabase está rodando
Write-Host "Verificando se o Supabase está rodando..." -ForegroundColor Yellow

# Tentar conectar ao banco
$connectionString = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

# Ler o arquivo de migration
$migrationPath = Join-Path $PSScriptRoot "..\migrations\03_add_desconto_pedidos.sql"
$migrationContent = Get-Content $migrationPath -Raw

Write-Host "Migration encontrada: $migrationPath" -ForegroundColor Green
Write-Host ""

# Executar a migration usando psql ou docker exec
Write-Host "Aplicando migration..." -ForegroundColor Yellow

# Método 1: Usar docker exec (se Supabase estiver rodando via Docker)
try {
    $containerName = docker ps --format "{{.Names}}" | Select-String "supabase_db" | Select-Object -First 1
    
    if ($containerName) {
        Write-Host "Container encontrado: $containerName" -ForegroundColor Green
        $migrationContent | docker exec -i $containerName psql -U postgres -d postgres
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Migration aplicada com sucesso!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Os seguintes campos foram adicionados à tabela pedidos:" -ForegroundColor Cyan
            Write-Host "  - valor_desconto" -ForegroundColor White
            Write-Host "  - percentual_desconto" -ForegroundColor White
            Write-Host "  - tipo_desconto" -ForegroundColor White
            Write-Host "  - valor_subtotal" -ForegroundColor White
        } else {
            Write-Host ""
            Write-Host "❌ Erro ao aplicar migration" -ForegroundColor Red
        }
    } else {
        Write-Host "Container do Supabase não encontrado." -ForegroundColor Red
        Write-Host ""
        Write-Host "Tentando método alternativo..." -ForegroundColor Yellow
        
        # Método 2: Usar supabase db execute
        Write-Host "Execute manualmente no Supabase Studio:" -ForegroundColor Yellow
        Write-Host "1. Acesse http://127.0.0.1:54323" -ForegroundColor White
        Write-Host "2. Vá em SQL Editor" -ForegroundColor White
        Write-Host "3. Cole o conteúdo do arquivo:" -ForegroundColor White
        Write-Host "   $migrationPath" -ForegroundColor Cyan
        Write-Host "4. Execute o SQL" -ForegroundColor White
    }
} catch {
    Write-Host ""
    Write-Host "Erro: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Execute manualmente no Supabase Studio:" -ForegroundColor Yellow
    Write-Host "1. Acesse http://127.0.0.1:54323" -ForegroundColor White
    Write-Host "2. Vá em SQL Editor" -ForegroundColor White
    Write-Host "3. Cole o conteúdo do arquivo:" -ForegroundColor White
    Write-Host "   $migrationPath" -ForegroundColor Cyan
    Write-Host "4. Execute o SQL" -ForegroundColor White
}

Write-Host ""




