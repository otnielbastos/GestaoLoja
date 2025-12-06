-- ================================================
-- MIGRATION 18: Adicionar empresa_id em TRANSFERENCIAS_ESTOQUE
-- Data: 05/12/2025
-- Descrição: Adicionar coluna empresa_id para multi-tenancy
-- ================================================

-- Adicionar coluna empresa_id (permite NULL por enquanto)
ALTER TABLE public.transferencias_estoque
ADD COLUMN empresa_id UUID REFERENCES public.empresas(id);

-- Criar índice para performance
CREATE INDEX idx_transferencias_empresa_id 
ON public.transferencias_estoque(empresa_id) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para busca por data
CREATE INDEX idx_transferencias_empresa_data 
ON public.transferencias_estoque(empresa_id, data_transferencia DESC) 
WHERE empresa_id IS NOT NULL;

-- Adicionar comentário
COMMENT ON COLUMN public.transferencias_estoque.empresa_id IS 'Empresa à qual a transferência pertence (multi-tenancy)';

-- ================================================
-- NOTA IMPORTANTE:
-- - Transferências sempre ocorrem DENTRO da mesma empresa
-- - Não permitir transferências entre empresas diferentes
-- - Filtrar SEMPRE por empresa_id
-- ================================================

-- FIM DA MIGRATION



