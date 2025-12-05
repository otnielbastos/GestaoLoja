# Plano de Implementação Multi-Tenant - GestaoLoja
## Guia Completo Step-by-Step

## 📋 ÍNDICE

1. [Visão Geral da Implementação](#visão-geral-da-implementação)
2. [Fase 1: Preparação e Planejamento](#fase-1-preparação-e-planejamento)
3. [Fase 2: Migração do Banco de Dados](#fase-2-migração-do-banco-de-dados)
4. [Fase 3: Implementação de Autenticação](#fase-3-implementação-de-autenticação)
5. [Fase 4: Implementação de RLS](#fase-4-implementação-de-rls)
6. [Fase 5: Refatoração do Frontend](#fase-5-refatoração-do-frontend)
7. [Fase 6: Sistema de Planos e Limites](#fase-6-sistema-de-planos-e-limites)
8. [Fase 7: Testes e QA](#fase-7-testes-e-qa)
9. [Fase 8: Migração de Dados Existentes](#fase-8-migração-de-dados-existentes)
10. [Fase 9: Deploy e Go-Live](#fase-9-deploy-e-go-live)
11. [Fase 10: Pós-Launch](#fase-10-pós-launch)

---

## 🎯 VISÃO GERAL DA IMPLEMENTAÇÃO

### Cronograma Estimado

```
┌─────────────────────────────────────────────────────────────┐
│                   CRONOGRAMA DO PROJETO                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Fase 1: Preparação              [2 semanas]   ████████    │
│  Fase 2: Banco de Dados          [3 semanas]   ████████████│
│  Fase 3: Autenticação            [2 semanas]   ████████    │
│  Fase 4: RLS                     [2 semanas]   ████████    │
│  Fase 5: Frontend                [4 semanas]   ████████████████│
│  Fase 6: Planos e Limites        [2 semanas]   ████████    │
│  Fase 7: Testes                  [2 semanas]   ████████    │
│  Fase 8: Migração de Dados       [1 semana]    ████        │
│  Fase 9: Deploy                  [1 semana]    ████        │
│  Fase 10: Pós-Launch             [Contínuo]    ∞           │
│                                                             │
│  TOTAL ESTIMADO: 19 semanas (~4,5 meses)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Equipe Recomendada

- **1 Arquiteto/Tech Lead** - Tempo integral
- **2 Desenvolvedores Full-Stack** - Tempo integral  
- **1 DevOps Engineer** - Meio período
- **1 QA Engineer** - Tempo integral (últimas 4 semanas)
- **1 Product Owner** - Meio período

### Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Vazamento de dados entre tenants | Média | Alto | Testes rigorosos de RLS, code review |
| Performance degradada | Alta | Médio | Índices adequados, monitoramento |
| Migração de dados com problemas | Média | Alto | Backup completo, ambiente de teste |
| Complexidade subestimada | Média | Alto | Buffer de 20% no cronograma |
| Resistência dos usuários atuais | Baixa | Médio | Comunicação clara, training |

---

## FASE 1: PREPARAÇÃO E PLANEJAMENTO

**Duração:** 2 semanas  
**Responsável:** Arquiteto + Product Owner

### Semana 1: Análise e Documentação

#### Dia 1-2: Análise Completa do Sistema Atual

```bash
# Tarefas:
□ Revisar toda a documentação existente
□ Mapear todas as tabelas e relacionamentos
□ Identificar todas as queries que precisam ser modificadas
□ Listar todos os serviços que acessam o banco
□ Documentar fluxos críticos de negócio
□ Identificar dependências externas

# Entregáveis:
- Documento de Análise Técnica Completa
- Mapa de Dependências
- Lista de Riscos Técnicos
```

#### Dia 3-4: Planejamento da Arquitetura

```bash
# Tarefas:
□ Definir estrutura de tabelas multi-tenant
□ Planejar estratégia de RLS
□ Desenhar fluxos de autenticação
□ Definir estrutura de permissões
□ Planejar sistema de limites
□ Criar diagramas de arquitetura

# Entregáveis:
- Diagrama de Arquitetura (C4 Model)
- Especificação de Banco de Dados
- Documento de Decisões Arquiteturais (ADRs)
```

#### Dia 5: Planejamento de Migração

```bash
# Tarefas:
□ Estratégia para migrar dados existentes
□ Plano de rollback
□ Definir estratégia de downtime (se houver)
□ Planejar comunicação com usuários
□ Preparar ambiente de testes

# Entregáveis:
- Plano de Migração Detalhado
- Script de Backup
- Plano de Comunicação
```

### Semana 2: Setup do Ambiente

#### Dia 1-3: Preparação de Ambientes

```bash
# Criar ambientes separados
1. Desenvolvimento Local
   □ Supabase Local configurado
   □ Banco de dados de desenvolvimento
   □ Variáveis de ambiente configuradas
   □ Git branches criados

2. Staging/Homologação
   □ Projeto Supabase criado
   □ Banco de dados staging
   □ CI/CD configurado
   □ Domínio staging configurado

3. Produção (preparação)
   □ Projeto Supabase criado
   □ Backup automático configurado
   □ Monitoramento configurado
   □ Domínio configurado
```

#### Dia 4-5: Setup de Ferramentas

```bash
# Ferramentas e Processos
□ Configurar Migrations com Supabase CLI
□ Setup de testes automatizados
□ Configurar monitoramento (Sentry, LogRocket, etc)
□ Setup de CI/CD (GitHub Actions ou similar)
□ Configurar lint e formatação
□ Documentação no Notion/Confluence

# Entregáveis:
- Ambientes prontos para desenvolvimento
- Pipeline de CI/CD funcional
- Documentação de setup
```

---

## FASE 2: MIGRAÇÃO DO BANCO DE DADOS

**Duração:** 3 semanas  
**Responsável:** Tech Lead + Desenvolvedor Backend

### Semana 1: Criação de Novas Tabelas

#### Script de Migration Completo

```sql
-- Migration: 04_add_multitenancy_structure.sql

-- ============================================
-- NOVAS TABELAS
-- ============================================

-- 1. Tabela de Planos
CREATE TABLE planos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    tipo VARCHAR(20) DEFAULT 'mensal',
    preco_mensal DECIMAL(10,2),
    preco_anual DECIMAL(10,2),
    desconto_anual DECIMAL(5,2),
    moeda VARCHAR(3) DEFAULT 'BRL',
    max_usuarios INTEGER DEFAULT 5,
    max_filiais INTEGER DEFAULT 1,
    max_produtos INTEGER DEFAULT 100,
    max_clientes INTEGER,
    max_pedidos_mes INTEGER,
    storage_gb INTEGER DEFAULT 1,
    features JSONB DEFAULT '[]'::jsonb,
    modulos_disponiveis JSONB DEFAULT '[]'::jsonb,
    ativo BOOLEAN DEFAULT TRUE,
    publico BOOLEAN DEFAULT TRUE,
    ordem_exibicao INTEGER DEFAULT 0,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabela de Empresas (Tenants)
CREATE TABLE empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    website VARCHAR(255),
    
    -- Endereço
    endereco_rua VARCHAR(255),
    endereco_numero VARCHAR(20),
    endereco_complemento VARCHAR(100),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100),
    endereco_estado CHAR(2),
    endereco_cep VARCHAR(10),
    
    -- Configurações e Personalização
    configuracoes JSONB DEFAULT '{}'::jsonb,
    personalizacao JSONB DEFAULT '{}'::jsonb,
    
    -- Assinatura
    plano_id UUID REFERENCES planos(id),
    data_assinatura TIMESTAMP WITH TIME ZONE,
    data_expiracao TIMESTAMP WITH TIME ZONE,
    status_assinatura VARCHAR(20) DEFAULT 'trial',
    limites JSONB DEFAULT '{}'::jsonb,
    
    -- Controle
    ativo BOOLEAN DEFAULT TRUE,
    bloqueado BOOLEAN DEFAULT FALSE,
    motivo_bloqueio TEXT,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por UUID,
    
    -- Segurança
    configuracoes_seguranca JSONB DEFAULT '{
        "requer_2fa": false,
        "tempo_expiracao_sessao": 480,
        "max_tentativas_login": 5,
        "tempo_bloqueio_login": 30
    }'::jsonb
);

-- 3. Tabela de Filiais
CREATE TABLE filiais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    nome VARCHAR(255) NOT NULL,
    codigo VARCHAR(50),
    tipo VARCHAR(50) DEFAULT 'loja',
    
    cnpj VARCHAR(18),
    inscricao_estadual VARCHAR(20),
    inscricao_municipal VARCHAR(20),
    
    email VARCHAR(255),
    telefone VARCHAR(20),
    telefone_2 VARCHAR(20),
    
    -- Endereço
    endereco_rua VARCHAR(255) NOT NULL,
    endereco_numero VARCHAR(20),
    endereco_complemento VARCHAR(100),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100) NOT NULL,
    endereco_estado CHAR(2) NOT NULL,
    endereco_cep VARCHAR(10),
    coordenadas_gps POINT,
    
    configuracoes JSONB DEFAULT '{}'::jsonb,
    horario_funcionamento JSONB,
    
    ativo BOOLEAN DEFAULT TRUE,
    eh_matriz BOOLEAN DEFAULT FALSE,
    ordem_exibicao INTEGER DEFAULT 0,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por UUID,
    
    UNIQUE(empresa_id, codigo),
    UNIQUE(empresa_id, cnpj)
);

-- 4. Tabela de Relacionamento Usuários <-> Empresas
CREATE TABLE usuarios_empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    papel VARCHAR(50) DEFAULT 'usuario',
    filiais_acesso UUID[] DEFAULT ARRAY[]::UUID[],
    acesso_todas_filiais BOOLEAN DEFAULT FALSE,
    
    ativo BOOLEAN DEFAULT TRUE,
    convite_aceito BOOLEAN DEFAULT FALSE,
    data_convite TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_aceite TIMESTAMP WITH TIME ZONE,
    convite_token VARCHAR(255),
    convite_expira TIMESTAMP WITH TIME ZONE,
    
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    convidado_por INTEGER REFERENCES usuarios(id),
    
    UNIQUE(usuario_id, empresa_id)
);

-- 5. Tabela de Limites de Uso
CREATE TABLE limites_uso (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    mes_referencia DATE NOT NULL,
    
    total_usuarios INTEGER DEFAULT 0,
    total_filiais INTEGER DEFAULT 0,
    total_produtos INTEGER DEFAULT 0,
    total_clientes INTEGER DEFAULT 0,
    total_pedidos_mes INTEGER DEFAULT 0,
    storage_usado_gb DECIMAL(10,2) DEFAULT 0,
    total_chamadas_api INTEGER DEFAULT 0,
    
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(empresa_id, mes_referencia)
);

-- 6. Tabela de Histórico de Assinaturas
CREATE TABLE historico_assinaturas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    plano_anterior_id UUID REFERENCES planos(id),
    plano_novo_id UUID REFERENCES planos(id),
    tipo_mudanca VARCHAR(50),
    
    valor_antigo DECIMAL(10,2),
    valor_novo DECIMAL(10,2),
    
    data_mudanca TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    motivo TEXT,
    realizado_por INTEGER REFERENCES usuarios(id)
);

-- 7. Tabela de Convites Pendentes
CREATE TABLE convites_pendentes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    email VARCHAR(255) NOT NULL,
    perfil_id INTEGER REFERENCES perfis(id),
    papel VARCHAR(50) DEFAULT 'usuario',
    filiais_acesso UUID[],
    
    token VARCHAR(255) NOT NULL UNIQUE,
    data_expiracao TIMESTAMP WITH TIME ZONE NOT NULL,
    
    status VARCHAR(20) DEFAULT 'pendente',
    data_aceite TIMESTAMP WITH TIME ZONE,
    
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por INTEGER REFERENCES usuarios(id),
    mensagem_personalizada TEXT
);

-- ============================================
-- ÍNDICES
-- ============================================

-- Planos
CREATE INDEX idx_planos_ativo ON planos(ativo);
CREATE INDEX idx_planos_publico ON planos(publico);

-- Empresas
CREATE INDEX idx_empresas_cnpj ON empresas(cnpj);
CREATE INDEX idx_empresas_status ON empresas(status_assinatura);
CREATE INDEX idx_empresas_plano ON empresas(plano_id);
CREATE INDEX idx_empresas_ativo ON empresas(ativo);

-- Filiais
CREATE INDEX idx_filiais_empresa ON filiais(empresa_id);
CREATE INDEX idx_filiais_ativo ON filiais(ativo);
CREATE INDEX idx_filiais_tipo ON filiais(tipo);
CREATE INDEX idx_filiais_matriz ON filiais(empresa_id, eh_matriz) WHERE eh_matriz = true;
CREATE UNIQUE INDEX idx_filiais_uma_matriz_por_empresa ON filiais(empresa_id) WHERE eh_matriz = true;

-- Usuários-Empresas
CREATE INDEX idx_usuarios_empresas_usuario ON usuarios_empresas(usuario_id);
CREATE INDEX idx_usuarios_empresas_empresa ON usuarios_empresas(empresa_id);
CREATE INDEX idx_usuarios_empresas_ativo ON usuarios_empresas(ativo);

-- Limites de Uso
CREATE INDEX idx_limites_uso_empresa ON limites_uso(empresa_id);
CREATE INDEX idx_limites_uso_mes ON limites_uso(mes_referencia);

-- Histórico de Assinaturas
CREATE INDEX idx_historico_assinaturas_empresa ON historico_assinaturas(empresa_id);
CREATE INDEX idx_historico_assinaturas_data ON historico_assinaturas(data_mudanca);

-- Convites
CREATE INDEX idx_convites_empresa ON convites_pendentes(empresa_id);
CREATE INDEX idx_convites_email ON convites_pendentes(email);
CREATE INDEX idx_convites_token ON convites_pendentes(token);
CREATE INDEX idx_convites_status ON convites_pendentes(status);

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger para atualizar data_atualizacao
CREATE TRIGGER trigger_update_empresas_timestamp
    BEFORE UPDATE ON empresas
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_filiais_timestamp
    BEFORE UPDATE ON filiais
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_planos_timestamp
    BEFORE UPDATE ON planos
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON TABLE empresas IS 'Tabela central do multi-tenancy - cada empresa é um tenant isolado';
COMMENT ON TABLE filiais IS 'Filiais/unidades de cada empresa - permite gestão multi-loja';
COMMENT ON TABLE usuarios_empresas IS 'Relacionamento many-to-many entre usuários e empresas';
COMMENT ON TABLE limites_uso IS 'Controle mensal de uso dos recursos por empresa';
COMMENT ON TABLE planos IS 'Planos de assinatura do SaaS com limites e features';
```

### Semana 2: Modificação de Tabelas Existentes

```sql
-- Migration: 05_add_tenant_columns.sql

-- ============================================
-- ADICIONAR COLUNAS DE TENANT
-- ============================================

-- Tabela: usuarios
ALTER TABLE usuarios 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE SET NULL,
ADD COLUMN filial_padrao_id UUID REFERENCES filiais(id) ON DELETE SET NULL,
ADD COLUMN auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE INDEX idx_usuarios_empresa ON usuarios(empresa_id);
CREATE INDEX idx_usuarios_filial_padrao ON usuarios(filial_padrao_id);
CREATE INDEX idx_usuarios_auth ON usuarios(auth_user_id);

-- Tabela: clientes
ALTER TABLE clientes 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID REFERENCES filiais(id) ON DELETE SET NULL;

CREATE INDEX idx_clientes_empresa ON clientes(empresa_id);
CREATE INDEX idx_clientes_filial ON clientes(filial_id);

-- Tabela: produtos
ALTER TABLE produtos 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;

CREATE INDEX idx_produtos_empresa ON produtos(empresa_id);

-- Tabela: estoque (IMPORTANTE: Muda para ser POR FILIAL)
ALTER TABLE estoque 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID REFERENCES filiais(id) ON DELETE CASCADE;

CREATE INDEX idx_estoque_empresa ON estoque(empresa_id);
CREATE INDEX idx_estoque_filial ON estoque(filial_id);

-- Adicionar constraint: Um produto só pode ter um registro de estoque por filial
ALTER TABLE estoque 
DROP CONSTRAINT IF EXISTS estoque_produto_id_key,
ADD CONSTRAINT unique_produto_filial UNIQUE(produto_id, filial_id);

-- Tabela: pedidos
ALTER TABLE pedidos 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID REFERENCES filiais(id) ON DELETE CASCADE;

CREATE INDEX idx_pedidos_empresa ON pedidos(empresa_id);
CREATE INDEX idx_pedidos_filial ON pedidos(filial_id);

-- Tabela: entregas
ALTER TABLE entregas 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID REFERENCES filiais(id) ON DELETE SET NULL;

CREATE INDEX idx_entregas_empresa ON entregas(empresa_id);
CREATE INDEX idx_entregas_filial ON entregas(filial_id);

-- Tabela: movimentacoes_estoque
ALTER TABLE movimentacoes_estoque 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID REFERENCES filiais(id) ON DELETE CASCADE;

CREATE INDEX idx_movimentacoes_empresa ON movimentacoes_estoque(empresa_id);
CREATE INDEX idx_movimentacoes_filial ON movimentacoes_estoque(filial_id);

-- Tabela: auditoria
ALTER TABLE auditoria 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;

CREATE INDEX idx_auditoria_empresa ON auditoria(empresa_id);

-- Tabela: perfis (permitir perfis globais e por empresa)
ALTER TABLE perfis 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN eh_global BOOLEAN DEFAULT FALSE;

CREATE INDEX idx_perfis_empresa ON perfis(empresa_id);
CREATE INDEX idx_perfis_global ON perfis(eh_global) WHERE eh_global = true;

-- Comentários
COMMENT ON COLUMN estoque.filial_id IS 'Estoque agora é por filial - cada filial tem controle independente';
COMMENT ON COLUMN perfis.eh_global IS 'Perfis globais (sistema) vs perfis customizados por empresa';
```

### Semana 3: Dados Iniciais e Funções

```sql
-- Migration: 06_seed_initial_data.sql

-- ============================================
-- INSERIR PLANOS INICIAIS
-- ============================================

INSERT INTO planos (nome, descricao, preco_mensal, preco_anual, desconto_anual, max_usuarios, max_filiais, max_produtos, max_pedidos_mes, storage_gb, features, ordem_exibicao) VALUES
('Trial', 'Plano de teste gratuito por 14 dias', 0, 0, 0, 2, 1, 50, 50, 0.5, 
 '["suporte_email"]'::jsonb, 0),
 
('Starter', 'Ideal para pequenos negócios', 97.00, 970.00, 17, 5, 1, 500, NULL, 2,
 '["suporte_email", "backup_diario", "relatorios_basicos"]'::jsonb, 1),
 
('Professional', 'Para empresas em crescimento', 197.00, 1970.00, 17, 15, 5, 2000, NULL, 10,
 '["suporte_prioritario", "backup_diario", "relatorios_avancados", "api_acesso", "multi_filiais"]'::jsonb, 2),
 
('Enterprise', 'Para grandes operações', 497.00, 4970.00, 17, NULL, NULL, NULL, NULL, 50,
 '["suporte_dedicado", "backup_horario", "relatorios_customizados", "api_ilimitada", "white_label", "sla_garantido"]'::jsonb, 3);

-- ============================================
-- MARCAR PERFIS EXISTENTES COMO GLOBAIS
-- ============================================

UPDATE perfis SET eh_global = true WHERE empresa_id IS NULL;

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

-- Função para obter empresa_id do contexto
CREATE OR REPLACE FUNCTION get_current_empresa_id()
RETURNS UUID AS $$
  SELECT 
    COALESCE(
      current_setting('app.current_empresa_id', TRUE)::UUID,
      (
        SELECT empresa_id 
        FROM usuarios 
        WHERE auth_user_id = auth.uid() 
        LIMIT 1
      )
    );
$$ LANGUAGE SQL STABLE;

-- Função para obter filiais que o usuário tem acesso
CREATE OR REPLACE FUNCTION get_user_filiais_acesso()
RETURNS UUID[] AS $$
  SELECT 
    CASE 
      WHEN ue.acesso_todas_filiais THEN 
        ARRAY(SELECT id FROM filiais WHERE empresa_id = ue.empresa_id AND ativo = true)
      ELSE 
        ue.filiais_acesso
    END
  FROM usuarios_empresas ue
  JOIN usuarios u ON u.id = ue.usuario_id
  WHERE u.auth_user_id = auth.uid() 
    AND ue.empresa_id = get_current_empresa_id()
    AND ue.ativo = true
  LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- Função para verificar papel do usuário
CREATE OR REPLACE FUNCTION user_has_papel(papel_required TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 
    FROM usuarios_empresas ue
    JOIN usuarios u ON u.id = ue.usuario_id
    WHERE u.auth_user_id = auth.uid()
      AND ue.empresa_id = get_current_empresa_id()
      AND ue.papel = papel_required
      AND ue.ativo = true
  );
$$ LANGUAGE SQL STABLE;

-- Função RPC para setar contexto da empresa
CREATE OR REPLACE FUNCTION set_config(setting TEXT, value TEXT)
RETURNS VOID AS $$
BEGIN
  PERFORM set_config(setting, value, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar usuário quando criar no auth
CREATE OR REPLACE FUNCTION handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.usuarios (auth_user_id, email, nome, ativo)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'nome', NEW.email), 
    TRUE
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================
-- VIEWS AUXILIARES
-- ============================================

-- View para estoque completo com filiais
CREATE OR REPLACE VIEW vw_estoque_filial AS
SELECT 
    p.id AS produto_id,
    p.empresa_id,
    p.nome AS produto_nome,
    p.categoria,
    p.unidade_medida,
    p.quantidade_minima,
    f.id AS filial_id,
    f.nome AS filial_nome,
    COALESCE(e.quantidade_atual, 0) AS quantidade_atual,
    COALESCE(e.quantidade_pronta_entrega, 0) AS quantidade_pronta_entrega,
    COALESCE(e.quantidade_encomenda, 0) AS quantidade_encomenda,
    e.ultima_atualizacao
FROM produtos p
CROSS JOIN filiais f
LEFT JOIN estoque e ON p.id = e.produto_id AND f.id = e.filial_id
WHERE p.status = 'ativo' 
  AND f.ativo = true
  AND p.empresa_id = f.empresa_id;
```

---

## FASE 3: IMPLEMENTAÇÃO DE AUTENTICAÇÃO

**Duração:** 2 semanas  
**Responsável:** Tech Lead + Desenvolvedor Full-Stack

### Semana 1: Migração para Supabase Auth

```typescript
// src/services/authSupabase.ts

import { supabase } from '../lib/supabase';

interface SignUpData {
  email: string;
  password: string;
  nome: string;
  empresaData?: {
    nome: string;
    razao_social: string;
    cnpj: string;
    email: string;
  };
}

class AuthSupabaseService {
  
  // Cadastro de nova empresa (Sign Up)
  async signUp(data: SignUpData) {
    try {
      // 1. Criar plano trial
      const { data: planoTrial } = await supabase
        .from('planos')
        .select('*')
        .eq('nome', 'Trial')
        .single();
      
      // 2. Criar empresa
      const { data: empresa, error: empresaError } = await supabase
        .from('empresas')
        .insert({
          nome: data.empresaData!.nome,
          razao_social: data.empresaData!.razao_social,
          cnpj: data.empresaData!.cnpj,
          email: data.empresaData!.email,
          plano_id: planoTrial!.id,
          status_assinatura: 'trial',
          data_assinatura: new Date().toISOString(),
          // Trial expira em 14 dias
          data_expiracao: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString(),
          limites: planoTrial!
        })
        .select()
        .single();
      
      if (empresaError) throw empresaError;
      
      // 3. Criar filial matriz
      const { data: filialMatriz, error: filialError } = await supabase
        .from('filiais')
        .insert({
          empresa_id: empresa.id,
          nome: 'Matriz',
          codigo: 'MATRIZ',
          tipo: 'loja',
          eh_matriz: true,
          ativo: true,
          endereco_cidade: data.empresaData!.cidade || 'N/A',
          endereco_estado: data.empresaData!.estado || 'N/A',
          endereco_rua: ''
        })
        .select()
        .single();
      
      if (filialError) throw filialError;
      
      // 4. Criar usuário no Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: data.email,
        password: data.password,
        options: {
          data: {
            nome: data.nome,
            empresa_id: empresa.id
          }
        }
      });
      
      if (authError) throw authError;
      
      // 5. Aguardar trigger criar o usuário na tabela usuarios
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // 6. Buscar usuário criado
      const { data: usuario } = await supabase
        .from('usuarios')
        .select('*')
        .eq('auth_user_id', authData.user!.id)
        .single();
      
      // 7. Vincular usuário à empresa como proprietário
      await supabase
        .from('usuarios_empresas')
        .insert({
          usuario_id: usuario!.id,
          empresa_id: empresa.id,
          papel: 'proprietario',
          acesso_todas_filiais: true,
          convite_aceito: true,
          data_aceite: new Date().toISOString()
        });
      
      // 8. Atribuir perfil Administrador
      const { data: perfilAdmin } = await supabase
        .from('perfis')
        .select('*')
        .eq('nome', 'Administrador')
        .eq('eh_global', true)
        .single();
      
      await supabase
        .from('usuarios')
        .update({ 
          perfil_id: perfilAdmin!.id,
          empresa_id: empresa.id,
          filial_padrao_id: filialMatriz.id
        })
        .eq('id', usuario!.id);
      
      return {
        success: true,
        user: authData.user,
        empresa,
        filial: filialMatriz
      };
      
    } catch (error: any) {
      console.error('Erro no cadastro:', error);
      throw error;
    }
  }

  // Login
  async signIn(email: string, password: string) {
    try {
      // 1. Login no Supabase Auth
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });
      
      if (error) throw error;
      
      // 2. Buscar dados do usuário
      const { data: usuario } = await supabase
        .from('usuarios')
        .select(`
          *,
          perfil:perfis(*),
          empresa:empresas(*)
        `)
        .eq('auth_user_id', data.user.id)
        .single();
      
      // 3. Buscar empresas do usuário
      const { data: empresas } = await supabase
        .from('usuarios_empresas')
        .select(`
          *,
          empresa:empresas(*)
        `)
        .eq('usuario_id', usuario!.id)
        .eq('ativo', true);
      
      // 4. Se usuário tem múltiplas empresas, retornar para escolha
      if (empresas!.length > 1) {
        return {
          success: true,
          requireCompanySelection: true,
          user: data.user,
          companies: empresas!.map(e => e.empresa)
        };
      }
      
      // 5. Setar empresa padrão
      const empresaSelecionada = empresas![0].empresa;
      await this.setEmpresaContext(empresaSelecionada.id);
      
      // 6. Buscar filiais
      const { data: filiais } = await supabase
        .from('filiais')
        .select('*')
        .eq('empresa_id', empresaSelecionada.id)
        .eq('ativo', true)
        .order('ordem_exibicao');
      
      return {
        success: true,
        user: data.user,
        usuario: usuario,
        empresa: empresaSelecionada,
        filiais: filiais || []
      };
      
    } catch (error: any) {
      console.error('Erro no login:', error);
      throw error;
    }
  }

  // Setar contexto da empresa
  async setEmpresaContext(empresaId: string) {
    await supabase.rpc('set_config', {
      setting: 'app.current_empresa_id',
      value: empresaId
    });
  }

  // Logout
  async signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    
    // Limpar localStorage
    localStorage.removeItem('empresaAtualId');
    localStorage.removeItem('filialAtualId');
  }

  // Obter sessão atual
  async getSession() {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;
    return data.session;
  }

  // Verificar se está autenticado
  isAuthenticated() {
    const session = supabase.auth.getSession();
    return !!session;
  }
}

