-- ================================================
-- SCRIPT DE VALIDAÇÃO - FASE 1: BANCO DE DADOS MULTI-TENANT
-- Data: 05/12/2025
-- Descrição: Validação completa da estrutura multi-tenant
-- ================================================

-- ================================================
-- CONFIGURAÇÃO
-- ================================================

-- Este script valida se todas as migrations da Fase 1 foram executadas corretamente
-- Execute este script APÓS executar todas as 16 migrations (04 a 19)

-- ================================================
-- SEÇÃO 1: VALIDAR TABELAS NOVAS (7 tabelas)
-- ================================================

\echo '========================================'
\echo 'SEÇÃO 1: Validando Tabelas Novas'
\echo '========================================'

-- Verificar se todas as 7 tabelas novas foram criadas
SELECT 
    CASE 
        WHEN COUNT(*) = 7 THEN '✅ SUCESSO: Todas as 7 tabelas novas foram criadas'
        ELSE '❌ ERRO: Faltam tabelas. Esperado: 7, Encontrado: ' || COUNT(*)::text
    END AS status_validacao
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
);

-- Listar tabelas encontradas
\echo ''
\echo 'Tabelas encontradas:'
SELECT 
    table_name AS tabela,
    CASE 
        WHEN table_name IN ('empresas', 'filiais', 'planos', 'usuarios_empresas', 
                           'limites_uso', 'historico_assinaturas', 'convites_pendentes')
        THEN '✅'
        ELSE '❌'
    END AS status
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

-- ================================================
-- SEÇÃO 2: VALIDAR COLUNAS empresa_id (9 tabelas)
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 2: Validando Colunas empresa_id'
\echo '========================================'

-- Verificar se todas as 9 tabelas têm empresa_id
SELECT 
    CASE 
        WHEN COUNT(*) = 9 THEN '✅ SUCESSO: Todas as 9 tabelas têm empresa_id'
        ELSE '❌ ERRO: Faltam colunas empresa_id. Esperado: 9, Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name = 'empresa_id'
AND table_name IN (
    'usuarios',
    'clientes',
    'produtos',
    'pedidos',
    'estoque',
    'entregas',
    'movimentacoes_estoque',
    'transferencias_estoque',
    'auditoria'
);

-- Listar tabelas com empresa_id
\echo ''
\echo 'Tabelas com empresa_id:'
SELECT 
    table_name AS tabela,
    data_type AS tipo_dado,
    is_nullable AS permite_null,
    CASE 
        WHEN table_name IN ('usuarios', 'clientes', 'produtos', 'pedidos', 
                           'estoque', 'entregas', 'movimentacoes_estoque', 
                           'transferencias_estoque', 'auditoria')
        THEN '✅'
        ELSE '❌'
    END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name = 'empresa_id'
AND table_name IN (
    'usuarios',
    'clientes',
    'produtos',
    'pedidos',
    'estoque',
    'entregas',
    'movimentacoes_estoque',
    'transferencias_estoque',
    'auditoria'
)
ORDER BY table_name;

-- Verificar se estoque tem filial_id também
\echo ''
\echo 'Verificando estoque (deve ter empresa_id E filial_id):'
SELECT 
    table_name AS tabela,
    column_name AS coluna,
    data_type AS tipo_dado
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'estoque'
AND column_name IN ('empresa_id', 'filial_id')
ORDER BY column_name;

-- ================================================
-- SEÇÃO 3: VALIDAR PLANOS INSERIDOS (4 planos)
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 3: Validando Planos Inseridos'
\echo '========================================'

-- Verificar se 4 planos foram inseridos
SELECT 
    CASE 
        WHEN COUNT(*) = 4 THEN '✅ SUCESSO: 4 planos foram inseridos'
        ELSE '❌ ERRO: Planos faltando. Esperado: 4, Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM public.planos;

-- Listar planos inseridos
\echo ''
\echo 'Planos encontrados:'
SELECT 
    nome AS plano,
    preco_mensal AS preco_mensal,
    ordem AS ordem,
    is_trial AS eh_trial,
    is_default AS eh_padrao,
    status AS status,
    CASE 
        WHEN nome IN ('Trial', 'Starter', 'Pro', 'Enterprise') THEN '✅'
        ELSE '❌'
    END AS status_validacao
