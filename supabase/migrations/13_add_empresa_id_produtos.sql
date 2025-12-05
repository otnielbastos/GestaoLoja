-- ================================================
-- MIGRATION 13: Adicionar empresa_id em PRODUTOS
-- Data: 05/12/2025
-- Descrição: Adicionar coluna empresa_id para multi-tenancy
-- ================================================

-- Adicionar coluna empresa_id (permite NULL por enquanto)
ALTER TABLE public.produtos
ADD COLUMN empresa_id UUID REFERENCES public.empresas(id);

-- Criar índice para performance
CREATE INDEX idx_produtos_empresa_id 
ON public.produtos(empresa_id) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para queries comuns (empresa + status)
CREATE INDEX idx_produtos_empresa_status 
ON public.produtos(empresa_id, status) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para busca por categoria
CREATE INDEX idx_produtos_empresa_categoria 
ON public.produtos(empresa_id, categoria) 
WHERE empresa_id IS NOT NULL;

-- Adicionar comentário
COMMENT ON COLUMN public.produtos.empresa_id IS 'Empresa à qual o produto pertence (multi-tenancy)';

-- ================================================
-- NOTA: O valor será populado posteriormente
-- Por enquanto, NULL é permitido para compatibilidade
-- ================================================

-- FIM DA MIGRATION