export const authSupabaseService = new AuthSupabaseService();
```

### Semana 2: Atualização dos Contexts

```typescript
// src/contexts/AuthContext.tsx

import React, { createContext, useContext, useState, useEffect } from 'react';
import { User as SupabaseUser } from '@supabase/supabase-js';
import { authSupabaseService } from '../services/authSupabase';
import { supabase } from '../lib/supabase';

interface User {
  id: string;
  email: string;
  nome: string;
  perfil: any;
  empresa: any;
}

interface AuthContextType {
  user: User | null;
  supabaseUser: SupabaseUser | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<any>;
  logout: () => Promise<void>;
  signUp: (data: any) => Promise<any>;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [supabaseUser, setSupabaseUser] = useState<SupabaseUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Verificar sessão ao carregar
    const checkSession = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (session) {
          setSupabaseUser(session.user);
          await loadUserData(session.user.id);
        }
      } catch (error) {
        console.error('Erro ao verificar sessão:', error);
      } finally {
        setIsLoading(false);
      }
    };

    checkSession();

    // Listener para mudanças de autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('Auth state changed:', event);
        
        if (session) {
          setSupabaseUser(session.user);
          await loadUserData(session.user.id);
        } else {
          setSupabaseUser(null);
          setUser(null);
        }
      }
    );

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const loadUserData = async (authUserId: string) => {
    const { data: usuario } = await supabase
      .from('usuarios')
      .select(`
        *,
        perfil:perfis(*),
        empresa:empresas(*)
      `)
      .eq('auth_user_id', authUserId)
      .single();
    
    if (usuario) {
      setUser(usuario as User);
    }
  };

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const result = await authSupabaseService.signIn(email, password);
      
      if (result.requireCompanySelection) {
        return result;
      }
      
      setUser(result.usuario);
      setSupabaseUser(result.user);
      
      return result;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    await authSupabaseService.signOut();
    setUser(null);
    setSupabaseUser(null);
  };

  const signUp = async (data: any) => {
    setIsLoading(true);
    try {
      return await authSupabaseService.signUp(data);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AuthContext.Provider value={{
      user,
      supabaseUser,
      isLoading,
      isAuthenticated: !!user,
      login,
      logout,
      signUp
    }}>
      {children}
    </AuthContext.Provider>
  );
};
```

```typescript
// src/contexts/EmpresaContext.tsx

