-- ================================================
-- MIGRATION 19: Adicionar empresa_id em AUDITORIA
-- Data: 05/12/2025
-- Descrição: Adicionar coluna empresa_id para multi-tenancy
-- ================================================

-- Adicionar coluna empresa_id (permite NULL por enquanto)
ALTER TABLE public.auditoria
ADD COLUMN empresa_id UUID REFERENCES public.empresas(id);

-- Criar índice para performance
CREATE INDEX idx_auditoria_empresa_id 
ON public.auditoria(empresa_id) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para busca por data
CREATE INDEX idx_auditoria_empresa_data 
ON public.auditoria(empresa_id, data_acao DESC) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para busca por tabela
CREATE INDEX idx_auditoria_empresa_tabela 
ON public.auditoria(empresa_id, tabela) 
WHERE empresa_id IS NOT NULL;

-- Adicionar comentário
COMMENT ON COLUMN public.auditoria.empresa_id IS 'Empresa à qual o log de auditoria pertence (multi-tenancy)';

-- ================================================
-- NOTA: O valor será populado posteriormente
-- Por enquanto, NULL é permitido para compatibilidade
-- ================================================

-- FIM DA MIGRATION

