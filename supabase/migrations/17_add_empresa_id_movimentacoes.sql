-- ================================================
-- MIGRATION 17: Adicionar empresa_id em MOVIMENTACOES_ESTOQUE
-- Data: 05/12/2025
-- Descrição: Adicionar coluna empresa_id para multi-tenancy
-- ================================================

-- Adicionar coluna empresa_id (permite NULL por enquanto)
ALTER TABLE public.movimentacoes_estoque
ADD COLUMN empresa_id UUID REFERENCES public.empresas(id);

-- Criar índice para performance
CREATE INDEX idx_movimentacoes_empresa_id 
ON public.movimentacoes_estoque(empresa_id) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para queries comuns (empresa + tipo)
CREATE INDEX idx_movimentacoes_empresa_tipo 
ON public.movimentacoes_estoque(empresa_id, tipo_movimento) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para busca por data
CREATE INDEX idx_movimentacoes_empresa_data 
ON public.movimentacoes_estoque(empresa_id, data_movimentacao DESC) 
WHERE empresa_id IS NOT NULL;

-- Adicionar comentário
COMMENT ON COLUMN public.movimentacoes_estoque.empresa_id IS 'Empresa à qual a movimentação pertence (multi-tenancy)';

-- ================================================
-- NOTA: O valor será populado posteriormente
-- Por enquanto, NULL é permitido para compatibilidade
-- ================================================

-- FIM DA MIGRATION



