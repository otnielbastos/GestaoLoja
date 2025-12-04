# Guia: Criar Instância Cópia do Supabase Local

Este guia explica como criar uma segunda instância do Supabase local com uma cópia exata do banco de dados atual.

## 🎯 Objetivo

Criar um ambiente de desenvolvimento/teste separado com os mesmos dados, permitindo:
- Testar mudanças sem afetar o ambiente principal
- Ter múltiplos ambientes (dev, test, staging)
- Fazer experimentos sem risco

## 📋 Métodos Disponíveis

### Método 1: Script Automatizado (Recomendado) ⚡

Use o script PowerShell que automatiza todo o processo:

```powershell
.\supabase\scripts\criar_instancia_copia.ps1
```

O script vai:
1. ✅ Fazer backup do banco atual
2. ✅ Criar novo projeto com `project_id` diferente
3. ✅ Configurar portas diferentes (para evitar conflitos)
4. ✅ Restaurar backup no novo projeto
5. ✅ Configurar storage

**Exemplo de uso:**
```powershell
.\supabase\scripts\criar_instancia_copia.ps1 -NovoProjectId "GestaoLoja-Teste"
```

### Método 2: Manual (Passo a Passo) 🖱️

#### Passo 1: Fazer Backup do Banco Atual

```powershell
# Criar backup
docker exec supabase_db_GestaoLoja pg_dump -U postgres -d postgres -F p > backup_copia.sql
```

#### Passo 2: Criar Novo Diretório

```powershell
# Criar diretório para novo projeto
mkdir supabase-GestaoLoja-Teste
cd supabase-GestaoLoja-Teste

# Inicializar Supabase
npx supabase init --project-id GestaoLoja-Teste
```

#### Passo 3: Configurar Portas Diferentes

Edite `supabase/config.toml` e altere as portas:

```toml
project_id = "GestaoLoja-Teste"

[api]
port = 54331  # Era 54321

[db]
port = 54332  # Era 54322

[studio]
port = 54333  # Era 54323
```

#### Passo 4: Iniciar Novo Projeto

```powershell
npx supabase start --project-id GestaoLoja-Teste --ignore-health-check
```

#### Passo 5: Restaurar Backup

```powershell
# Restaurar backup
Get-Content ..\backup_copia.sql | docker exec -i supabase_db_GestaoLoja-Teste psql -U postgres -d postgres
```

## 🔌 Portas Configuradas

O script automaticamente configura portas diferentes:

| Serviço | Projeto Original | Nova Instância |
|---------|-----------------|----------------|
| API | 54321 | 54331 |
| Database | 54322 | 54332 |
| Studio | 54323 | 54333 |
| Mailpit | 54324 | 54334 |
| Pooler | 54329 | 54339 |
| Shadow DB | 54320 | 54330 |

## 📁 Estrutura de Diretórios

Após criar a cópia, você terá:

```
GestaoLoja/
  ├── supabase/              # Projeto original
  │   └── config.toml
  └── supabase-GestaoLoja-Teste/  # Nova instância
      └── supabase/
          └── config.toml
```

## 🚀 Usar a Nova Instância

### Iniciar/Parar

```powershell
# Entrar no diretório do novo projeto
cd supabase-GestaoLoja-Teste

# Iniciar
npx supabase start --project-id GestaoLoja-Teste

# Parar
npx supabase stop --project-id GestaoLoja-Teste
```

### Atualizar .env.local

Para usar a nova instância na aplicação, atualize `.env.local`:

```env
# Nova instância
VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_ANON_KEY=(obtenha com: npx supabase status --project-id GestaoLoja-Teste)
```

### Obter Credenciais

```powershell
npx supabase status --project-id GestaoLoja-Teste
```

## ⚠️ Observações Importantes

1. **Portas:**
   - Cada instância precisa de portas diferentes
   - O script configura automaticamente
   - Verifique se as portas não estão em uso

2. **Storage:**
   - O storage (imagens) NÃO é copiado automaticamente
   - Use o script `copiar_storage_producao.ps1` se necessário
   - Ou copie manualmente via Supabase Studio

3. **Sincronização:**
   - As instâncias são independentes
   - Mudanças em uma não afetam a outra
   - Para sincronizar, faça novo backup/restore

4. **Recursos:**
   - Cada instância usa recursos do Docker
   - Múltiplas instâncias podem consumir mais memória/CPU
   - Pare instâncias não utilizadas

## 🔄 Sincronizar Dados Novamente

Para atualizar a cópia com dados mais recentes:

```powershell
# 1. Fazer novo backup do original
docker exec supabase_db_GestaoLoja pg_dump -U postgres -d postgres -F p > backup_atualizado.sql

# 2. Restaurar na cópia
Get-Content backup_atualizado.sql | docker exec -i supabase_db_GestaoLoja-Teste psql -U postgres -d postgres
```

## 🗑️ Remover Instância

Para remover uma instância criada:

```powershell
# 1. Parar a instância
cd supabase-GestaoLoja-Teste
npx supabase stop --project-id GestaoLoja-Teste

# 2. Remover diretório
cd ..
Remove-Item supabase-GestaoLoja-Teste -Recurse -Force

# 3. Remover volumes Docker (opcional)
docker volume ls --filter "label=com.supabase.cli.project=GestaoLoja-Teste"
docker volume rm <volume-id>
```

## ✅ Verificar se Funcionou

1. **Status:**
   ```powershell
   npx supabase status --project-id GestaoLoja-Teste
   ```

2. **Acessar Studio:**
   - http://127.0.0.1:54333
   - Verifique se os dados estão lá

3. **Verificar dados:**
   ```sql
   -- Conectar ao banco da nova instância
   docker exec -it supabase_db_GestaoLoja-Teste psql -U postgres -d postgres
   
   -- Verificar tabelas
   SELECT COUNT(*) FROM usuarios;
   ```

## 🎯 Casos de Uso

- **Desenvolvimento:** Testar novas features sem afetar dados principais
- **Testes:** Ambiente isolado para testes automatizados
- **Experimentos:** Tentar mudanças arriscadas sem medo
- **Treinamento:** Ambiente separado para treinar usuários

