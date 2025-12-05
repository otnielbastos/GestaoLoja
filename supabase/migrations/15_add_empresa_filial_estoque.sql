-- ================================================
-- MIGRATION 15: Adicionar empresa_id e filial_id em ESTOQUE
-- Data: 05/12/2025
-- Descrição: Adicionar colunas empresa_id e filial_id para multi-tenancy
--            O estoque é POR FILIAL (isolamento por filial)
-- ================================================

-- Adicionar coluna empresa_id (permite NULL por enquanto)
ALTER TABLE public.estoque
ADD COLUMN empresa_id UUID REFERENCES public.empresas(id);

-- Adicionar coluna filial_id (permite NULL por enquanto)
ALTER TABLE public.estoque
ADD COLUMN filial_id UUID REFERENCES public.filiais(id);

-- Criar índice para performance (empresa)
CREATE INDEX idx_estoque_empresa_id 
ON public.estoque(empresa_id) 
WHERE empresa_id IS NOT NULL;

-- Criar índice para performance (filial) - MAIS IMPORTANTE
CREATE INDEX idx_estoque_filial_id 
ON public.estoque(filial_id) 
WHERE filial_id IS NOT NULL;

-- Índice composto para queries comuns (empresa + filial + produto)
CREATE INDEX idx_estoque_empresa_filial_produto 
ON public.estoque(empresa_id, filial_id, produto_id) 
WHERE empresa_id IS NOT NULL;

-- Nota: Não há coluna tipo_estoque
-- O estoque diferencia pronta_entrega vs encomenda através das colunas:
-- quantidade_pronta_entrega e quantidade_encomenda

-- Adicionar comentários
COMMENT ON COLUMN public.estoque.empresa_id IS 'Empresa à qual o estoque pertence (multi-tenancy)';
COMMENT ON COLUMN public.estoque.filial_id IS 'Filial específica onde o estoque está armazenado';

-- ================================================
-- NOTA IMPORTANTE:
-- - Estoque é isolado POR FILIAL
-- - Uma empresa com múltiplas filiais terá estoque separado em cada
-- - Filtrar SEMPRE por filial_id ao mostrar estoque
-- - empresa_id serve para queries de agregação total
-- ================================================

-- FIM DA MIGRATION