FROM public.planos
ORDER BY ordem;

-- Verificar valores esperados dos planos
\echo ''
\echo 'Validação detalhada dos planos:'
SELECT 
    nome AS plano,
    CASE 
        WHEN nome = 'Trial' AND preco_mensal = 0.00 AND is_trial = true THEN '✅'
        WHEN nome = 'Starter' AND preco_mensal = 79.90 THEN '✅'
        WHEN nome = 'Pro' AND preco_mensal = 149.90 THEN '✅'
        WHEN nome = 'Enterprise' AND preco_mensal = 299.90 THEN '✅'
        ELSE '❌'
    END AS validacao_preco,
    CASE 
        WHEN ordem = 0 AND nome = 'Trial' THEN '✅'
        WHEN ordem = 1 AND nome = 'Starter' THEN '✅'
        WHEN ordem = 2 AND nome = 'Pro' THEN '✅'
        WHEN ordem = 3 AND nome = 'Enterprise' THEN '✅'
        ELSE '❌'
    END AS validacao_ordem
FROM public.planos
ORDER BY ordem;

-- ================================================
-- SEÇÃO 4: VALIDAR ÍNDICES
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 4: Validando Índices'
\echo '========================================'

-- Verificar índices em empresa_id (deve ter pelo menos 9)
SELECT 
    CASE 
        WHEN COUNT(*) >= 9 THEN '✅ SUCESSO: Índices em empresa_id criados (' || COUNT(*)::text || ' encontrados)'
        ELSE '❌ ERRO: Faltam índices. Esperado: 9+, Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%empresa_id%';

-- Listar índices relacionados a multi-tenancy
\echo ''
\echo 'Índices relacionados a multi-tenancy:'
SELECT 
    tablename AS tabela,
    indexname AS indice,
    CASE 
        WHEN indexname LIKE '%empresa_id%' OR 
             indexname LIKE '%filial_id%' OR
             indexname LIKE '%empresas%' OR
             indexname LIKE '%planos%' OR
             indexname LIKE '%usuarios_empresas%'
        THEN '✅'
        ELSE '⚠️'
    END AS status
FROM pg_indexes
WHERE schemaname = 'public'
AND (
    indexname LIKE '%empresa_id%' OR 
    indexname LIKE '%filial_id%' OR
    indexname LIKE '%empresas%' OR
    indexname LIKE '%planos%' OR
    indexname LIKE '%usuarios_empresas%'
)
ORDER BY tablename, indexname;

-- ================================================
-- SEÇÃO 5: VALIDAR FOREIGN KEYS
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 5: Validando Foreign Keys'
\echo '========================================'

-- Verificar foreign keys relacionadas a empresas
SELECT 
    CASE 
        WHEN COUNT(*) >= 10 THEN '✅ SUCESSO: Foreign keys criadas (' || COUNT(*)::text || ' encontradas)'
        ELSE '❌ ERRO: Faltam foreign keys. Esperado: 10+, Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public'
AND (
    kcu.column_name = 'empresa_id' OR
    kcu.column_name = 'filial_id' OR
    kcu.column_name = 'plano_id' OR
    tc.constraint_name LIKE '%empresa%' OR
    tc.constraint_name LIKE '%filial%' OR
    tc.constraint_name LIKE '%plano%'
);

-- Listar foreign keys
\echo ''
\echo 'Foreign keys encontradas:'
SELECT 
    tc.table_name AS tabela_origem,
    kcu.column_name AS coluna,
    ccu.table_name AS tabela_destino,
    ccu.column_name AS coluna_destino,
    tc.constraint_name AS constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public'
AND (
    kcu.column_name = 'empresa_id' OR
    kcu.column_name = 'filial_id' OR
    kcu.column_name = 'plano_id' OR
    tc.constraint_name LIKE '%empresa%' OR
    tc.constraint_name LIKE '%filial%' OR
    tc.constraint_name LIKE '%plano%'
)
ORDER BY tc.table_name, kcu.column_name;

-- ================================================
-- SEÇÃO 6: VALIDAR FUNÇÕES AUXILIARES
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 6: Validando Funções Auxiliares'
\echo '========================================'