import React, { createContext, useContext, useState, useEffect } from 'react';
import { useAuth } from './AuthContext';
import { supabase } from '../lib/supabase';
import { authSupabaseService } from '../services/authSupabase';

interface Empresa {
  id: string;
  nome: string;
  razao_social: string;
  cnpj: string;
  // ... outros campos
}

interface Filial {
  id: string;
  nome: string;
  codigo: string;
  eh_matriz: boolean;
  // ... outros campos
}

interface EmpresaContextType {
  empresaAtual: Empresa | null;
  filialAtual: Filial | null;
  empresas: Empresa[];
  filiais: Filial[];
  trocarEmpresa: (empresaId: string) => Promise<void>;
  trocarFilial: (filialId: string) => void;
  loading: boolean;
}

const EmpresaContext = createContext<EmpresaContextType | null>(null);

export const useEmpresa = () => {
  const context = useContext(EmpresaContext);
  if (!context) throw new Error('useEmpresa must be used within EmpresaProvider');
  return context;
};

export const EmpresaProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user, supabaseUser } = useAuth();
  const [empresaAtual, setEmpresaAtual] = useState<Empresa | null>(null);
  const [filialAtual, setFilialAtual] = useState<Filial | null>(null);
  const [empresas, setEmpresas] = useState<Empresa[]>([]);
  const [filiais, setFiliais] = useState<Filial[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      carregarEmpresasUsuario();
    } else {
      setEmpresaAtual(null);
      setFilialAtual(null);
      setEmpresas([]);
      setFiliais([]);
    }
  }, [user]);

  const carregarEmpresasUsuario = async () => {
    try {
      setLoading(true);
      
      // Buscar empresas do usuário
      const { data: usuarioEmpresas } = await supabase
        .from('usuarios_empresas')
        .select('empresa:empresas(*)')
        .eq('usuario_id', user!.id)
        .eq('ativo', true);
      
      const empresasData = usuarioEmpresas!.map(ue => ue.empresa);
      setEmpresas(empresasData);
      
      // Setar empresa padrão
      const empresaPadrao = user!.empresa || empresasData[0];
      if (empresaPadrao) {
        await trocarEmpresa(empresaPadrao.id);
      }
    } catch (error) {
      console.error('Erro ao carregar empresas:', error);
    } finally {
      setLoading(false);
    }
  };

  const trocarEmpresa = async (empresaId: string) => {
    try {
      // Buscar empresa
      const { data: empresa } = await supabase
        .from('empresas')
        .select('*')
        .eq('id', empresaId)
        .single();
      
      setEmpresaAtual(empresa);
      
      // Setar contexto no Supabase
      await authSupabaseService.setEmpresaContext(empresaId);
      
      // Buscar filiais
      const { data: filiaisData } = await supabase
        .from('filiais')
        .select('*')
        .eq('empresa_id', empresaId)
        .eq('ativo', true)
        .order('ordem_exibicao');
      
      setFiliais(filiaisData || []);
      
      // Setar filial padrão
      const filialPadrao = filiaisData!.find(f => f.eh_matriz) || filiaisData![0];
      setFilialAtual(filialPadrao);
      
      // Salvar no localStorage
      localStorage.setItem('empresaAtualId', empresaId);
      localStorage.setItem('filialAtualId', filialPadrao?.id);
      
    } catch (error) {
      console.error('Erro ao trocar empresa:', error);
    }
  };

  const trocarFilial = (filialId: string) => {
    const filial = filiais.find(f => f.id === filialId);
    if (filial) {
      setFilialAtual(filial);
      localStorage.setItem('filialAtualId', filialId);
    }
  };

  return (
    <EmpresaContext.Provider value={{
      empresaAtual,
      filialAtual,
      empresas,
      filiais,
      trocarEmpresa,
      trocarFilial,
      loading
    }}>
      {children}
    </EmpresaContext.Provider>
  );
};
```

---

**CONTINUA...**

Este documento está completo até a Fase 3. As próximas fases incluem:

- **Fase 4:** Implementação de RLS
- **Fase 5:** Refatoração do Frontend
- **Fase 6:** Sistema de Planos e Limites
- **Fase 7:** Testes e QA
- **Fase 8:** Migração de Dados
- **Fase 9:** Deploy
- **Fase 10:** Pós-Launch

**Deseja que eu continue com as fases restantes?**

