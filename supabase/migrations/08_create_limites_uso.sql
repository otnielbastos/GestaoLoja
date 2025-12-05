-- ================================================
-- MIGRATION 08: Criar Tabela LIMITES_USO
-- Data: 05/12/2025
-- Descrição: Controlar uso e limites de cada empresa
--            Para billing e enforcement de planos
-- ================================================

-- Tabela: limites_uso
CREATE TABLE IF NOT EXISTS public.limites_uso (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
    
    -- Tipo de Limite
    tipo_limite VARCHAR(50) NOT NULL, -- usuarios, produtos, pedidos_mes, clientes, filiais, storage_gb
    
    -- Valores
    limite_maximo INTEGER, -- NULL = ilimitado
    valor_atual INTEGER NOT NULL DEFAULT 0,
    
    -- Período (para limites mensais)
    mes_referencia VARCHAR(7), -- Format: YYYY-MM (ex: 2025-12)
    
    -- Alertas
    alerta_enviado BOOLEAN DEFAULT false,
    percentual_uso DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN limite_maximo IS NULL THEN 0
            WHEN limite_maximo = 0 THEN 0
            ELSE (valor_atual::DECIMAL / limite_maximo::DECIMAL) * 100
        END
    ) STORED,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- ÍNDICES
-- ================================================

-- Índice único para evitar duplicação (empresa + tipo + mes)
CREATE UNIQUE INDEX idx_limites_uso_unique 
ON public.limites_uso(empresa_id, tipo_limite, mes_referencia);

-- Índice para buscar limites de uma empresa
CREATE INDEX idx_limites_uso_empresa 
ON public.limites_uso(empresa_id);

-- Índice para alertas (empresas próximas do limite)
CREATE INDEX idx_limites_uso_alertas 
ON public.limites_uso(empresa_id, alerta_enviado) 
WHERE percentual_uso >= 80;

-- ================================================
-- TRIGGER: updated_at automático
-- ================================================

CREATE TRIGGER set_updated_at_limites_uso
    BEFORE UPDATE ON public.limites_uso
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- FUNÇÕES AUXILIARES
-- ================================================

-- Função: Inicializar limites para uma empresa (baseado no plano)
CREATE OR REPLACE FUNCTION inicializar_limites_empresa(p_empresa_id UUID)
RETURNS VOID AS $$
DECLARE
    v_plano RECORD;
    v_mes_atual VARCHAR(7);
BEGIN
    -- Obter mês atual
    v_mes_atual := TO_CHAR(NOW(), 'YYYY-MM');
    
    -- Buscar plano da empresa
    SELECT 
        p.limite_usuarios,
        p.limite_produtos,
        p.limite_pedidos_mes,
        p.limite_clientes,
        p.limite_filiais,
        p.limite_storage_gb
    INTO v_plano
    FROM public.empresas e
    JOIN public.planos p ON e.plano_id = p.id
    WHERE e.id = p_empresa_id;
    
    -- Inserir limites (INSERT ... ON CONFLICT para evitar duplicação)
    
    -- Usuários
    INSERT INTO public.limites_uso (empresa_id, tipo_limite, limite_maximo, mes_referencia)
    VALUES (p_empresa_id, 'usuarios', v_plano.limite_usuarios, NULL)
    ON CONFLICT (empresa_id, tipo_limite, mes_referencia) DO NOTHING;
    
    -- Produtos
    INSERT INTO public.limites_uso (empresa_id, tipo_limite, limite_maximo, mes_referencia)
    VALUES (p_empresa_id, 'produtos', v_plano.limite_produtos, NULL)
    ON CONFLICT (empresa_id, tipo_limite, mes_referencia) DO NOTHING;
    
    -- Pedidos por Mês
    INSERT INTO public.limites_uso (empresa_id, tipo_limite, limite_maximo, mes_referencia)
    VALUES (p_empresa_id, 'pedidos_mes', v_plano.limite_pedidos_mes, v_mes_atual)
    ON CONFLICT (empresa_id, tipo_limite, mes_referencia) DO NOTHING;
    
    -- Clientes
    INSERT INTO public.limites_uso (empresa_id, tipo_limite, limite_maximo, mes_referencia)
    VALUES (p_empresa_id, 'clientes', v_plano.limite_clientes, NULL)
    ON CONFLICT (empresa_id, tipo_limite, mes_referencia) DO NOTHING;
    
    -- Filiais
    INSERT INTO public.limites_uso (empresa_id, tipo_limite, limite_maximo, mes_referencia)
    VALUES (p_empresa_id, 'filiais', v_plano.limite_filiais, NULL)
    ON CONFLICT (empresa_id, tipo_limite, mes_referencia) DO NOTHING;
    
    -- Storage
    INSERT INTO public.limites_uso (empresa_id, tipo_limite, limite_maximo, mes_referencia)
    VALUES (p_empresa_id, 'storage_gb', v_plano.limite_storage_gb, NULL)
    ON CONFLICT (empresa_id, tipo_limite, mes_referencia) DO NOTHING;
    
END;
$$ LANGUAGE plpgsql;

