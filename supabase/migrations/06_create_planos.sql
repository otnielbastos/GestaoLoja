-- ================================================
-- MIGRATION 06: Criar Tabela PLANOS
-- Data: 05/12/2025
-- Descrição: Planos de assinatura do SaaS
-- ================================================

-- Tabela: planos
CREATE TABLE IF NOT EXISTS public.planos (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Dados do Plano
    nome VARCHAR(100) NOT NULL UNIQUE, -- Trial, Starter, Pro, Enterprise
    descricao TEXT,
    
    -- Preços
    preco_mensal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    preco_anual DECIMAL(10,2), -- Desconto no anual
    
    -- Limites do Plano
    limite_usuarios INTEGER, -- NULL = ilimitado
    limite_produtos INTEGER,
    limite_pedidos_mes INTEGER,
    limite_clientes INTEGER,
    limite_filiais INTEGER,
    limite_storage_gb INTEGER, -- Storage para imagens
    
    -- Recursos (Flags de Features)
    permite_multi_filial BOOLEAN DEFAULT false,
    permite_relatorios_avancados BOOLEAN DEFAULT false,
    permite_api_acesso BOOLEAN DEFAULT false,
    permite_exportacao_dados BOOLEAN DEFAULT true,
    permite_integracao_nfe BOOLEAN DEFAULT false,
    permite_personalizacao BOOLEAN DEFAULT false,
    remove_marca_dagua BOOLEAN DEFAULT false,
    
    -- Suporte
    nivel_suporte VARCHAR(50) DEFAULT 'basico', -- basico, prioritario, dedicado
    
    -- Status e Ordem
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, inactive
    ordem INTEGER NOT NULL DEFAULT 0, -- Para ordenar exibição (Trial=0, Starter=1, etc)
    
    -- Flags Especiais
    is_default BOOLEAN DEFAULT false, -- Plano padrão para novos cadastros
    is_trial BOOLEAN DEFAULT false, -- É o plano trial?
    
    -- Configurações Extras
    configuracoes JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- ÍNDICES
-- ================================================

-- Índice para busca por nome
CREATE UNIQUE INDEX idx_planos_nome ON public.planos(LOWER(nome));

-- Índice para planos ativos
CREATE INDEX idx_planos_active ON public.planos(status) WHERE status = 'active';

-- Índice para ordenação
CREATE INDEX idx_planos_ordem ON public.planos(ordem);

-- ================================================
-- TRIGGER: updated_at automático
-- ================================================

CREATE TRIGGER set_updated_at_planos
    BEFORE UPDATE ON public.planos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- INSERIR PLANOS PADRÃO
-- ================================================

INSERT INTO public.planos (
    nome, descricao, preco_mensal, preco_anual, ordem, is_trial, is_default,
    limite_usuarios, limite_produtos, limite_pedidos_mes, limite_clientes, limite_filiais, limite_storage_gb,
    permite_multi_filial, permite_relatorios_avancados, permite_api_acesso, 
    permite_exportacao_dados, permite_integracao_nfe, permite_personalizacao, remove_marca_dagua,
    nivel_suporte, status
) VALUES 
-- PLANO TRIAL (14 dias grátis)
(
    'Trial',
    'Teste grátis por 14 dias - Acesso completo ao sistema',
    0.00,
    0.00,
    0,
    true,
    true, -- É o padrão para novos cadastros
    2, -- Limite de usuários
    50, -- Limite de produtos
    100, -- Limite de pedidos por mês
    50, -- Limite de clientes
    1, -- Apenas 1 filial
    1, -- 1GB de storage
    false, -- Sem multi-filial
    false, -- Sem relatórios avançados
    false, -- Sem API
    true, -- Exportação básica
    false, -- Sem NFe
    false, -- Sem personalização
    false, -- Com marca d'água
    'basico',
    'active'
),

-- PLANO STARTER
(
    'Starter',
    'Plano básico ideal para pequenos negócios',
    79.90,
    799.00, -- ~R$ 66/mês (2 meses grátis no anual)
    1,
    false,
    false,
    3, -- 3 usuários
    200, -- 200 produtos
    500, -- 500 pedidos/mês
    200, -- 200 clientes
    1, -- 1 filial
    5, -- 5GB
    false, -- Sem multi-filial
    false, -- Sem relatórios avançados
    false, -- Sem API
    true, -- Exportação
    false, -- Sem NFe
    false, -- Sem personalização
    true, -- Remove marca d'água
    'basico',
    'active'
),

-- PLANO PRO (Mais Popular)
(
    'Pro',
    'Plano profissional com recursos avançados',
    149.90,
    1499.00, -- ~R$ 125/mês (2 meses grátis)
    2,
    false,
    false,
    10, -- 10 usuários
    NULL, -- Produtos ilimitados
    NULL, -- Pedidos ilimitados
    NULL, -- Clientes ilimitados
    5, -- Até 5 filiais
    20, -- 20GB
    true, -- Multi-filial
    true, -- Relatórios avançados
    false, -- Sem API (só Enterprise)
    true, -- Exportação
    true, -- NFe
    true, -- Personalização
    true, -- Remove marca d'água
    'prioritario',
    'active'
),

-- PLANO ENTERPRISE
(
    'Enterprise',
    'Plano completo para grandes operações',
    299.90,
    2999.00, -- ~R$ 250/mês (2 meses grátis)
    3,
    false,
    false,
    NULL, -- Usuários ilimitados
    NULL, -- Produtos ilimitados
    NULL, -- Pedidos ilimitados
    NULL, -- Clientes ilimitados
    NULL, -- Filiais ilimitadas
    100, -- 100GB
    true, -- Multi-filial
    true, -- Relatórios avançados
    true, -- API completa
    true, -- Exportação
    true, -- NFe
    true, -- Personalização total
    true, -- Remove marca d'água
    'dedicado',
    'active'
);

-- ================================================
-- COMENTÁRIOS (Documentação)
-- ================================================

COMMENT ON TABLE public.planos IS 'Planos de assinatura do sistema SaaS';
COMMENT ON COLUMN public.planos.preco_mensal IS 'Preço mensal em Reais (BRL)';
COMMENT ON COLUMN public.planos.preco_anual IS 'Preço anual com desconto (geralmente 2 meses grátis)';
COMMENT ON COLUMN public.planos.limite_usuarios IS 'Limite de usuários (NULL = ilimitado)';
COMMENT ON COLUMN public.planos.is_trial IS 'Indica se é o plano trial gratuito';
COMMENT ON COLUMN public.planos.is_default IS 'Plano padrão para novos cadastros';
COMMENT ON COLUMN public.planos.ordem IS 'Ordem de exibição (0=Trial, 1=Starter, 2=Pro, 3=Enterprise)';

-- ================================================
-- GRANT PERMISSIONS
-- ================================================

GRANT ALL ON public.planos TO service_role;
GRANT SELECT ON public.planos TO authenticated; -- Usuários só podem ler planos

-- ================================================
-- CONSTRAINT: Validação de Status
-- ================================================

ALTER TABLE public.planos
ADD CONSTRAINT check_plano_status 
CHECK (status IN ('active', 'inactive'));

-- ================================================
-- CONSTRAINT: Validação de Nível Suporte
-- ================================================

ALTER TABLE public.planos
ADD CONSTRAINT check_plano_nivel_suporte 
CHECK (nivel_suporte IN ('basico', 'prioritario', 'dedicado'));

-- ================================================
-- CONSTRAINT: Preços não podem ser negativos
-- ================================================

ALTER TABLE public.planos
ADD CONSTRAINT check_plano_preco_mensal 
CHECK (preco_mensal >= 0);

ALTER TABLE public.planos
ADD CONSTRAINT check_plano_preco_anual 
CHECK (preco_anual IS NULL OR preco_anual >= 0);

-- ================================================
-- AGORA podemos adicionar a FK em empresas
-- ================================================

ALTER TABLE public.empresas
ADD CONSTRAINT fk_empresas_plano
FOREIGN KEY (plano_id) REFERENCES public.planos(id);

-- ================================================
-- FIM DA MIGRATION
-- ================================================



