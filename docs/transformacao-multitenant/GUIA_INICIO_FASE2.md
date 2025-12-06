# 🔒 GUIA DE INÍCIO - FASE 2: RLS e Isolamento

> **Data:** 05/12/2025  
> **Fase:** Fase 2 - Row Level Security (RLS) e Isolamento  
> **Status:** ⏳ Pronto para iniciar  
> **Duração Prevista:** 2-3 semanas

---

## 📋 ÍNDICE

1. [Visão Geral](#visao-geral)
2. [O que é RLS?](#o-que-e-rls)
3. [Pré-requisitos](#pre-requisitos)
4. [Estrutura da Fase 2](#estrutura-da-fase-2)
5. [Passo a Passo](#passo-a-passo)
6. [Exemplos de Código](#exemplos-de-codigo)
7. [Testes de Isolamento](#testes-de-isolamento)
8. [Troubleshooting](#troubleshooting)

---

## 📊 VISÃO GERAL

A **Fase 2** é **CRÍTICA** para a segurança do sistema multi-tenant. Ela implementa o **Row Level Security (RLS)** que garante que:

✅ **Cada empresa vê APENAS seus próprios dados**  
✅ **Nenhuma empresa pode acessar dados de outra**  
✅ **Isolamento total a nível de banco de dados**  
✅ **Segurança mesmo se o frontend tiver bugs**  

### Objetivos da Fase 2

1. ✅ Habilitar RLS em **todas as tabelas**
2. ✅ Criar **policies** para cada tabela (SELECT, INSERT, UPDATE, DELETE)
3. ✅ Testar **isolamento completo** entre empresas
4. ✅ Validar que **nenhum vazamento** de dados é possível

---

## 🎓 O QUE É RLS?

### Row Level Security (RLS)

**RLS** é um recurso nativo do PostgreSQL que permite controlar quais linhas (rows) um usuário pode ver ou modificar, **baseado em condições definidas por você**.

### Como Funciona

```sql
-- SEM RLS: Usuário vê TODOS os dados
SELECT * FROM clientes;  -- Retorna clientes de TODAS as empresas

-- COM RLS: Usuário vê APENAS seus dados
SELECT * FROM clientes;  -- Retorna APENAS clientes da empresa do usuário
```

### Policies

**Policies** são as regras que definem o que cada usuário pode fazer:

```sql
-- Policy de SELECT: Usuário só vê clientes da sua empresa
CREATE POLICY "Usuários veem apenas clientes da sua empresa"
ON clientes FOR SELECT
USING (empresa_id = get_current_empresa_id());

-- Policy de INSERT: Usuário só pode criar clientes na sua empresa
CREATE POLICY "Usuários criam clientes apenas na sua empresa"
ON clientes FOR INSERT
WITH CHECK (empresa_id = get_current_empresa_id());
```

---

## ✅ PRÉ-REQUISITOS

Antes de iniciar a Fase 2, certifique-se de que:

- [x] ✅ **Fase 1 concluída** (todas as migrations executadas)
- [x] ✅ **Validação da Fase 1 passou** (scripts de validação executados)
- [x] ✅ **Funções auxiliares criadas** (já criadas na migration 07):
  - `get_current_empresa_id()`
  - `get_user_filiais_acesso()`
  - `user_has_papel()`
  - `user_is_admin()`
- [x] ✅ **Ambiente de teste configurado**
- [x] ✅ **Backup do banco feito**

---

## 📐 ESTRUTURA DA FASE 2

A Fase 2 está dividida em **3 semanas**:

### **Semana 1: Funções Auxiliares e Primeiras Policies**
- ✅ Funções auxiliares (já criadas)
- Habilitar RLS em todas as tabelas
- Criar policies básicas para `empresas`
- Testar policies

### **Semana 2: Policies para Todas as Tabelas**
- Criar policies para todas as tabelas:
  - `filiais`
  - `clientes`
  - `produtos`
  - `pedidos`
  - `estoque` (⚠️ especial: por filial!)
  - `entregas`
  - `movimentacoes_estoque`
  - `transferencias_estoque`
  - `auditoria`

### **Semana 3: Testes de Isolamento**
- Criar 3 empresas fake com dados diferentes
- Testar isolamento completo
- Validar que empresa A não vê empresa B
- Testes de performance

---

## 🚀 PASSO A PASSO

### **PASSO 1: Criar Migration para Habilitar RLS**

Criar arquivo: `supabase/migrations/20_enable_rls_all_tables.sql`

```sql
-- ================================================
-- MIGRATION 20: Habilitar RLS em Todas as Tabelas
-- Data: 05/12/2025
-- Descrição: Habilita Row Level Security em todas as tabelas
-- ================================================

-- IMPORTANTE: RLS deve ser habilitado ANTES de criar policies
-- Se habilitar RLS sem policies, nenhum dado será acessível!

-- Tabelas Novas Multi-Tenant
ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.filiais ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.planos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios_empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.limites_uso ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historico_assinaturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.convites_pendentes ENABLE ROW LEVEL SECURITY;

-- Tabelas Existentes com empresa_id
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entregas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transferencias_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria ENABLE ROW LEVEL SECURITY;

-- ================================================
-- NOTA IMPORTANTE
-- ================================================
-- Após habilitar RLS, você PRECISA criar policies
-- Caso contrário, nenhum dado será acessível!
-- 
-- Próximo passo: Criar policies (migration 21+)
-- ================================================
```

---

### **PASSO 2: Criar Primeira Policy (Tabela empresas)**

Criar arquivo: `supabase/migrations/21_create_policies_empresas.sql`

```sql
-- ================================================
-- MIGRATION 21: Policies para Tabela EMPRESAS
-- Data: 05/12/2025
-- Descrição: Cria policies RLS para tabela empresas
-- ================================================

-- Policy SELECT: Usuários veem apenas sua própria empresa
CREATE POLICY "empresas_select_own"
ON public.empresas
FOR SELECT
USING (
    id IN (
        SELECT empresa_id 
        FROM public.usuarios_empresas 
        WHERE usuario_id = auth.uid() 
        AND status = 'active' 
        AND deleted_at IS NULL
    )
);

-- Policy INSERT: Apenas service_role pode criar empresas
-- (Criação de empresa será feita via função especial)
CREATE POLICY "empresas_insert_service_role"
ON public.empresas
FOR INSERT
WITH CHECK (auth.role() = 'service_role');

-- Policy UPDATE: Usuários admin podem atualizar sua empresa
CREATE POLICY "empresas_update_admin"
ON public.empresas
FOR UPDATE
USING (
    id IN (
        SELECT empresa_id 
        FROM public.usuarios_empresas 
        WHERE usuario_id = auth.uid() 
        AND papel IN ('admin', 'super_admin')
        AND status = 'active' 
        AND deleted_at IS NULL
    )
);

-- Policy DELETE: Soft delete apenas para admins
CREATE POLICY "empresas_delete_admin"
ON public.empresas
FOR UPDATE  -- UPDATE porque é soft delete (deleted_at)
USING (
    id IN (
        SELECT empresa_id 
        FROM public.usuarios_empresas 
        WHERE usuario_id = auth.uid() 
        AND papel IN ('admin', 'super_admin')
        AND status = 'active' 
        AND deleted_at IS NULL
    )
);
```

---

### **PASSO 3: Testar Primeira Policy**

Após criar a migration 21, **teste imediatamente**:

```sql
-- 1. Verificar que RLS está habilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'empresas';
-- Deve retornar: rowsecurity = true

-- 2. Verificar policies criadas
SELECT schemaname, tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename = 'empresas';
-- Deve retornar 4 policies

-- 3. Testar SELECT (como usuário autenticado)
-- (Execute no contexto de um usuário autenticado)
SELECT * FROM empresas;
-- Deve retornar apenas a empresa do usuário logado
```

---

### **PASSO 4: Criar Policies para Outras Tabelas**

Seguir o mesmo padrão para todas as tabelas. Ver seção [Exemplos de Código](#exemplos-de-codigo) abaixo.

---

## 💻 EXEMPLOS DE CÓDIGO

### **Exemplo 1: Policies para Tabela CLIENTES**

```sql
-- ================================================
-- Policies para CLIENTES
-- ================================================

-- SELECT: Usuários veem apenas clientes da sua empresa
CREATE POLICY "clientes_select_own_empresa"
ON public.clientes
FOR SELECT
USING (
    empresa_id = get_current_empresa_id()
    AND deleted_at IS NULL  -- Soft delete
);

-- INSERT: Usuários criam clientes apenas na sua empresa
CREATE POLICY "clientes_insert_own_empresa"
ON public.clientes
FOR INSERT
WITH CHECK (
    empresa_id = get_current_empresa_id()
);

-- UPDATE: Usuários atualizam apenas clientes da sua empresa
CREATE POLICY "clientes_update_own_empresa"
ON public.clientes
FOR UPDATE
USING (
    empresa_id = get_current_empresa_id()
    AND deleted_at IS NULL
);

-- DELETE: Soft delete (UPDATE deleted_at)
CREATE POLICY "clientes_delete_own_empresa"
ON public.clientes
FOR UPDATE
USING (
    empresa_id = get_current_empresa_id()
    AND deleted_at IS NULL
);
```

---

### **Exemplo 2: Policies para Tabela ESTOQUE (Por Filial!)**

⚠️ **IMPORTANTE:** Estoque é especial porque precisa filtrar por **filial** também!

```sql
-- ================================================
-- Policies para ESTOQUE (Por Filial)
-- ================================================

-- SELECT: Usuários veem estoque apenas das filiais que têm acesso
CREATE POLICY "estoque_select_own_filial"
ON public.estoque
FOR SELECT
USING (
    empresa_id = get_current_empresa_id()
    AND (
        filial_id = ANY(get_user_filiais_acesso())
        OR get_user_filiais_acesso() IS NULL  -- NULL = acesso a todas
    )
);

-- INSERT: Usuários criam estoque apenas nas filiais com acesso
CREATE POLICY "estoque_insert_own_filial"
ON public.estoque
FOR INSERT
WITH CHECK (
    empresa_id = get_current_empresa_id()
    AND (
        filial_id = ANY(get_user_filiais_acesso())
        OR get_user_filiais_acesso() IS NULL
    )
);

-- UPDATE: Usuários atualizam estoque apenas das filiais com acesso
CREATE POLICY "estoque_update_own_filial"
ON public.estoque
FOR UPDATE
USING (
    empresa_id = get_current_empresa_id()
    AND (
        filial_id = ANY(get_user_filiais_acesso())
        OR get_user_filiais_acesso() IS NULL
    )
);

-- DELETE: Usuários deletam estoque apenas das filiais com acesso
CREATE POLICY "estoque_delete_own_filial"
ON public.estoque
FOR DELETE
USING (
    empresa_id = get_current_empresa_id()
    AND (
        filial_id = ANY(get_user_filiais_acesso())
        OR get_user_filiais_acesso() IS NULL
    )
);
```

---

### **Exemplo 3: Policies para Tabela PEDIDOS**

```sql
-- ================================================
-- Policies para PEDIDOS
-- ================================================

-- SELECT: Usuários veem apenas pedidos da sua empresa
CREATE POLICY "pedidos_select_own_empresa"
ON public.pedidos
FOR SELECT
USING (
    empresa_id = get_current_empresa_id()
);

-- INSERT: Usuários criam pedidos apenas na sua empresa
CREATE POLICY "pedidos_insert_own_empresa"
ON public.pedidos
FOR INSERT
WITH CHECK (
    empresa_id = get_current_empresa_id()
);

-- UPDATE: Usuários atualizam apenas pedidos da sua empresa
CREATE POLICY "pedidos_update_own_empresa"
ON public.pedidos
FOR UPDATE
USING (
    empresa_id = get_current_empresa_id()
);

-- DELETE: Apenas admins podem deletar pedidos
CREATE POLICY "pedidos_delete_admin"
ON public.pedidos
FOR DELETE
USING (
    empresa_id = get_current_empresa_id()
    AND user_is_admin(auth.uid(), empresa_id)
);
```

---

## 🧪 TESTES DE ISOLAMENTO

### **Teste Crítico: Empresa A não vê Empresa B**

Após criar todas as policies, você **DEVE** testar:

```sql
-- 1. Criar Empresa A
INSERT INTO empresas (nome, cnpj, email, status) 
VALUES ('Empresa A', '11.111.111/0001-11', 'empresaA@test.com', 'active')
RETURNING id;  -- Anotar o ID

-- 2. Criar Empresa B
INSERT INTO empresas (nome, cnpj, email, status) 
VALUES ('Empresa B', '22.222.222/0002-22', 'empresaB@test.com', 'active')
RETURNING id;  -- Anotar o ID

-- 3. Criar Cliente na Empresa A
INSERT INTO clientes (nome, empresa_id) 
VALUES ('Cliente A', '[ID_EMPRESA_A]');

-- 4. Criar Cliente na Empresa B
INSERT INTO clientes (nome, empresa_id) 
VALUES ('Cliente B', '[ID_EMPRESA_B]');

-- 5. Logar como usuário da Empresa A
-- 6. SELECT * FROM clientes;
--    Deve retornar APENAS "Cliente A"
--    NÃO deve retornar "Cliente B"

-- 7. Logar como usuário da Empresa B
-- 8. SELECT * FROM clientes;
--    Deve retornar APENAS "Cliente B"
--    NÃO deve retornar "Cliente A"
```

---

## 🔧 TROUBLESHOOTING

### Problema 1: "Nenhum dado retornado após habilitar RLS"

**Causa:** RLS habilitado mas nenhuma policy criada.

**Solução:**
1. Verificar se policies foram criadas:
```sql
SELECT * FROM pg_policies WHERE tablename = 'nome_tabela';
```

2. Se não houver policies, criar imediatamente.

3. Se houver policies, verificar se estão corretas.

---

### Problema 2: "Erro: função get_current_empresa_id() não existe"

**Causa:** Função não foi criada ou não está no schema correto.

**Solução:**
1. Verificar se função existe:
```sql
SELECT proname FROM pg_proc WHERE proname = 'get_current_empresa_id';
```

2. Se não existir, executar migration 07 novamente.

---

### Problema 3: "Usuário vê dados de outra empresa"

**Causa:** Policy incorreta ou função retornando valor errado.

**Solução:**
1. Verificar função `get_current_empresa_id()`:
```sql
SELECT get_current_empresa_id();
```

2. Verificar policy:
```sql
SELECT * FROM pg_policies WHERE tablename = 'nome_tabela';
```

3. Testar policy manualmente:
```sql
EXPLAIN SELECT * FROM clientes;
-- Verificar se a policy está sendo aplicada
```

---

## ✅ CHECKLIST DE INÍCIO

Antes de começar a Fase 2, verifique:

- [x] ✅ Fase 1 concluída e validada
- [x] ✅ Funções auxiliares criadas (migration 07)
- [x] ✅ Ambiente de teste configurado
- [x] ✅ Backup do banco feito
- [ ] Ler este guia completamente
- [ ] Entender conceito de RLS
- [ ] Preparar para criar migrations 20+

---

## 📝 PRÓXIMOS PASSOS

1. ✅ **Ler este guia completamente**
2. ✅ **Criar migration 20** (habilitar RLS)
3. ✅ **Criar migration 21** (policies para empresas)
4. ✅ **Testar primeira policy**
5. ✅ **Criar policies para outras tabelas**
6. ✅ **Testar isolamento completo**

---

## 🎯 RESUMO

**Fase 2 é CRÍTICA** para segurança. Não pule etapas!

- ✅ Habilitar RLS em todas as tabelas
- ✅ Criar policies para cada tabela
- ✅ Testar isolamento extensivamente
- ✅ Validar que nenhum vazamento é possível

**Tempo estimado:** 2-3 semanas  
**Dificuldade:** Média-Alta  
**Crítico:** ⚠️ SIM - Segurança do sistema depende disso!

---

**Última atualização:** 05/12/2025  
**Próxima fase:** Fase 3 - Autenticação Multi-Tenant

