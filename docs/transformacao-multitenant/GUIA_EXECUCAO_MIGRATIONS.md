# 🚀 GUIA DE EXECUÇÃO DAS MIGRATIONS - Fase 1

> **Data:** 05/12/2025  
> **Fase:** Fase 1 - Banco de Dados Multi-Tenant  
> **Ambiente:** Teste (Desenvolvimento)

---

## 📋 ÍNDICE

1. [Visão Geral](#visao-geral)
2. [Pré-requisitos](#pre-requisitos)
3. [Ordem de Execução](#ordem-execucao)
4. [Como Executar](#como-executar)
5. [Verificação](#verificacao)
6. [Rollback](#rollback)
7. [Troubleshooting](#troubleshooting)

---

## 📊 VISÃO GERAL

**Total de Migrations:** 16 arquivos SQL  
**Tempo Estimado:** 15-20 minutos  
**Objetivo:** Criar estrutura multi-tenant no banco de dados

### Migrations Criadas:

#### **Grupo 1: Novas Tabelas (04-10)**
- ✅ `04_create_empresas.sql` - Empresas (tenants)
- ✅ `05_create_filiais.sql` - Filiais por empresa
- ✅ `06_create_planos.sql` - Planos de assinatura + 4 planos padrão
- ✅ `07_create_usuarios_empresas.sql` - Relacionamento N:N + funções auxiliares
- ✅ `08_create_limites_uso.sql` - Controle de uso por plano
- ✅ `09_create_historico_assinaturas.sql` - Histórico financeiro
- ✅ `10_create_convites_pendentes.sql` - Sistema de convites

#### **Grupo 2: Adicionar empresa_id (11-19)**
- ✅ `11_add_empresa_id_usuarios.sql`
- ✅ `12_add_empresa_id_clientes.sql`
- ✅ `13_add_empresa_id_produtos.sql`
- ✅ `14_add_empresa_id_pedidos.sql`
- ✅ `15_add_empresa_filial_estoque.sql` ⚠️ (empresa_id + filial_id)
- ✅ `16_add_empresa_id_entregas.sql`
- ✅ `17_add_empresa_id_movimentacoes.sql`
- ✅ `18_add_empresa_id_transferencias.sql`
- ✅ `19_add_empresa_id_auditoria.sql`

---

## ✅ PRÉ-REQUISITOS

### Antes de Executar:

- [ ] **Backup completo do banco** (já feito pelo usuário ✅)
- [ ] **Ambiente de teste criado** (Supabase separado) ✅
- [ ] **Supabase CLI instalado** (recomendado, mas não obrigatório)
- [ ] **Acesso ao Dashboard do Supabase**
- [ ] **Git commit das migrations** (para versionamento)

### Verificar Conexão:

```bash
# Testar conexão com Supabase (opcional)
supabase status
```

---

## 📝 ORDEM DE EXECUÇÃO

**IMPORTANTE:** Execute na ordem exata! Algumas migrations dependem de outras.

```
GRUPO 1: Criar Novas Tabelas
├─ 04_create_empresas.sql      (1° - Tabela principal)
├─ 05_create_filiais.sql        (2° - Depende de empresas)
├─ 06_create_planos.sql         (3° - Adiciona FK em empresas)
├─ 07_create_usuarios_empresas  (4° - Depende de empresas + auth.users)
├─ 08_create_limites_uso.sql    (5° - Depende de empresas + planos)
├─ 09_create_historico.sql      (6° - Depende de empresas + planos)
└─ 10_create_convites.sql       (7° - Depende de empresas + auth.users)

GRUPO 2: Adicionar empresa_id (ordem flexível)
├─ 11_add_empresa_id_usuarios.sql
├─ 12_add_empresa_id_clientes.sql
├─ 13_add_empresa_id_produtos.sql
├─ 14_add_empresa_id_pedidos.sql
├─ 15_add_empresa_filial_estoque.sql
├─ 16_add_empresa_id_entregas.sql
├─ 17_add_empresa_id_movimentacoes.sql
├─ 18_add_empresa_id_transferencias.sql
└─ 19_add_empresa_id_auditoria.sql
```

---

## 🎯 COMO EXECUTAR

### **Método 1: Supabase Dashboard (Recomendado)**

#### Passo 1: Acessar SQL Editor

1. Abrir Supabase Dashboard: https://app.supabase.com
2. Selecionar projeto de **teste**
3. Ir em **SQL Editor** (menu lateral esquerdo)

#### Passo 2: Executar Migrations

Para cada arquivo SQL (na ordem):

1. Clicar em **"New query"**
2. Copiar conteúdo do arquivo SQL
3. Colar no editor
4. Clicar em **"Run"** (ou F5)
5. ✅ Verificar mensagem de sucesso
6. ❌ Se erro, ver seção [Troubleshooting](#troubleshooting)

#### Exemplo:

```sql
-- Copiar todo o conteúdo de 04_create_empresas.sql
-- Colar no SQL Editor
-- Clicar em Run
-- Aguardar sucesso: "Success. No rows returned"
```

#### Passo 3: Repetir para Todas

Executar **uma por uma**, na ordem:
- 04, 05, 06, 07, 08, 09, 10 (Grupo 1)
- 11, 12, 13, 14, 15, 16, 17, 18, 19 (Grupo 2)

---

### **Método 2: Supabase CLI (Alternativo)**

Se tiver Supabase CLI instalado:

```bash
# Navegar até pasta do projeto
cd C:\dev\GestaoLoja

# Executar migrations
supabase db push

# OU executar uma por vez:
supabase db execute --file supabase/migrations/04_create_empresas.sql
supabase db execute --file supabase/migrations/05_create_filiais.sql
# ... e assim por diante
```

---

### **Método 3: Script Batch (Windows)**

Criar arquivo `executar_migrations.bat`:

```batch
@echo off
echo Executando migrations da Fase 1...
echo.

REM Execute manualmente via Supabase Dashboard
echo Abra o Supabase Dashboard e execute as migrations na ordem:
echo.
echo GRUPO 1:
echo - 04_create_empresas.sql
echo - 05_create_filiais.sql
echo - 06_create_planos.sql
echo - 07_create_usuarios_empresas.sql
echo - 08_create_limites_uso.sql
echo - 09_create_historico_assinaturas.sql
echo - 10_create_convites_pendentes.sql
echo.
echo GRUPO 2:
echo - 11 a 19 (adicionar empresa_id)
echo.
pause
```

---

## ✅ VERIFICAÇÃO

### Após Executar TODAS as Migrations:

#### 1. Verificar Tabelas Criadas

Execute no SQL Editor:

```sql
-- Verificar tabelas multi-tenant
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'empresas', 
    'filiais', 
    'planos', 
    'usuarios_empresas', 
    'limites_uso', 
    'historico_assinaturas', 
    'convites_pendentes'
)
ORDER BY table_name;

-- Deve retornar 7 tabelas
```

#### 2. Verificar Planos Inseridos

```sql
SELECT nome, preco_mensal, ordem 
FROM planos 
ORDER BY ordem;

-- Deve retornar 4 planos:
-- Trial (R$ 0,00)
-- Starter (R$ 79,90)
-- Pro (R$ 149,90)
-- Enterprise (R$ 299,90)
```

#### 3. Verificar Colunas Adicionadas

```sql
-- Verificar se empresa_id foi adicionado
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name = 'empresa_id'
ORDER BY table_name;

-- Deve retornar 9 tabelas com empresa_id
```

#### 4. Verificar Funções Criadas

```sql
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE '%empresa%'
ORDER BY routine_name;

-- Deve retornar funções auxiliares:
-- get_current_empresa_id
-- inicializar_limites_empresa
-- etc
```

#### 5. Teste Simples

```sql
-- Inserir empresa de teste
INSERT INTO empresas (nome, cnpj, email, plano_id)
VALUES (
    'Empresa Teste',
    '12.345.678/0001-90',
    'teste@exemplo.com',
    (SELECT id FROM planos WHERE nome = 'Trial')
)
RETURNING id, nome, status;

-- Deve retornar a empresa criada com status 'trial'
```

---

## 🔄 ROLLBACK

### Se Algo Der Errado:

#### **Opção 1: Restaurar Backup (Mais Seguro)**

```sql
-- No Supabase Dashboard:
-- Settings > Database > Backups > Restore
```

#### **Opção 2: Reverter Manualmente**

**Reverter Grupo 2 (empresa_id):**

```sql
-- Remover colunas empresa_id
ALTER TABLE auditoria DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE transferencias_estoque DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE movimentacoes_estoque DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE entregas DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE estoque DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE estoque DROP COLUMN IF EXISTS filial_id;
ALTER TABLE pedidos DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE produtos DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE clientes DROP COLUMN IF EXISTS empresa_id;
ALTER TABLE usuarios DROP COLUMN IF EXISTS empresa_id;
```

**Reverter Grupo 1 (tabelas novas):**

```sql
-- Remover tabelas (cuidado: perde dados!)
DROP TABLE IF EXISTS convites_pendentes CASCADE;
DROP TABLE IF EXISTS historico_assinaturas CASCADE;
DROP TABLE IF EXISTS limites_uso CASCADE;
DROP TABLE IF EXISTS usuarios_empresas CASCADE;
DROP TABLE IF EXISTS filiais CASCADE;
DROP TABLE IF EXISTS empresas CASCADE;
DROP TABLE IF EXISTS planos CASCADE;
```

---

## 🐛 TROUBLESHOOTING

### Problemas Comuns:

#### 1. **Erro: "relation already exists"**

**Causa:** Tabela já foi criada anteriormente

**Solução:**
```sql
-- Verificar se tabela existe
SELECT * FROM empresas LIMIT 1;

-- Se existe, pular essa migration
-- Se não deveria existir, fazer DROP primeiro
```

#### 2. **Erro: "permission denied"**

**Causa:** Usuário sem permissão

**Solução:** Executar como `service_role` ou `postgres` no Dashboard

#### 3. **Erro: "foreign key constraint"**

**Causa:** Tabela referenciada não existe

**Solução:** Executar migrations na ordem correta (ver [Ordem de Execução](#ordem-execucao))

#### 4. **Erro: "column empresa_id already exists"**

**Causa:** Migration já foi executada

**Solução:** 
```sql
-- Verificar se coluna existe
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'usuarios' AND column_name = 'empresa_id';

-- Se existe, pular migration
```

#### 5. **Erro: "syntax error"**

**Causa:** SQL copiado incorretamente

**Solução:** 
- Copiar arquivo SQL completo novamente
- Verificar se não falta nenhuma linha
- Executar todo o arquivo de uma vez (não linha por linha)

---

## 📊 CHECKLIST DE EXECUÇÃO

Use este checklist ao executar:

### Grupo 1: Novas Tabelas
- [ ] 04_create_empresas.sql executada ✅
- [ ] 05_create_filiais.sql executada ✅
- [ ] 06_create_planos.sql executada ✅
  - [ ] Verificar 4 planos inseridos ✅
- [ ] 07_create_usuarios_empresas.sql executada ✅
  - [ ] Verificar funções criadas ✅
- [ ] 08_create_limites_uso.sql executada ✅
- [ ] 09_create_historico_assinaturas.sql executada ✅
- [ ] 10_create_convites_pendentes.sql executada ✅

### Grupo 2: Adicionar empresa_id
- [ ] 11_add_empresa_id_usuarios.sql ✅
- [ ] 12_add_empresa_id_clientes.sql ✅
- [ ] 13_add_empresa_id_produtos.sql ✅
- [ ] 14_add_empresa_id_pedidos.sql ✅
- [ ] 15_add_empresa_filial_estoque.sql ✅
- [ ] 16_add_empresa_id_entregas.sql ✅
- [ ] 17_add_empresa_id_movimentacoes.sql ✅
- [ ] 18_add_empresa_id_transferencias.sql ✅
- [ ] 19_add_empresa_id_auditoria.sql ✅

### Verificações Finais
- [ ] Todas as 7 tabelas novas existem ✅
- [ ] Todos os 4 planos foram inseridos ✅
- [ ] Todas as 9 tabelas têm empresa_id ✅
- [ ] Funções auxiliares criadas ✅
- [ ] Sem erros no console ✅
- [ ] Teste simples executado com sucesso ✅

---

## 🎉 PRÓXIMOS PASSOS

Após executar com sucesso:

1. ✅ **Popular dados fake** (empresas, filiais de teste)
2. ✅ **Testar queries básicas**
3. ✅ **Atualizar CHECKLIST_PROGRESSO.md**
4. ✅ **Atualizar CHANGELOG.md**
5. ✅ **Commit das mudanças**
6. ⏭️ **Iniciar Fase 2: RLS e Isolamento**

---

## 📞 AJUDA

Se encontrar problemas:

1. Consultar seção [Troubleshooting](#troubleshooting)
2. Verificar logs de erro no Supabase Dashboard
3. Consultar documentação Supabase: https://supabase.com/docs
4. Restaurar backup se necessário

---

**Última atualização:** 05/12/2025  
**Autor:** Sistema  
**Versão:** 1.0