-- Função: Verificar se empresa atingiu limite
CREATE OR REPLACE FUNCTION verificar_limite(
    p_empresa_id UUID,
    p_tipo_limite VARCHAR
)
RETURNS BOOLEAN AS $$
DECLARE
    v_limite INTEGER;
    v_atual INTEGER;
    v_mes_atual VARCHAR(7);
BEGIN
    v_mes_atual := TO_CHAR(NOW(), 'YYYY-MM');
    
    -- Buscar limite
    SELECT limite_maximo, valor_atual
    INTO v_limite, v_atual
    FROM public.limites_uso
    WHERE empresa_id = p_empresa_id
    AND tipo_limite = p_tipo_limite
    AND (
        mes_referencia IS NULL -- Limites fixos (não mensais)
        OR mes_referencia = v_mes_atual -- Limites mensais
    )
    LIMIT 1;
    
    -- Se limite é NULL = ilimitado
    IF v_limite IS NULL THEN
        RETURN false; -- Não atingiu (ilimitado)
    END IF;
    
    -- Verificar se atingiu
    RETURN v_atual >= v_limite;
END;
$$ LANGUAGE plpgsql;

-- Função: Incrementar uso
CREATE OR REPLACE FUNCTION incrementar_uso(
    p_empresa_id UUID,
    p_tipo_limite VARCHAR,
    p_incremento INTEGER DEFAULT 1
)
RETURNS VOID AS $$
DECLARE
    v_mes_atual VARCHAR(7);
BEGIN
    v_mes_atual := TO_CHAR(NOW(), 'YYYY-MM');
    
    -- Atualizar valor atual
    UPDATE public.limites_uso
    SET valor_atual = valor_atual + p_incremento,
        updated_at = NOW()
    WHERE empresa_id = p_empresa_id
    AND tipo_limite = p_tipo_limite
    AND (
        mes_referencia IS NULL 
        OR mes_referencia = v_mes_atual
    );
    
    -- Se não existir, criar
    IF NOT FOUND THEN
        INSERT INTO public.limites_uso (
            empresa_id, 
            tipo_limite, 
            valor_atual, 
            mes_referencia
        ) VALUES (
            p_empresa_id, 
            p_tipo_limite, 
            p_incremento,
            CASE 
                WHEN p_tipo_limite = 'pedidos_mes' THEN v_mes_atual
                ELSE NULL
            END
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Função: Decrementar uso
CREATE OR REPLACE FUNCTION decrementar_uso(
    p_empresa_id UUID,
    p_tipo_limite VARCHAR,
    p_decremento INTEGER DEFAULT 1
)
RETURNS VOID AS $$
DECLARE
    v_mes_atual VARCHAR(7);
BEGIN
    v_mes_atual := TO_CHAR(NOW(), 'YYYY-MM');
    
    -- Atualizar valor atual (não deixar ficar negativo)
    UPDATE public.limites_uso
    SET valor_atual = GREATEST(0, valor_atual - p_decremento),
        updated_at = NOW()
    WHERE empresa_id = p_empresa_id
    AND tipo_limite = p_tipo_limite
    AND (
        mes_referencia IS NULL 
        OR mes_referencia = v_mes_atual
    );
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- TRIGGER: Inicializar limites ao criar empresa
-- ================================================

CREATE OR REPLACE FUNCTION trigger_inicializar_limites()
RETURNS TRIGGER AS $$
BEGIN
    -- Inicializar limites para a nova empresa
    PERFORM inicializar_limites_empresa(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_empresa_init_limites
    AFTER INSERT ON public.empresas
    FOR EACH ROW
    EXECUTE FUNCTION trigger_inicializar_limites();

-- ================================================
-- COMENTÁRIOS (Documentação)
-- ================================================

COMMENT ON TABLE public.limites_uso IS 'Controle de uso e limites de cada empresa';
COMMENT ON COLUMN public.limites_uso.tipo_limite IS 'Tipo: usuarios, produtos, pedidos_mes, clientes, filiais, storage_gb';
COMMENT ON COLUMN public.limites_uso.limite_maximo IS 'Limite máximo (NULL = ilimitado)';
COMMENT ON COLUMN public.limites_uso.valor_atual IS 'Uso atual';
COMMENT ON COLUMN public.limites_uso.mes_referencia IS 'Mês de referência para limites mensais (YYYY-MM)';
COMMENT ON COLUMN public.limites_uso.percentual_uso IS 'Percentual de uso (calculado automaticamente)';

-- ================================================
-- GRANT PERMISSIONS
-- ================================================

GRANT ALL ON public.limites_uso TO service_role;
GRANT SELECT ON public.limites_uso TO authenticated;

GRANT EXECUTE ON FUNCTION inicializar_limites_empresa TO service_role;
GRANT EXECUTE ON FUNCTION verificar_limite TO authenticated;
GRANT EXECUTE ON FUNCTION incrementar_uso TO service_role;
GRANT EXECUTE ON FUNCTION decrementar_uso TO service_role;

-- ================================================
-- CONSTRAINT: Validação de Tipo Limite
-- ================================================

ALTER TABLE public.limites_uso
ADD CONSTRAINT check_limites_tipo 
CHECK (tipo_limite IN ('usuarios', 'produtos', 'pedidos_mes', 'clientes', 'filiais', 'storage_gb'));

-- ================================================
-- FIM DA MIGRATION
-- ================================================

