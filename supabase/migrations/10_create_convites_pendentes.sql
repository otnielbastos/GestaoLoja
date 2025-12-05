-- ================================================
-- MIGRATION 10: Criar Tabela CONVITES_PENDENTES
-- Data: 05/12/2025
-- Descrição: Gerenciar convites para novos usuários
-- ================================================

-- Tabela: convites_pendentes
CREATE TABLE IF NOT EXISTS public.convites_pendentes (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamentos
    empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
    convidado_por UUID NOT NULL REFERENCES auth.users(id),
    
    -- Dados do Convite
    email VARCHAR(255) NOT NULL,
    papel VARCHAR(50) NOT NULL DEFAULT 'usuario', -- Papel que terá quando aceitar
    
    -- Token de Convite (único e seguro)
    token VARCHAR(255) NOT NULL UNIQUE,
    
    -- Filiais com acesso
    filiais_acesso UUID[],
    acesso_todas_filiais BOOLEAN DEFAULT true,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'pendente', -- pendente, aceito, expirado, cancelado
    
    -- Datas
    data_convite TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_expiracao TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days'), -- Convite expira em 7 dias
    data_aceitacao TIMESTAMP WITH TIME ZONE,
    
    -- Mensagem Personalizada
    mensagem_convite TEXT,
    
    -- Aceito Por (quando aceitar)
    aceito_por_usuario_id UUID REFERENCES auth.users(id),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- ÍNDICES
-- ================================================

-- Índice único para evitar convites duplicados (email + empresa)
CREATE UNIQUE INDEX idx_convites_email_empresa 
ON public.convites_pendentes(email, empresa_id) 
WHERE status = 'pendente';

-- Índice para buscar convites de uma empresa
CREATE INDEX idx_convites_empresa 
ON public.convites_pendentes(empresa_id, status);

-- Índice para buscar por token (validação rápida)
CREATE UNIQUE INDEX idx_convites_token 
ON public.convites_pendentes(token);

-- Índice para buscar convites por email
CREATE INDEX idx_convites_email 
ON public.convites_pendentes(email) 
WHERE status = 'pendente';

-- Índice para limpar convites expirados
-- Nota: Removido 'data_expiracao < NOW()' do WHERE pois NOW() não é IMMUTABLE
CREATE INDEX idx_convites_expirados 
ON public.convites_pendentes(data_expiracao, status)
WHERE status = 'pendente';

-- ================================================
-- TRIGGER: updated_at automático
-- ================================================

CREATE TRIGGER set_updated_at_convites
    BEFORE UPDATE ON public.convites_pendentes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- TRIGGER: Marcar convites expirados automaticamente
-- ================================================

CREATE OR REPLACE FUNCTION marcar_convites_expirados()
RETURNS TRIGGER AS $$
BEGIN
    -- Se está lendo um convite pendente que já expirou, marcar como expirado
    IF NEW.status = 'pendente' AND NEW.data_expiracao < NOW() THEN
        NEW.status := 'expirado';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_convite_expiracao
    BEFORE UPDATE ON public.convites_pendentes
    FOR EACH ROW
    WHEN (OLD.status = 'pendente')
    EXECUTE FUNCTION marcar_convites_expirados();

-- ================================================
-- FUNÇÕES AUXILIARES
-- ================================================

-- Função: Criar convite
CREATE OR REPLACE FUNCTION criar_convite(
    p_empresa_id UUID,
    p_email VARCHAR,
    p_papel VARCHAR,
    p_convidado_por UUID,
    p_filiais_acesso UUID[] DEFAULT NULL,
    p_acesso_todas_filiais BOOLEAN DEFAULT true,
    p_mensagem TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_token VARCHAR(255);
    v_convite_id UUID;
BEGIN
    -- Gerar token único e seguro (usando gen_random_uuid + timestamp)
    v_token := encode(gen_random_bytes(32), 'hex');
    
    -- Verificar se email já está convidado ou já é usuário
    IF EXISTS (
        SELECT 1 FROM public.convites_pendentes
        WHERE empresa_id = p_empresa_id
        AND email = p_email
        AND status = 'pendente'
    ) THEN
        RAISE EXCEPTION 'Este email já possui um convite pendente';
    END IF;
    
    -- Criar convite
    INSERT INTO public.convites_pendentes (
        empresa_id,
        email,
        papel,
        token,
        convidado_por,
        filiais_acesso,
        acesso_todas_filiais,
        mensagem_convite
    ) VALUES (
        p_empresa_id,
        p_email,
        p_papel,
        v_token,
        p_convidado_por,
        p_filiais_acesso,
        p_acesso_todas_filiais,
        p_mensagem
    )
    RETURNING id INTO v_convite_id;
    
    RETURN v_convite_id;
END;
$$ LANGUAGE plpgsql;

-- Função: Validar token de convite
CREATE OR REPLACE FUNCTION validar_token_convite(p_token VARCHAR)
RETURNS TABLE (
    id UUID,
    empresa_id UUID,
    email VARCHAR,
    papel VARCHAR,
    filiais_acesso UUID[],
    acesso_todas_filiais BOOLEAN,
    status VARCHAR,
    data_expiracao TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.empresa_id,
        c.email,
        c.papel,
        c.filiais_acesso,
        c.acesso_todas_filiais,
        c.status,
        c.data_expiracao
    FROM public.convites_pendentes c
    WHERE c.token = p_token;
END;
$$ LANGUAGE plpgsql;

-- Função: Aceitar convite
CREATE OR REPLACE FUNCTION aceitar_convite(
    p_token VARCHAR,
    p_usuario_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_convite RECORD;
BEGIN
    -- Buscar convite
    SELECT * INTO v_convite
    FROM public.convites_pendentes
    WHERE token = p_token
    AND status = 'pendente'
    AND data_expiracao > NOW();
    
    -- Se não encontrou ou expirou
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Criar relacionamento usuário-empresa
    INSERT INTO public.usuarios_empresas (
        usuario_id,
        empresa_id,
        papel,
        filiais_acesso,
        acesso_todas_filiais,
        convidado_por,
        data_convite,
        data_aceitacao
    ) VALUES (
        p_usuario_id,
        v_convite.empresa_id,
        v_convite.papel,
        v_convite.filiais_acesso,
        v_convite.acesso_todas_filiais,
        v_convite.convidado_por,
        v_convite.data_convite,
        NOW()
    );
    
    -- Marcar convite como aceito
    UPDATE public.convites_pendentes
    SET status = 'aceito',
        data_aceitacao = NOW(),
        aceito_por_usuario_id = p_usuario_id,
        updated_at = NOW()
    WHERE id = v_convite.id;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Função: Cancelar convite
CREATE OR REPLACE FUNCTION cancelar_convite(p_convite_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE public.convites_pendentes
    SET status = 'cancelado',
        updated_at = NOW()
    WHERE id = p_convite_id
    AND status = 'pendente';
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Função: Reenviar convite (gera novo token e estende validade)
CREATE OR REPLACE FUNCTION reenviar_convite(p_convite_id UUID)
RETURNS VARCHAR AS $$
DECLARE
    v_novo_token VARCHAR(255);
BEGIN
    -- Gerar novo token
    v_novo_token := encode(gen_random_bytes(32), 'hex');
    
    -- Atualizar convite
    UPDATE public.convites_pendentes
    SET token = v_novo_token,
        data_expiracao = NOW() + INTERVAL '7 days',
        updated_at = NOW()
    WHERE id = p_convite_id
    AND status = 'pendente';
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Convite não encontrado ou já foi aceito/cancelado';
    END IF;
    
    RETURN v_novo_token;
END;
$$ LANGUAGE plpgsql;

-- Função: Limpar convites expirados (executar periodicamente)
CREATE OR REPLACE FUNCTION limpar_convites_expirados()
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.convites_pendentes
    SET status = 'expirado',
        updated_at = NOW()
    WHERE status = 'pendente'
    AND data_expiracao < NOW();
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- COMENTÁRIOS (Documentação)
-- ================================================

COMMENT ON TABLE public.convites_pendentes IS 'Convites para novos usuários entrarem em empresas';
COMMENT ON COLUMN public.convites_pendentes.token IS 'Token único e seguro para aceitar convite';
COMMENT ON COLUMN public.convites_pendentes.data_expiracao IS 'Convites expiram em 7 dias';
COMMENT ON COLUMN public.convites_pendentes.papel IS 'Papel que o usuário terá quando aceitar';

-- ================================================
-- GRANT PERMISSIONS
-- ================================================

GRANT ALL ON public.convites_pendentes TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.convites_pendentes TO authenticated;

GRANT EXECUTE ON FUNCTION criar_convite TO authenticated;
GRANT EXECUTE ON FUNCTION validar_token_convite TO anon, authenticated;
GRANT EXECUTE ON FUNCTION aceitar_convite TO authenticated;
GRANT EXECUTE ON FUNCTION cancelar_convite TO authenticated;
GRANT EXECUTE ON FUNCTION reenviar_convite TO authenticated;
GRANT EXECUTE ON FUNCTION limpar_convites_expirados TO service_role;

-- ================================================
-- CONSTRAINT: Validação de Status
-- ================================================

ALTER TABLE public.convites_pendentes
ADD CONSTRAINT check_convite_status 
CHECK (status IN ('pendente', 'aceito', 'expirado', 'cancelado'));

-- ================================================
-- CONSTRAINT: Validação de Papel
-- ================================================

ALTER TABLE public.convites_pendentes
ADD CONSTRAINT check_convite_papel 
CHECK (papel IN ('super_admin', 'admin', 'gerente', 'operador', 'usuario'));

-- ================================================
-- FIM DA MIGRATION
-- ================================================

