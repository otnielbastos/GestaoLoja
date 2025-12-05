-- ================================================
-- MIGRATION 07: Criar Tabela USUARIOS_EMPRESAS
-- Data: 05/12/2025
-- Descrição: Relacionamento entre usuários e empresas (N:N)
--            Um usuário pode estar em várias empresas
--            Uma empresa pode ter vários usuários
-- ================================================

-- Tabela: usuarios_empresas
CREATE TABLE IF NOT EXISTS public.usuarios_empresas (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamentos
    usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
    
    -- Papel/Permissão na Empresa
    papel VARCHAR(50) NOT NULL DEFAULT 'usuario', -- super_admin, admin, gerente, operador, usuario
    
    -- Filiais com Acesso (se NULL = acesso a todas)
    filiais_acesso UUID[], -- Array de IDs de filiais que o usuário pode acessar
    acesso_todas_filiais BOOLEAN DEFAULT true, -- Se true, ignora filiais_acesso
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, inactive, suspended
    
    -- Permissões Personalizadas (JSON)
    permissoes_customizadas JSONB DEFAULT '{}'::jsonb,
    
    -- Dados de Convite
    convidado_por UUID REFERENCES auth.users(id), -- Quem convidou este usuário
    data_convite TIMESTAMP WITH TIME ZONE,
    data_aceitacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE -- Soft delete
);

-- ================================================
-- ÍNDICES
-- ================================================

-- IMPORTANTE: Um usuário pode estar em apenas UMA empresa por vez
-- (simplifica lógica, mas permite futuro multi-empresa)
CREATE UNIQUE INDEX idx_usuarios_empresas_unique 
ON public.usuarios_empresas(usuario_id, empresa_id) 
WHERE deleted_at IS NULL;

-- Índice para buscar usuários de uma empresa
CREATE INDEX idx_usuarios_empresas_empresa 
ON public.usuarios_empresas(empresa_id) 
WHERE deleted_at IS NULL;

-- Índice para buscar empresas de um usuário
CREATE INDEX idx_usuarios_empresas_usuario 
ON public.usuarios_empresas(usuario_id) 
WHERE deleted_at IS NULL;

-- Índice para filtrar por papel
CREATE INDEX idx_usuarios_empresas_papel 
ON public.usuarios_empresas(empresa_id, papel) 
WHERE deleted_at IS NULL;

-- Índice para usuários ativos
CREATE INDEX idx_usuarios_empresas_active 
ON public.usuarios_empresas(empresa_id, status) 
WHERE status = 'active' AND deleted_at IS NULL;

-- ================================================
-- TRIGGER: updated_at automático
-- ================================================

CREATE TRIGGER set_updated_at_usuarios_empresas
    BEFORE UPDATE ON public.usuarios_empresas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- FUNÇÕES AUXILIARES
-- ================================================

-- Função: Verificar se usuário tem papel específico
CREATE OR REPLACE FUNCTION user_has_papel(
    p_usuario_id UUID,
    p_empresa_id UUID,
    p_papel VARCHAR
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.usuarios_empresas
        WHERE usuario_id = p_usuario_id
        AND empresa_id = p_empresa_id
        AND papel = p_papel
        AND status = 'active'
        AND deleted_at IS NULL
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função: Verificar se usuário é admin da empresa
CREATE OR REPLACE FUNCTION user_is_admin(
    p_usuario_id UUID,
    p_empresa_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.usuarios_empresas
        WHERE usuario_id = p_usuario_id
        AND empresa_id = p_empresa_id
        AND papel IN ('admin', 'super_admin')
        AND status = 'active'
        AND deleted_at IS NULL
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função: Obter empresa_id do usuário atual
CREATE OR REPLACE FUNCTION get_current_empresa_id()
RETURNS UUID AS $$
DECLARE
    v_empresa_id UUID;
BEGIN
    -- Buscar empresa_id do usuário autenticado
    SELECT empresa_id INTO v_empresa_id
    FROM public.usuarios_empresas
    WHERE usuario_id = auth.uid()
    AND status = 'active'
    AND deleted_at IS NULL
    LIMIT 1;
    
    RETURN v_empresa_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função: Obter filiais com acesso do usuário
CREATE OR REPLACE FUNCTION get_user_filiais_acesso()
RETURNS UUID[] AS $$
DECLARE
    v_filiais UUID[];
    v_acesso_todas BOOLEAN;
BEGIN
    -- Buscar configuração de acesso
    SELECT filiais_acesso, acesso_todas_filiais 
    INTO v_filiais, v_acesso_todas
    FROM public.usuarios_empresas
    WHERE usuario_id = auth.uid()
    AND status = 'active'
    AND deleted_at IS NULL
    LIMIT 1;
    
    -- Se tem acesso a todas, retornar NULL (significa todas)
    IF v_acesso_todas THEN
        RETURN NULL;
    ELSE
        RETURN v_filiais;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================
-- COMENTÁRIOS (Documentação)
-- ================================================

COMMENT ON TABLE public.usuarios_empresas IS 'Relacionamento N:N entre usuários e empresas';
COMMENT ON COLUMN public.usuarios_empresas.papel IS 'Papel do usuário: super_admin, admin, gerente, operador, usuario';
COMMENT ON COLUMN public.usuarios_empresas.filiais_acesso IS 'Array de IDs de filiais com acesso (NULL = todas)';
COMMENT ON COLUMN public.usuarios_empresas.acesso_todas_filiais IS 'Se true, usuário tem acesso a todas as filiais';
COMMENT ON COLUMN public.usuarios_empresas.permissoes_customizadas IS 'Permissões específicas em JSON';

-- ================================================
-- GRANT PERMISSIONS
-- ================================================

GRANT ALL ON public.usuarios_empresas TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.usuarios_empresas TO authenticated;

-- Permissões para as funções auxiliares
GRANT EXECUTE ON FUNCTION user_has_papel TO authenticated;
GRANT EXECUTE ON FUNCTION user_is_admin TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_empresa_id TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_filiais_acesso TO authenticated;

-- ================================================
-- CONSTRAINT: Validação de Status
-- ================================================

ALTER TABLE public.usuarios_empresas
ADD CONSTRAINT check_usuario_empresa_status 
CHECK (status IN ('active', 'inactive', 'suspended'));

-- ================================================
-- CONSTRAINT: Validação de Papel
-- ================================================

ALTER TABLE public.usuarios_empresas
ADD CONSTRAINT check_usuario_empresa_papel 
CHECK (papel IN ('super_admin', 'admin', 'gerente', 'operador', 'usuario'));

-- ================================================
-- FIM DA MIGRATION
-- ================================================