-- Verificar funções auxiliares criadas
SELECT 
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ SUCESSO: Funções auxiliares criadas (' || COUNT(*)::text || ' encontradas)'
        ELSE '❌ ERRO: Faltam funções. Esperado: 4+, Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_current_empresa_id',
    'get_user_filiais_acesso',
    'user_has_papel',
    'user_is_admin'
);

-- Listar funções auxiliares
\echo ''
\echo 'Funções auxiliares encontradas:'
SELECT 
    p.proname AS nome_funcao,
    pg_get_function_arguments(p.oid) AS argumentos,
    CASE 
        WHEN p.proname IN ('get_current_empresa_id', 'get_user_filiais_acesso', 
                          'user_has_papel', 'user_is_admin')
        THEN '✅'
        ELSE '⚠️'
    END AS status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_current_empresa_id',
    'get_user_filiais_acesso',
    'user_has_papel',
    'user_is_admin',
    'update_updated_at_column'
)
ORDER BY p.proname;

-- ================================================
-- SEÇÃO 7: VALIDAR TRIGGERS
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 7: Validando Triggers'
\echo '========================================'

-- Verificar triggers criados
SELECT 
    CASE 
        WHEN COUNT(*) >= 5 THEN '✅ SUCESSO: Triggers criados (' || COUNT(*)::text || ' encontrados)'
        ELSE '⚠️ AVISO: Alguns triggers podem estar faltando. Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
AND t.tgname LIKE '%updated_at%'
AND NOT t.tgisinternal;

-- Listar triggers
\echo ''
\echo 'Triggers encontrados:'
SELECT 
    c.relname AS tabela,
    t.tgname AS trigger_name,
    CASE 
        WHEN t.tgname LIKE '%updated_at%' THEN '✅'
        ELSE '⚠️'
    END AS status
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
AND NOT t.tgisinternal
AND (
    t.tgname LIKE '%updated_at%' OR
    c.relname IN ('empresas', 'filiais', 'planos', 'usuarios_empresas', 
                  'limites_uso', 'historico_assinaturas', 'convites_pendentes')
)
ORDER BY c.relname, t.tgname;

-- ================================================
-- SEÇÃO 8: VALIDAR CONSTRAINTS
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 8: Validando Constraints'
\echo '========================================'

-- Verificar constraints de validação
SELECT 
    CASE 
        WHEN COUNT(*) >= 5 THEN '✅ SUCESSO: Constraints criadas (' || COUNT(*)::text || ' encontradas)'
        ELSE '⚠️ AVISO: Algumas constraints podem estar faltando. Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM information_schema.table_constraints
WHERE constraint_schema = 'public'
AND constraint_type = 'CHECK'
AND (
    constraint_name LIKE '%status%' OR
    constraint_name LIKE '%plano%' OR
    constraint_name LIKE '%empresa%'
);

-- Listar constraints importantes
\echo ''
\echo 'Constraints encontradas:'
SELECT 
    tc.table_name AS tabela,
    tc.constraint_name AS constraint_name,
    tc.constraint_type AS tipo,
    CASE 
        WHEN tc.constraint_name LIKE '%status%' OR
             tc.constraint_name LIKE '%plano%' OR
             tc.constraint_name LIKE '%empresa%'
        THEN '✅'
        ELSE '⚠️'
    END AS status
FROM information_schema.table_constraints tc
WHERE tc.constraint_schema = 'public'
AND tc.constraint_type = 'CHECK'
AND (
    tc.constraint_name LIKE '%status%' OR
    tc.constraint_name LIKE '%plano%' OR
    tc.constraint_name LIKE '%empresa%'
)
ORDER BY tc.table_name, tc.constraint_name;

-- ================================================
-- SEÇÃO 9: VALIDAR PERMISSÕES
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 9: Validando Permissões'
\echo '========================================'

-- Verificar permissões em tabelas principais
SELECT 
    CASE 
        WHEN COUNT(*) >= 7 THEN '✅ SUCESSO: Permissões configuradas (' || COUNT(*)::text || ' tabelas)'
        ELSE '⚠️ AVISO: Verifique permissões manualmente. Encontrado: ' || COUNT(*)::text
    END AS status_validacao
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND grantee IN ('authenticated', 'service_role')
AND table_name IN (
    'empresas',
    'filiais',
    'planos',
    'usuarios_empresas',
    'limites_uso',
    'historico_assinaturas',
    'convites_pendentes'
);

