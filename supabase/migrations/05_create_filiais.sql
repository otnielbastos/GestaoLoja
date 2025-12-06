-- ================================================
-- MIGRATION 05: Criar Tabela FILIAIS
-- Data: 05/12/2025
-- Descrição: Tabela para filiais/lojas de cada empresa
-- ================================================

-- Tabela: filiais
CREATE TABLE IF NOT EXISTS public.filiais (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
    
    -- Dados da Filial
    nome VARCHAR(255) NOT NULL,
    codigo VARCHAR(50), -- Código interno da filial (ex: "LOJA01", "MATRIZ")
    
    -- Tipo
    tipo VARCHAR(20) NOT NULL DEFAULT 'filial', -- matriz, filial, loja, deposito
    is_matriz BOOLEAN DEFAULT false, -- Flag para identificar matriz rapidamente
    
    -- Endereço
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    cep VARCHAR(9),
    
    -- Contato
    telefone VARCHAR(20),
    email VARCHAR(255),
    
    -- Responsável
    responsavel_nome VARCHAR(255),
    responsavel_telefone VARCHAR(20),
    responsavel_email VARCHAR(255),
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, inactive, closed
    
    -- Configurações
    configuracoes JSONB DEFAULT '{}'::jsonb,
    
    -- Horários de Funcionamento (JSON)
    horarios_funcionamento JSONB DEFAULT '{
        "segunda": {"abertura": "08:00", "fechamento": "18:00", "ativo": true},
        "terca": {"abertura": "08:00", "fechamento": "18:00", "ativo": true},
        "quarta": {"abertura": "08:00", "fechamento": "18:00", "ativo": true},
        "quinta": {"abertura": "08:00", "fechamento": "18:00", "ativo": true},
        "sexta": {"abertura": "08:00", "fechamento": "18:00", "ativo": true},
        "sabado": {"abertura": "08:00", "fechamento": "12:00", "ativo": true},
        "domingo": {"abertura": null, "fechamento": null, "ativo": false}
    }'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE -- Soft delete
);

-- ================================================
-- ÍNDICES
-- ================================================

-- Índice para buscar filiais de uma empresa (mais comum)
CREATE INDEX idx_filiais_empresa_id ON public.filiais(empresa_id) WHERE deleted_at IS NULL;

-- Índice composto empresa + status (queries filtradas)
CREATE INDEX idx_filiais_empresa_status ON public.filiais(empresa_id, status) WHERE deleted_at IS NULL;

-- Índice para encontrar matriz rapidamente
CREATE INDEX idx_filiais_matriz ON public.filiais(empresa_id, is_matriz) WHERE is_matriz = true AND deleted_at IS NULL;

-- Índice para busca por código
CREATE INDEX idx_filiais_codigo ON public.filiais(empresa_id, codigo) WHERE deleted_at IS NULL;

-- Índice para busca por cidade/estado
CREATE INDEX idx_filiais_localizacao ON public.filiais(estado, cidade) WHERE deleted_at IS NULL;

-- ================================================
-- TRIGGER: updated_at automático
-- ================================================

CREATE TRIGGER set_updated_at_filiais
    BEFORE UPDATE ON public.filiais
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- TRIGGER: Garantir apenas uma matriz por empresa
-- ================================================

CREATE OR REPLACE FUNCTION check_only_one_matriz()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_matriz = true THEN
        -- Verificar se já existe outra matriz para esta empresa
        IF EXISTS (
            SELECT 1 FROM public.filiais 
            WHERE empresa_id = NEW.empresa_id 
            AND is_matriz = true 
            AND id != NEW.id
            AND deleted_at IS NULL
        ) THEN
            RAISE EXCEPTION 'Já existe uma matriz cadastrada para esta empresa';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_single_matriz
    BEFORE INSERT OR UPDATE ON public.filiais
    FOR EACH ROW
    EXECUTE FUNCTION check_only_one_matriz();

-- ================================================
-- COMENTÁRIOS (Documentação)
-- ================================================

COMMENT ON TABLE public.filiais IS 'Filiais/lojas de cada empresa';
COMMENT ON COLUMN public.filiais.empresa_id IS 'Empresa dona desta filial';
COMMENT ON COLUMN public.filiais.tipo IS 'Tipo: matriz, filial, loja, deposito';
COMMENT ON COLUMN public.filiais.is_matriz IS 'Flag para identificar matriz (apenas uma por empresa)';
COMMENT ON COLUMN public.filiais.horarios_funcionamento IS 'Horários de funcionamento por dia da semana (JSON)';

-- ================================================
-- GRANT PERMISSIONS
-- ================================================

GRANT ALL ON public.filiais TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.filiais TO authenticated;

-- ================================================
-- CONSTRAINT: Validação de Status
-- ================================================

ALTER TABLE public.filiais
ADD CONSTRAINT check_filial_status 
CHECK (status IN ('active', 'inactive', 'closed'));

-- ================================================
-- CONSTRAINT: Validação de Tipo
-- ================================================

ALTER TABLE public.filiais
ADD CONSTRAINT check_filial_tipo 
CHECK (tipo IN ('matriz', 'filial', 'loja', 'deposito'));

-- ================================================
-- CONSTRAINT: Validação de UF (Estado)
-- ================================================

ALTER TABLE public.filiais
ADD CONSTRAINT check_filial_estado
CHECK (
    estado IN (
        'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
        'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
        'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    )
);

-- ================================================
-- FIM DA MIGRATION
-- ================================================



