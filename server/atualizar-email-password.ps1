# Script para atualizar a senha de e-mail no arquivo .env
# Uso: .\atualizar-email-password.ps1 "sua_senha_de_app_aqui"

param(
    [Parameter(Mandatory=$true)]
    [string]$NovaSenha
)

$envFile = Join-Path $PSScriptRoot ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "❌ Arquivo .env não encontrado em: $envFile"
    exit 1
}

# Ler o conteúdo do arquivo
$content = Get-Content $envFile

# Substituir ou adicionar EMAIL_PASSWORD
$updated = $false
$newContent = $content | ForEach-Object {
    if ($_ -match "^EMAIL_PASSWORD=") {
        $updated = $true
        "EMAIL_PASSWORD=$NovaSenha"
    } else {
        $_
    }
}

# Se não encontrou a linha, adicionar
if (-not $updated) {
    $newContent += "EMAIL_PASSWORD=$NovaSenha"
}

# Salvar o arquivo
$newContent | Set-Content $envFile -Encoding UTF8

Write-Host "✅ EMAIL_PASSWORD atualizado com sucesso!"
Write-Host "   Reinicie o servidor para aplicar as mudanças."

