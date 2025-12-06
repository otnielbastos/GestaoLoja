-- ================================================
-- MIGRATION 09: Criar Tabela HISTORICO_ASSINATURAS
-- Data: 05/12/2025
-- Descrição: Histórico de mudanças de plano e pagamentos
-- ================================================

-- Tabela: historico_assinaturas
CREATE TABLE IF NOT EXISTS public.historico_assinaturas (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
    
    -- Plano
    plano_id UUID NOT NULL REFERENCES public.planos(id),
    plano_nome VARCHAR(100) NOT NULL, -- Guardar nome para histórico (caso plano mude)
    
    -- Tipo de Evento
    tipo_evento VARCHAR(50) NOT NULL, -- inicio, renovacao, upgrade, downgrade, cancelamento, reativacao
    
    -- Valores
    valor_cobrado DECIMAL(10,2),
    periodo_cobranca VARCHAR(20), -- mensal, anual
    
    -- Datas
    data_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    data_fim TIMESTAMP WITH TIME ZONE,
    
    -- Pagamento
    status_pagamento VARCHAR(30) DEFAULT 'pendente', -- pendente, pago, vencido, cancelado
    forma_pagamento VARCHAR(50), -- pix, boleto, cartao_credito, transferencia
    data_pagamento TIMESTAMP WITH TIME ZONE,
    data_vencimento TIMESTAMP WITH TIME ZONE,
    
    -- Dados do Pagamento (se aplicável)
    transacao_id VARCHAR(255), -- ID externo do gateway de pagamento
    comprovante_url TEXT, -- URL do comprovante/nota fiscal
    
    -- Observações
    observacoes TEXT,
    
    -- Quem fez a ação
    realizado_por UUID REFERENCES auth.users(id), -- Usuário que fez a ação (admin)
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- ÍNDICES
-- ================================================

-- Índice para buscar histórico de uma empresa
CREATE INDEX idx_historico_empresa 
ON public.historico_assinaturas(empresa_id, created_at DESC);

-- Índice para buscar por plano
CREATE INDEX idx_historico_plano 
ON public.historico_assinaturas(plano_id);

-- Índice para buscar por tipo de evento
CREATE INDEX idx_historico_tipo_evento 
ON public.historico_assinaturas(tipo_evento);

-- Índice para pagamentos pendentes
CREATE INDEX idx_historico_pagamentos_pendentes 
ON public.historico_assinaturas(empresa_id, status_pagamento, data_vencimento)
WHERE status_pagamento IN ('pendente', 'vencido');

-- Índice para relatórios financeiros (pagamentos confirmados)
CREATE INDEX idx_historico_pagamentos_realizados 
ON public.historico_assinaturas(data_pagamento, status_pagamento)
WHERE status_pagamento = 'pago';

-- ================================================
-- FUNÇÕES AUXILIARES
-- ================================================

-- Função: Registrar início de assinatura
CREATE OR REPLACE FUNCTION registrar_inicio_assinatura(
    p_empresa_id UUID,
    p_plano_id UUID,
    p_periodo VARCHAR DEFAULT 'mensal'
)
RETURNS UUID AS $$
DECLARE
    v_plano RECORD;
    v_valor DECIMAL(10,2);
    v_data_fim TIMESTAMP;
    v_historico_id UUID;
BEGIN
    -- Buscar dados do plano
    SELECT nome, preco_mensal, preco_anual
    INTO v_plano
    FROM public.planos
    WHERE id = p_plano_id;
    
    -- Definir valor e data fim baseado no período
    IF p_periodo = 'anual' THEN
        v_valor := v_plano.preco_anual;
        v_data_fim := NOW() + INTERVAL '1 year';
    ELSE
        v_valor := v_plano.preco_mensal;
        v_data_fim := NOW() + INTERVAL '1 month';
    END IF;
    
    -- Inserir no histórico
    INSERT INTO public.historico_assinaturas (
        empresa_id,
        plano_id,
        plano_nome,
        tipo_evento,
        valor_cobrado,
        periodo_cobranca,
        data_inicio,
        data_fim,
        status_pagamento,
        data_vencimento
    ) VALUES (
        p_empresa_id,
        p_plano_id,
        v_plano.nome,
        'inicio',
        v_valor,
        p_periodo,
        NOW(),
        v_data_fim,
        CASE WHEN v_valor = 0 THEN 'pago' ELSE 'pendente' END,
        CASE WHEN v_valor = 0 THEN NULL ELSE NOW() + INTERVAL '5 days' END
    )
    RETURNING id INTO v_historico_id;
    
    RETURN v_historico_id;
END;
$$ LANGUAGE plpgsql;

-- Função: Registrar renovação
CREATE OR REPLACE FUNCTION registrar_renovacao_assinatura(
    p_empresa_id UUID
)
RETURNS UUID AS $$
DECLARE
    v_empresa RECORD;
    v_plano RECORD;
    v_historico_id UUID;
BEGIN
    -- Buscar dados da empresa e plano
    SELECT e.plano_id, p.nome, p.preco_mensal
    INTO v_empresa
    FROM public.empresas e
    JOIN public.planos p ON e.plano_id = p.id
    WHERE e.id = p_empresa_id;
    
    -- Inserir renovação no histórico
    INSERT INTO public.historico_assinaturas (
        empresa_id,
        plano_id,
        plano_nome,
        tipo_evento,
        valor_cobrado,
        periodo_cobranca,
        data_inicio,
        data_fim,
        status_pagamento,
        data_vencimento
    ) VALUES (
        p_empresa_id,
        v_empresa.plano_id,
        v_empresa.nome,
        'renovacao',
        v_empresa.preco_mensal,
        'mensal',
        NOW(),
        NOW() + INTERVAL '1 month',
        'pendente',
        NOW() + INTERVAL '5 days'
    )
    RETURNING id INTO v_historico_id;
    
    RETURN v_historico_id;
END;
$$ LANGUAGE plpgsql;

-- Função: Registrar mudança de plano (upgrade/downgrade)
CREATE OR REPLACE FUNCTION registrar_mudanca_plano(
    p_empresa_id UUID,
    p_novo_plano_id UUID,
    p_realizado_por UUID
)
RETURNS UUID AS $$
DECLARE
    v_plano_atual UUID;
    v_ordem_atual INTEGER;
    v_ordem_novo INTEGER;
    v_tipo_evento VARCHAR(50);
    v_novo_plano RECORD;
    v_historico_id UUID;
BEGIN
    -- Buscar plano atual
    SELECT plano_id INTO v_plano_atual
    FROM public.empresas
    WHERE id = p_empresa_id;
    
    -- Buscar ordens para determinar se é upgrade ou downgrade
    SELECT ordem INTO v_ordem_atual FROM public.planos WHERE id = v_plano_atual;
    SELECT ordem INTO v_ordem_novo FROM public.planos WHERE id = p_novo_plano_id;
    
    -- Determinar tipo
    IF v_ordem_novo > v_ordem_atual THEN
        v_tipo_evento := 'upgrade';
    ELSE
        v_tipo_evento := 'downgrade';
    END IF;
    
    -- Buscar dados do novo plano
    SELECT nome, preco_mensal
    INTO v_novo_plano
    FROM public.planos
    WHERE id = p_novo_plano_id;
    
    -- Registrar mudança
    INSERT INTO public.historico_assinaturas (
        empresa_id,
        plano_id,
        plano_nome,
        tipo_evento,
        valor_cobrado,
        periodo_cobranca,
        data_inicio,
        data_fim,
        status_pagamento,
        data_vencimento,
        realizado_por
    ) VALUES (
        p_empresa_id,
        p_novo_plano_id,
        v_novo_plano.nome,
        v_tipo_evento,
        v_novo_plano.preco_mensal,
        'mensal',
        NOW(),
        NOW() + INTERVAL '1 month',
        'pendente',
        NOW() + INTERVAL '5 days',
        p_realizado_por
    )
    RETURNING id INTO v_historico_id;
    
    -- Atualizar plano da empresa
    UPDATE public.empresas
    SET plano_id = p_novo_plano_id,
        data_renovacao = NOW() + INTERVAL '1 month',
        updated_at = NOW()
    WHERE id = p_empresa_id;
    
    RETURN v_historico_id;
END;
$$ LANGUAGE plpgsql;

-- Função: Registrar pagamento
CREATE OR REPLACE FUNCTION registrar_pagamento(
    p_historico_id UUID,
    p_forma_pagamento VARCHAR,
    p_transacao_id VARCHAR DEFAULT NULL,
    p_comprovante_url TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE public.historico_assinaturas
    SET status_pagamento = 'pago',
        data_pagamento = NOW(),
        forma_pagamento = p_forma_pagamento,
        transacao_id = p_transacao_id,
        comprovante_url = p_comprovante_url
    WHERE id = p_historico_id;
    
    -- Atualizar status da empresa para active (se estava suspended por falta de pagamento)
    UPDATE public.empresas
    SET status = 'active',
        updated_at = NOW()
    WHERE id = (SELECT empresa_id FROM public.historico_assinaturas WHERE id = p_historico_id)
    AND status = 'suspended';
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- COMENTÁRIOS (Documentação)
-- ================================================

COMMENT ON TABLE public.historico_assinaturas IS 'Histórico de assinaturas, mudanças de plano e pagamentos';
COMMENT ON COLUMN public.historico_assinaturas.tipo_evento IS 'inicio, renovacao, upgrade, downgrade, cancelamento, reativacao';
COMMENT ON COLUMN public.historico_assinaturas.status_pagamento IS 'pendente, pago, vencido, cancelado';
COMMENT ON COLUMN public.historico_assinaturas.periodo_cobranca IS 'mensal ou anual';

-- ================================================
-- GRANT PERMISSIONS
-- ================================================

GRANT ALL ON public.historico_assinaturas TO service_role;
GRANT SELECT ON public.historico_assinaturas TO authenticated;

GRANT EXECUTE ON FUNCTION registrar_inicio_assinatura TO service_role;
GRANT EXECUTE ON FUNCTION registrar_renovacao_assinatura TO service_role;
GRANT EXECUTE ON FUNCTION registrar_mudanca_plano TO authenticated;
GRANT EXECUTE ON FUNCTION registrar_pagamento TO service_role;

-- ================================================
-- CONSTRAINT: Validação de Tipo Evento
-- ================================================

ALTER TABLE public.historico_assinaturas
ADD CONSTRAINT check_historico_tipo_evento 
CHECK (tipo_evento IN ('inicio', 'renovacao', 'upgrade', 'downgrade', 'cancelamento', 'reativacao'));

-- ================================================
-- CONSTRAINT: Validação de Status Pagamento
-- ================================================

ALTER TABLE public.historico_assinaturas
ADD CONSTRAINT check_historico_status_pagamento 
CHECK (status_pagamento IN ('pendente', 'pago', 'vencido', 'cancelado'));

-- ================================================
-- CONSTRAINT: Validação de Período
-- ================================================

ALTER TABLE public.historico_assinaturas
ADD CONSTRAINT check_historico_periodo 
CHECK (periodo_cobranca IN ('mensal', 'anual'));

-- ================================================
-- FIM DA MIGRATION
-- ================================================



