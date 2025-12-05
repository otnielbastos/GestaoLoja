-- ================================================
-- MIGRATION 11: Adicionar empresa_id em USUARIOS
-- Data: 05/12/2025
-- Descrição: Adicionar coluna empresa_id para multi-tenancy
-- ================================================

-- Adicionar coluna empresa_id (permite NULL por enquanto)
ALTER TABLE public.usuarios
ADD COLUMN empresa_id UUID REFERENCES public.empresas(id);

-- Criar índice para performance
CREATE INDEX idx_usuarios_empresa_id 
ON public.usuarios(empresa_id) 
WHERE empresa_id IS NOT NULL;

-- Adicionar comentário
COMMENT ON COLUMN public.usuarios.empresa_id IS 'Empresa à qual o usuário pertence (multi-tenancy)';

-- ================================================
-- NOTA: O valor será populado posteriormente
-- Por enquanto, NULL é permitido para compatibilidade
-- ================================================

-- FIM DA MIGRATION