-- ================================================
-- SEÇÃO 10: VALIDAÇÃO ESTRUTURAL DETALHADA
-- ================================================

\echo ''
\echo '========================================'
\echo 'SEÇÃO 10: Validação Estrutural Detalhada'
\echo '========================================'

-- Verificar estrutura da tabela empresas
\echo ''
\echo 'Estrutura da tabela empresas:'
SELECT 
    column_name AS coluna,
    data_type AS tipo,
    is_nullable AS nullable,
    column_default AS default_value
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'empresas'
ORDER BY ordinal_position;

-- Verificar estrutura da tabela filiais
\echo ''
\echo 'Estrutura da tabela filiais:'
SELECT 
    column_name AS coluna,
    data_type AS tipo,
    is_nullable AS nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'filiais'
ORDER BY ordinal_position
LIMIT 10; -- Limitar para não ficar muito longo

-- Verificar estrutura da tabela usuarios_empresas
\echo ''
\echo 'Estrutura da tabela usuarios_empresas:'
SELECT 
    column_name AS coluna,
    data_type AS tipo,
    is_nullable AS nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'usuarios_empresas'
ORDER BY ordinal_position;

-- ================================================
-- SEÇÃO 11: RESUMO FINAL
-- ================================================

\echo ''
\echo '========================================'
\echo 'RESUMO FINAL DA VALIDAÇÃO'
\echo '========================================'

-- Criar resumo consolidado
SELECT 
    'Tabelas Novas' AS categoria,
    COUNT(*)::text || '/7' AS resultado,
    CASE WHEN COUNT(*) = 7 THEN '✅' ELSE '❌' END AS status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'empresas', 'filiais', 'planos', 'usuarios_empresas', 
    'limites_uso', 'historico_assinaturas', 'convites_pendentes'
)

UNION ALL

SELECT 
    'Colunas empresa_id' AS categoria,
    COUNT(*)::text || '/9' AS resultado,
    CASE WHEN COUNT(*) = 9 THEN '✅' ELSE '❌' END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name = 'empresa_id'
AND table_name IN (
    'usuarios', 'clientes', 'produtos', 'pedidos', 'estoque',
    'entregas', 'movimentacoes_estoque', 'transferencias_estoque', 'auditoria'
)

UNION ALL

SELECT 
    'Planos Inseridos' AS categoria,
    COUNT(*)::text || '/4' AS resultado,
    CASE WHEN COUNT(*) = 4 THEN '✅' ELSE '❌' END AS status
FROM public.planos

UNION ALL

SELECT 
    'Funções Auxiliares' AS categoria,
    COUNT(*)::text || '/4' AS resultado,
    CASE WHEN COUNT(*) >= 4 THEN '✅' ELSE '❌' END AS status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_current_empresa_id', 'get_user_filiais_acesso', 
    'user_has_papel', 'user_is_admin'
)

UNION ALL

SELECT 
    'Índices empresa_id' AS categoria,
    COUNT(*)::text || '/9+' AS resultado,
    CASE WHEN COUNT(*) >= 9 THEN '✅' ELSE '❌' END AS status
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%empresa_id%'

UNION ALL

SELECT 
    'Foreign Keys' AS categoria,
    COUNT(DISTINCT tc.constraint_name)::text || '/10+' AS resultado,
    CASE WHEN COUNT(DISTINCT tc.constraint_name) >= 10 THEN '✅' ELSE '❌' END AS status
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public'
AND (
    kcu.column_name = 'empresa_id' OR
    kcu.column_name = 'filial_id' OR
    kcu.column_name = 'plano_id'
);

-- ================================================
-- FIM DO SCRIPT DE VALIDAÇÃO
-- ================================================

\echo ''
\echo '========================================'
\echo 'Validação concluída!'
\echo '========================================'
\echo ''
\echo 'Se todas as validações mostraram ✅, você está pronto para a Fase 2!'
\echo 'Se houver ❌, verifique quais migrations faltam executar.'
\echo ''

