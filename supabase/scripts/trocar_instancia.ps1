# Script para trocar entre instancias do Supabase local
# Execute: .\supabase\scripts\trocar_instancia.ps1

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("original", "copia", "GestaoLoja", "GestaoLoja-Prod_Local")]
    [string]$Instancia = ""
)

Write-Host "Trocar Instancia do Supabase Local" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($Instancia)) {
    Write-Host "Escolha a instancia:" -ForegroundColor Yellow
    Write-Host "   1. original (GestaoLoja) - Porta 54321" -ForegroundColor White
    Write-Host "   2. copia (GestaoLoja-Prod_Local) - Porta 54331" -ForegroundColor White
    Write-Host ""
    $escolha = Read-Host "Digite 1 ou 2"
    
    if ($escolha -eq "1") {
        $Instancia = "original"
    } elseif ($escolha -eq "2") {
        $Instancia = "copia"
    } else {
        Write-Host "Opcao invalida!" -ForegroundColor Red
        exit 1
    }
}

# Normalizar nome
if ($Instancia -eq "GestaoLoja" -or $Instancia -eq "original") {
    $Instancia = "original"
    $Url = "http://127.0.0.1:54321"
    $AnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    $Nome = "GestaoLoja (Original)"
} else {
    $Instancia = "copia"
    $Url = "http://127.0.0.1:54331"
    $AnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    $Nome = "GestaoLoja-Prod_Local (Copia)"
}

Write-Host ""
Write-Host "Atualizando .env.local para usar: $Nome" -ForegroundColor Yellow
Write-Host ""

# Criar conteudo do .env.local
if ($Instancia -eq "original") {
    $envContent = @"
# ============================================
# CONFIGURACAO DO SUPABASE LOCAL
# ============================================
# 
# Este arquivo permite escolher qual instancia do Supabase local usar.
# 
# INSTANCIAS DISPONIVEIS:
# 
# 1. INSTANCIA ORIGINAL (GestaoLoja)
#    - URL: http://127.0.0.1:54321
#    - Studio: http://127.0.0.1:54323
#    - Database: postgresql://postgres:postgres@127.0.0.1:54322/postgres
# 
# 2. INSTANCIA COPIA (GestaoLoja-Prod_Local)
#    - URL: http://127.0.0.1:54331
#    - Studio: http://127.0.0.1:54333
#    - Database: postgresql://postgres:postgres@127.0.0.1:54332/postgres
#
# ============================================
# INSTRUCOES:
# ============================================
# 
# Para trocar de instancia:
#   1. Descomente a instancia desejada abaixo (remova o #)
#   2. Comente a instancia atual (adicione # no inicio das linhas)
#   3. Reinicie o servidor (npm run dev)
# 
# OU use o script automatizado:
#   .\supabase\scripts\trocar_instancia.ps1
#
# ============================================
# INSTANCIA ORIGINAL (GestaoLoja) - ATIVA
# ============================================
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=$AnonKey

# ============================================
# INSTANCIA COPIA (GestaoLoja-Prod_Local) - INATIVA
# ============================================
# VITE_SUPABASE_URL=http://127.0.0.1:54331
# VITE_SUPABASE_ANON_KEY=$AnonKey

# ============================================
# NOTAS:
# ============================================
# - A senha do banco PostgreSQL local e "postgres" (padrao do Supabase)
# - A aplicacao nao usa senha diretamente - ela usa as chaves acima
# - Para acessar o Studio:
#   * Original: http://127.0.0.1:54323
#   * Copia: http://127.0.0.1:54333
#
# ============================================
"@
} else {
    $envContent = @"
# ============================================
# CONFIGURACAO DO SUPABASE LOCAL
# ============================================
# 
# Este arquivo permite escolher qual instancia do Supabase local usar.
# 
# INSTANCIAS DISPONIVEIS:
# 
# 1. INSTANCIA ORIGINAL (GestaoLoja)
#    - URL: http://127.0.0.1:54321
#    - Studio: http://127.0.0.1:54323
#    - Database: postgresql://postgres:postgres@127.0.0.1:54322/postgres
# 
# 2. INSTANCIA COPIA (GestaoLoja-Prod_Local)
#    - URL: http://127.0.0.1:54331
#    - Studio: http://127.0.0.1:54333
#    - Database: postgresql://postgres:postgres@127.0.0.1:54332/postgres
#
# ============================================
# INSTRUCOES:
# ============================================
# 
# Para trocar de instancia:
#   1. Descomente a instancia desejada abaixo (remova o #)
#   2. Comente a instancia atual (adicione # no inicio das linhas)
#   3. Reinicie o servidor (npm run dev)
# 
# OU use o script automatizado:
#   .\supabase\scripts\trocar_instancia.ps1
#
# ============================================
# INSTANCIA ORIGINAL (GestaoLoja) - INATIVA
# ============================================
# VITE_SUPABASE_URL=http://127.0.0.1:54321
# VITE_SUPABASE_ANON_KEY=$AnonKey

# ============================================
# INSTANCIA COPIA (GestaoLoja-Prod_Local) - ATIVA
# ============================================
VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_ANON_KEY=$AnonKey

# ============================================
# NOTAS:
# ============================================
# - A senha do banco PostgreSQL local e "postgres" (padrao do Supabase)
# - A aplicacao nao usa senha diretamente - ela usa as chaves acima
# - Para acessar o Studio:
#   * Original: http://127.0.0.1:54323
#   * Copia: http://127.0.0.1:54333
#
# ============================================
"@
}

# Salvar arquivo
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText(".\.env.local", $envContent, $utf8NoBom)

Write-Host "Arquivo .env.local atualizado!" -ForegroundColor Green
Write-Host ""
Write-Host "Configuracao ativa:" -ForegroundColor Cyan
Write-Host "   Instancia: $Nome" -ForegroundColor Gray
Write-Host "   URL: $Url" -ForegroundColor Gray
Write-Host ""
Write-Host "IMPORTANTE: Reinicie o servidor de desenvolvimento para aplicar as mudancas!" -ForegroundColor Yellow
Write-Host "   Pressione Ctrl+C no terminal onde o npm run dev esta rodando" -ForegroundColor Gray
Write-Host "   E execute novamente: npm run dev" -ForegroundColor Gray
Write-Host ""

