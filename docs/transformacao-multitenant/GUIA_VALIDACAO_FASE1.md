# ✅ GUIA DE VALIDAÇÃO - FASE 1: Banco de Dados Multi-Tenant

> **Data:** 05/12/2025  
> **Fase:** Fase 1 - Banco de Dados Multi-Tenant  
> **Objetivo:** Validar se todas as migrations foram executadas corretamente

---

## 📋 ÍNDICE

1. [Visão Geral](#visao-geral)
2. [Quando Validar](#quando-validar)
3. [Scripts Disponíveis](#scripts-disponiveis)
4. [Como Executar](#como-executar)
5. [Interpretando Resultados](#interpretando-resultados)
6. [Troubleshooting](#troubleshooting)

---

## 📊 VISÃO GERAL

Após executar as **16 migrations** da Fase 1, você precisa validar se tudo foi criado corretamente antes de avançar para a Fase 2 (RLS e Isolamento).

### O que é validado:

✅ **7 Tabelas Novas** criadas  
✅ **9 Tabelas Existentes** com `empresa_id` adicionado  
✅ **4 Planos** inseridos (Trial, Starter, Pro, Enterprise)  
✅ **4 Funções Auxiliares** criadas  
✅ **Índices** em `empresa_id` criados  
✅ **Foreign Keys** configuradas corretamente  
✅ **Triggers** e **Constraints** criados  

---

## ⏰ QUANDO VALIDAR

Execute a validação:

1. ✅ **Após executar TODAS as 16 migrations** (04 a 19)
2. ✅ **Antes de iniciar a Fase 2** (RLS e Isolamento)
3. ✅ **Se tiver dúvidas** se alguma migration foi executada
4. ✅ **Após restaurar backup** para verificar integridade

---

## 📁 SCRIPTS DISPONÍVEIS

Temos **3 scripts** de validação, cada um com um propósito:

### 1. `validar_fase1_rapido.sql` ⚡ (Recomendado para início)

**Uso:** Validação rápida e resumida  
**Tempo:** ~2 segundos  
**Ideal para:** Verificação rápida se tudo está OK

**O que faz:**
- Mostra resumo de 6 categorias principais
- Resultado final: ✅ ou ❌
- Não mostra detalhes, só status

### 2. `validar_fase1_simples.sql` 📊 (Recomendado para validação completa)

**Uso:** Validação completa e detalhada  
**Tempo:** ~5 segundos  
**Ideal para:** Validação completa antes da Fase 2

**O que faz:**
- Valida todas as categorias
- Mostra detalhes de cada validação
- Lista tabelas, funções, índices encontrados
- Resumo final consolidado

### 3. `validar_fase1.sql` 🔍 (Para uso via CLI/psql)

**Uso:** Validação completa com mensagens formatadas  
**Tempo:** ~10 segundos  
**Ideal para:** Executar via terminal (psql) ou Supabase CLI

**O que faz:**
- Tudo do script simples
- Mensagens formatadas com `\echo`
- Mais verboso e organizado
- Melhor para debug

---

## 🚀 COMO EXECUTAR

### **Método 1: Supabase Dashboard (Recomendado)**

#### Passo 1: Acessar SQL Editor

1. Abrir Supabase Dashboard: https://app.supabase.com
2. Selecionar projeto de **teste**
3. Ir em **SQL Editor** (menu lateral esquerdo)

#### Passo 2: Executar Script

**Para validação rápida:**
1. Clicar em **"New query"**
2. Abrir arquivo: `supabase/scripts/validar_fase1_rapido.sql`
3. Copiar todo o conteúdo
4. Colar no SQL Editor
5. Clicar em **"Run"** (ou F5)
6. ✅ Verificar resultados

**Para validação completa:**
1. Clicar em **"New query"**
2. Abrir arquivo: `supabase/scripts/validar_fase1_simples.sql`
3. Copiar todo o conteúdo
4. Colar no SQL Editor
5. Clicar em **"Run"** (ou F5)
6. ✅ Verificar resultados detalhados

#### Passo 3: Interpretar Resultados

Ver seção [Interpretando Resultados](#interpretando-resultados) abaixo.

---

### **Método 2: Supabase CLI**

Se tiver Supabase CLI instalado:

```bash
# Navegar até pasta do projeto
cd C:\dev\GestaoLoja

# Executar validação rápida
supabase db execute --file supabase/scripts/validar_fase1_rapido.sql

# OU validação completa
supabase db execute --file supabase/scripts/validar_fase1_simples.sql
```

---

### **Método 3: psql (PostgreSQL CLI)**

Se tiver acesso direto ao banco via psql:

```bash
# Conectar ao banco
psql -h [HOST] -U [USER] -d [DATABASE]

# Executar validação completa
\i supabase/scripts/validar_fase1.sql
```

---

## 📊 INTERPRETANDO RESULTADOS

### ✅ **Resultado Esperado (Sucesso)**

Todas as validações devem mostrar **✅**:

```
categoria          | resultado | status
--------------------+-----------+--------
Tabelas Novas       | 7/7       | ✅
Colunas empresa_id  | 9/9       | ✅
Planos Inseridos    | 4/4       | ✅
Funções Auxiliares  | 4/4       | ✅
Índices empresa_id  | 9+/9+     | ✅
Foreign Keys        | 10+/10+   | ✅
```

**Resultado Final:** `🎉 FASE 1 VALIDADA COM SUCESSO! Pronto para Fase 2!`

---

### ❌ **Resultado com Erros**

Se alguma validação mostrar **❌**:

```
categoria          | resultado | status
--------------------+-----------+--------
Tabelas Novas       | 5/7       | ❌  ← FALTAM 2 TABELAS!
Colunas empresa_id   | 7/9       | ❌  ← FALTAM 2 COLUNAS!
Planos Inseridos   | 4/4       | ✅
...
```

**O que fazer:**
1. Ver qual categoria falhou
2. Ver seção [Troubleshooting](#troubleshooting)
3. Verificar quais migrations não foram executadas
4. Executar migrations faltantes
5. Validar novamente

---

### 📋 **Exemplos de Resultados**

#### Exemplo 1: Tudo OK ✅

```
Tabelas Novas       | 7/7       | ✅
Colunas empresa_id  | 9/9       | ✅
Planos Inseridos    | 4/4       | ✅
Funções Auxiliares  | 4/4       | ✅
Índices empresa_id  | 12/9+     | ✅
Foreign Keys        | 15/10+    | ✅

🎉 FASE 1 VALIDADA COM SUCESSO! Pronto para Fase 2!
```

**Ação:** ✅ Pode avançar para Fase 2!

---

#### Exemplo 2: Faltam Tabelas ❌

```
Tabelas Novas       | 5/7       | ❌
Colunas empresa_id  | 9/9       | ✅
Planos Inseridos    | 4/4       | ✅
...
```

**Problema:** Faltam 2 tabelas novas  
**Solução:** Verificar quais migrations do Grupo 1 (04-10) não foram executadas

---

#### Exemplo 3: Faltam Colunas empresa_id ❌

```
Tabelas Novas       | 7/7       | ✅
Colunas empresa_id  | 6/9       | ❌
Planos Inseridos    | 4/4       | ✅
...
```

**Problema:** Faltam 3 colunas `empresa_id`  
**Solução:** Verificar quais migrations do Grupo 2 (11-19) não foram executadas

---

#### Exemplo 4: Faltam Planos ❌

```
Tabelas Novas       | 7/7       | ✅
Colunas empresa_id  | 9/9       | ✅
Planos Inseridos    | 2/4       | ❌
...
```

**Problema:** Faltam 2 planos  
**Solução:** Migration 06 (`06_create_planos.sql`) não foi executada completamente ou teve erro

---

## 🔧 TROUBLESHOOTING

### Problema 1: Faltam Tabelas Novas

**Sintoma:** Validação mostra menos de 7 tabelas

**Solução:**
1. Verificar quais tabelas faltam:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'empresas', 'filiais', 'planos', 'usuarios_empresas', 
    'limites_uso', 'historico_assinaturas', 'convites_pendentes'
);
```

2. Verificar migrations do Grupo 1 (04-10):
   - `04_create_empresas.sql`
   - `05_create_filiais.sql`
   - `06_create_planos.sql`
   - `07_create_usuarios_empresas.sql`
   - `08_create_limites_uso.sql`
   - `09_create_historico_assinaturas.sql`
   - `10_create_convites_pendentes.sql`

3. Executar migrations faltantes na ordem correta

---

### Problema 2: Faltam Colunas empresa_id

**Sintoma:** Validação mostra menos de 9 colunas `empresa_id`

**Solução:**
1. Verificar quais tabelas não têm `empresa_id`:
```sql
SELECT table_name 
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name = 'empresa_id'
AND table_name IN (
    'usuarios', 'clientes', 'produtos', 'pedidos', 'estoque',
    'entregas', 'movimentacoes_estoque', 'transferencias_estoque', 'auditoria'
);
```

2. Verificar migrations do Grupo 2 (11-19):
   - `11_add_empresa_id_usuarios.sql`
   - `12_add_empresa_id_clientes.sql`
   - `13_add_empresa_id_produtos.sql`
   - `14_add_empresa_id_pedidos.sql`
   - `15_add_empresa_filial_estoque.sql`
   - `16_add_empresa_id_entregas.sql`
   - `17_add_empresa_id_movimentacoes.sql`
   - `18_add_empresa_id_transferencias.sql`
   - `19_add_empresa_id_auditoria.sql`

3. Executar migrations faltantes (ordem não importa para este grupo)

---

### Problema 3: Faltam Planos

**Sintoma:** Validação mostra menos de 4 planos

**Solução:**
1. Verificar se migration 06 foi executada:
```sql
SELECT COUNT(*) FROM public.planos;
```

2. Se retornar 0 ou menos de 4:
   - Re-executar `06_create_planos.sql`
   - Verificar se não houve erro na execução

3. Se retornar 4 mas validação falha:
   - Verificar se nomes estão corretos:
```sql
SELECT nome FROM public.planos ORDER BY ordem;
```
   - Deve retornar: Trial, Starter, Pro, Enterprise

---

### Problema 4: Faltam Funções Auxiliares

**Sintoma:** Validação mostra menos de 4 funções

**Solução:**
1. Verificar se migration 07 foi executada:
   - `07_create_usuarios_empresas.sql` cria as funções

2. Verificar funções existentes:
```sql
SELECT proname 
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_current_empresa_id',
    'get_user_filiais_acesso',
    'user_has_papel',
    'user_is_admin'
);
```

3. Se faltarem, re-executar migration 07

---

### Problema 5: Faltam Índices ou Foreign Keys

**Sintoma:** Validação mostra menos índices/FKs do que esperado

**Solução:**
1. Geralmente isso acontece se:
   - Migration foi executada parcialmente
   - Houve erro durante execução
   - Rollback foi feito

2. Verificar logs de execução no Supabase Dashboard

3. Re-executar migrations afetadas

4. Se persistir, verificar manualmente:
```sql
-- Ver índices
SELECT indexname, tablename 
FROM pg_indexes 
WHERE schemaname = 'public' 
AND indexname LIKE '%empresa_id%';

-- Ver foreign keys
SELECT tc.table_name, kcu.column_name, ccu.table_name AS referenced_table
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public';
```

---

## ✅ CHECKLIST DE VALIDAÇÃO

Use este checklist após executar as migrations:

- [ ] Executei todas as 16 migrations (04 a 19)
- [ ] Executei script de validação rápida
- [ ] Todas as validações mostraram ✅
- [ ] Executei script de validação completa
- [ ] Verifiquei detalhes de cada categoria
- [ ] Nenhum erro encontrado
- [ ] Resultado final: "🎉 FASE 1 VALIDADA COM SUCESSO!"

**Se todos os itens estão ✅:** Você está pronto para a Fase 2! 🚀

---

## 📝 PRÓXIMOS PASSOS

Após validar com sucesso:

1. ✅ **Atualizar CHECKLIST_PROGRESSO.md**
   - Marcar Fase 1 como 100% concluída
   - Atualizar status

2. ✅ **Atualizar CHANGELOG.md**
   - Documentar validação bem-sucedida
   - Anotar data/hora

3. ✅ **Iniciar Fase 2: RLS e Isolamento**
   - Criar funções auxiliares adicionais
   - Habilitar RLS em todas as tabelas
   - Criar policies de isolamento

---

## 🎯 RESUMO

**Script Recomendado:** `validar_fase1_simples.sql`  
**Quando Usar:** Após executar todas as 16 migrations  
**Tempo:** ~5 segundos  
**Resultado Esperado:** Todas as validações com ✅  

**Se tudo OK:** ✅ Pronto para Fase 2!  
**Se houver ❌:** Verificar seção Troubleshooting

---

**Última atualização:** 05/12/2025  
**Próxima validação:** Após executar migrations da Fase 2

