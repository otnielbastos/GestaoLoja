-- ================================================
-- SCRIPT DE VALIDAÇÃO SIMPLIFICADO - FASE 1
-- Para usar no Supabase Dashboard (SQL Editor)
-- ================================================

-- ================================================
-- VALIDAÇÃO 1: Tabelas Novas (7 tabelas)
-- ================================================

SELECT 
    'Tabelas Novas' AS validacao,
    COUNT(*) AS encontradas,
    7 AS esperadas,
    CASE WHEN COUNT(*) = 7 THEN '✅ SUCESSO' ELSE '❌ ERRO' END AS status
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
SELECT 
    table_name AS tabela,
    '✅' AS status
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
-- VALIDAÇÃO 2: Colunas empresa_id (9 tabelas)
-- ================================================

SELECT 
    'Colunas empresa_id' AS validacao,
    COUNT(*) AS encontradas,
    9 AS esperadas,
    CASE WHEN COUNT(*) = 9 THEN '✅ SUCESSO' ELSE '❌ ERRO' END AS status
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
SELECT 
    table_name AS tabela,
    data_type AS tipo,
    is_nullable AS permite_null,
    '✅' AS status
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

-- Verificar estoque (deve ter empresa_id E filial_id)
SELECT 
    'Estoque - empresa_id e filial_id' AS validacao,
    COUNT(*) AS colunas_encontradas,
    2 AS esperadas,
    CASE WHEN COUNT(*) = 2 THEN '✅ SUCESSO' ELSE '❌ ERRO' END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'estoque'
AND column_name IN ('empresa_id', 'filial_id');

-- ================================================
-- VALIDAÇÃO 3: Planos Inseridos (4 planos)
-- ================================================

SELECT 
    'Planos Inseridos' AS validacao,
    COUNT(*) AS encontrados,
    4 AS esperados,
    CASE WHEN COUNT(*) = 4 THEN '✅ SUCESSO' ELSE '❌ ERRO' END AS status
FROM public.planos;

-- Listar planos
SELECT 
    nome AS plano,
    preco_mensal AS preco,
    ordem,
    is_trial AS trial,
    is_default AS padrao,
    status,
    CASE 
        WHEN nome IN ('Trial', 'Starter', 'Pro', 'Enterprise') THEN '✅'
        ELSE '❌'
    END AS status_validacao
FROM public.planos
ORDER BY ordem;

-- ================================================
-- VALIDAÇÃO 4: Funções Auxiliares (4 funções)
-- ================================================

SELECT 
    'Funções Auxiliares' AS validacao,
    COUNT(*) AS encontradas,
    4 AS esperadas,
    CASE WHEN COUNT(*) >= 4 THEN '✅ SUCESSO' ELSE '❌ ERRO' END AS status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_current_empresa_id',
    'get_user_filiais_acesso',
    'user_has_papel',
    'user_is_admin'
);

-- Listar funções
SELECT 
    p.proname AS funcao,
    pg_get_function_arguments(p.oid) AS argumentos,
    '✅' AS status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_current_empresa_id',
    'get_user_filiais_acesso',
    'user_has_papel',
    'user_is_admin'
)
ORDER BY p.proname;

-- ================================================
-- VALIDAÇÃO 5: Índices em empresa_id
-- ================================================

SELECT 
    'Índices empresa_id' AS validacao,
    COUNT(*) AS encontrados,
    9 AS esperados_minimo,
    CASE WHEN COUNT(*) >= 9 THEN '✅ SUCESSO' ELSE '❌ ERRO' END AS status
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%empresa_id%';

-- Listar índices
SELECT 
    tablename AS tabela,
    indexname AS indice,
    '✅' AS status
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%empresa_id%'
ORDER BY tablename, indexname;

-- ================================================
-- VALIDAÇÃO 6: Foreign Keys
-- ================================================

SELECT 
    'Foreign Keys' AS validacao,
    COUNT(DISTINCT tc.constraint_name) AS encontradas,
    10 AS esperadas_minimo,
    CASE WHEN COUNT(DISTINCT tc.constraint_name) >= 10 THEN '✅ SUCESSO' ELSE '❌ ERRO' END AS status
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

-- Listar foreign keys
SELECT 
    tc.table_name AS tabela_origem,
    kcu.column_name AS coluna,
    ccu.table_name AS tabela_destino,
    '✅' AS status
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
    kcu.column_name = 'plano_id'
)
ORDER BY tc.table_name, kcu.column_name;

-- ================================================
-- RESUMO FINAL CONSOLIDADO
-- ================================================

SELECT 
    '═══════════════════════════════════════' AS separador;

SELECT 
    'RESUMO FINAL DA VALIDAÇÃO' AS titulo;

SELECT 
    '═══════════════════════════════════════' AS separador;

-- Resumo consolidado
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

SELECT 
    '═══════════════════════════════════════' AS separador;

SELECT 
    CASE 
        WHEN (
            (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('empresas', 'filiais', 'planos', 'usuarios_empresas', 'limites_uso', 'historico_assinaturas', 'convites_pendentes')) = 7
            AND (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'empresa_id' AND table_name IN ('usuarios', 'clientes', 'produtos', 'pedidos', 'estoque', 'entregas', 'movimentacoes_estoque', 'transferencias_estoque', 'auditoria')) = 9
            AND (SELECT COUNT(*) FROM public.planos) = 4
        )
        THEN '🎉 TODAS AS VALIDAÇÕES PASSARAM! Você está pronto para a Fase 2!'
        ELSE '⚠️ ALGUMAS VALIDAÇÕES FALHARAM. Verifique os resultados acima.'
    END AS resultado_final;

