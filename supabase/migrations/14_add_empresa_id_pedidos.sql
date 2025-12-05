-- ================================================
-- MIGRATION 14: Adicionar empresa_id em PEDIDOS
-- Data: 05/12/2025
-- Descrição: Adicionar coluna empresa_id para multi-tenancy
-- ================================================

-- Adicionar coluna empresa_id (permite NULL por enquanto)
ALTER TABLE public.pedidos
ADD COLUMN empresa_id UUID REFERENCES public.empresas(id);

-- Criar índice para performance
CREATE INDEX idx_pedidos_empresa_id 
ON public.pedidos(empresa_id) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para queries comuns (empresa + status)
CREATE INDEX idx_pedidos_empresa_status 
ON public.pedidos(empresa_id, status) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para busca por data
CREATE INDEX idx_pedidos_empresa_data 
ON public.pedidos(empresa_id, data_pedido DESC) 
WHERE empresa_id IS NOT NULL;

-- Índice composto para busca por tipo
CREATE INDEX idx_pedidos_empresa_tipo 
ON public.pedidos(empresa_id, tipo) 
WHERE empresa_id IS NOT NULL;

-- Adicionar comentário
COMMENT ON COLUMN public.pedidos.empresa_id IS 'Empresa à qual o pedido pertence (multi-tenancy)';

-- ================================================
-- NOTA: O valor será populado posteriormente
-- Por enquanto, NULL é permitido para compatibilidade
-- ================================================

-- FIM DA MIGRATION

