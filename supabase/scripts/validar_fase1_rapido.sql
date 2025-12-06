-- ================================================
-- VALIDAÇÃO RÁPIDA - FASE 1
-- Execute este script para uma verificação rápida
-- ================================================

-- Resumo rápido de todas as validações
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

-- Resultado final
SELECT 
    CASE 
        WHEN (
            (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('empresas', 'filiais', 'planos', 'usuarios_empresas', 'limites_uso', 'historico_assinaturas', 'convites_pendentes')) = 7
            AND (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'empresa_id' AND table_name IN ('usuarios', 'clientes', 'produtos', 'pedidos', 'estoque', 'entregas', 'movimentacoes_estoque', 'transferencias_estoque', 'auditoria')) = 9
            AND (SELECT COUNT(*) FROM public.planos) = 4
        )
        THEN '🎉 FASE 1 VALIDADA COM SUCESSO! Pronto para Fase 2!'
        ELSE '⚠️ FASE 1 INCOMPLETA. Verifique os resultados acima.'
    END AS resultado_final;

