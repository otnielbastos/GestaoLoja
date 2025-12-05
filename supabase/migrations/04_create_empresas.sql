-- ================================================
-- MIGRATION 04: Criar Tabela EMPRESAS
-- Data: 05/12/2025
-- Descrição: Tabela principal para multi-tenancy
-- ================================================

-- Tabela: empresas
CREATE TABLE IF NOT EXISTS public.empresas (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Dados da Empresa
    nome VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    razao_social VARCHAR(255),
    cnpj VARCHAR(18) UNIQUE NOT NULL, -- Format: 00.000.000/0000-00
    
    -- Endereço
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2), -- UF: SP, RJ, etc
    cep VARCHAR(9), -- Format: 00000-000
    
    -- Contato
    telefone VARCHAR(20),
    email VARCHAR(255) NOT NULL,
    website VARCHAR(255),
    
    -- Plano e Status
    plano_id UUID, -- Foreign key será adicionada depois que criar tabela planos
    status VARCHAR(20) NOT NULL DEFAULT 'trial', -- trial, active, suspended, cancelled
    
    -- Datas de Assinatura
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_inicio_plano TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_fim_trial TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '14 days'), -- Trial de 14 dias
    data_renovacao TIMESTAMP WITH TIME ZONE, -- Próxima data de cobrança
    data_cancelamento TIMESTAMP WITH TIME ZONE,
    
    -- Configurações
    configuracoes JSONB DEFAULT '{}'::jsonb, -- Configurações personalizadas
    
    -- Marca d'água (se ativo ou não)
    marca_dagua_ativa BOOLEAN DEFAULT true, -- Remove marca d'água em planos pagos
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE -- Soft delete
);

-- ================================================
-- ÍNDICES
-- ================================================

-- Índice para busca por CNPJ (único e rápido)
CREATE UNIQUE INDEX idx_empresas_cnpj ON public.empresas(cnpj) WHERE deleted_at IS NULL;

-- Índice para busca por email
CREATE INDEX idx_empresas_email ON public.empresas(email) WHERE deleted_at IS NULL;

-- Índice para filtrar por status
CREATE INDEX idx_empresas_status ON public.empresas(status) WHERE deleted_at IS NULL;

-- Índice para filtrar por plano
CREATE INDEX idx_empresas_plano_id ON public.empresas(plano_id) WHERE deleted_at IS NULL;

-- Índice para busca por nome (case-insensitive)
CREATE INDEX idx_empresas_nome_lower ON public.empresas(LOWER(nome)) WHERE deleted_at IS NULL;

-- Índice para empresas ativas (não deletadas)
CREATE INDEX idx_empresas_active ON public.empresas(id) WHERE deleted_at IS NULL;

-- ================================================
-- TRIGGER: updated_at automático
-- ================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_empresas
    BEFORE UPDATE ON public.empresas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- COMENTÁRIOS (Documentação)
-- ================================================

COMMENT ON TABLE public.empresas IS 'Tabela principal de empresas (tenants) do sistema multi-tenant';
COMMENT ON COLUMN public.empresas.id IS 'ID único da empresa (UUID)';
COMMENT ON COLUMN public.empresas.cnpj IS 'CNPJ da empresa (único no sistema)';
COMMENT ON COLUMN public.empresas.status IS 'Status da assinatura: trial, active, suspended, cancelled';
COMMENT ON COLUMN public.empresas.data_fim_trial IS 'Data em que o período trial expira (14 dias)';
COMMENT ON COLUMN public.empresas.plano_id IS 'Plano atual da empresa (FK para tabela planos)';
COMMENT ON COLUMN public.empresas.configuracoes IS 'Configurações personalizadas da empresa em JSON';
COMMENT ON COLUMN public.empresas.deleted_at IS 'Data de exclusão (soft delete - NULL = ativo)';

-- ================================================
-- GRANT PERMISSIONS
-- ================================================

-- Service role tem acesso total
GRANT ALL ON public.empresas TO service_role;

-- Authenticated users terão acesso via RLS (será configurado na Fase 2)
GRANT SELECT, INSERT, UPDATE ON public.empresas TO authenticated;

-- ================================================
-- CONSTRAINT: Validação de Status
-- ================================================

ALTER TABLE public.empresas
ADD CONSTRAINT check_empresa_status 
CHECK (status IN ('trial', 'active', 'suspended', 'cancelled'));

-- ================================================
-- CONSTRAINT: Validação de UF (Estado)
-- ================================================

ALTER TABLE public.empresas
ADD CONSTRAINT check_empresa_estado
CHECK (
    estado IS NULL OR
    estado IN (
        'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
        'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
        'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    )
);

-- ================================================
-- FIM DA MIGRATION
-- ================================================

