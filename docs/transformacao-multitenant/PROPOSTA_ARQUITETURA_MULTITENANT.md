# Proposta de Arquitetura SaaS Multi-Tenant - GestaoLoja

## 📋 ÍNDICE

1. [Visão Geral da Transformação](#visão-geral-da-transformação)
2. [Modelo de Multi-Tenancy](#modelo-de-multi-tenancy)
3. [Arquitetura Proposta](#arquitetura-proposta)
4. [Modelo de Dados Multi-Tenant](#modelo-de-dados-multi-tenant)
5. [Sistema de Autenticação e Autorização](#sistema-de-autenticação-e-autorização)
6. [Row Level Security (RLS)](#row-level-security-rls)
7. [Gerenciamento de Empresas e Filiais](#gerenciamento-de-empresas-e-filiais)
8. [Sistema de Permissões Hierárquico](#sistema-de-permissões-hierárquico)
9. [Planos e Limites (Billing)](#planos-e-limites-billing)
10. [Migração de Dados](#migração-de-dados)
11. [Plano de Implementação](#plano-de-implementação)
12. [Considerações de Segurança](#considerações-de-segurança)
13. [Performance e Escalabilidade](#performance-e-escalabilidade)
14. [Custos e ROI](#custos-e-roi)

---

## 🎯 VISÃO GERAL DA TRANSFORMAÇÃO

### Objetivo
Transformar o **GestaoLoja** de um sistema single-tenant em uma **solução SaaS Multi-Tenant completa**, permitindo que múltiplas empresas utilizem a mesma aplicação com **isolamento total de dados**, suporte a **múltiplas filiais** por empresa, e **gestão hierárquica de permissões**.

### Modelo de Negócio Proposto

#### Para Quem?
- **Pequenas e médias empresas** que precisam de gestão completa
- **Redes de lojas** com múltiplas filiais
- **Franquias** que precisam de gestão centralizada
- **Grupos empresariais** com várias marcas

#### Diferenciais Competitivos
- ✅ **Isolamento total** de dados por empresa e filial
- ✅ **Gestão hierárquica** (empresa → filiais → usuários)
- ✅ **Permissões granulares** por filial e função
- ✅ **Relatórios consolidados** (visão empresa + filiais)
- ✅ **Setup rápido** (onboarding automatizado)
- ✅ **Preço acessível** (planos flexíveis)

---

## 🏢 MODELO DE MULTI-TENANCY

### Abordagem Escolhida: **Shared Database + Shared Schema**

#### Por quê?

**Vantagens:**
- ✅ Mais econômico (um banco para todos)
- ✅ Manutenção simplificada (uma única estrutura)
- ✅ Backups centralizados
- ✅ Migrations unificadas
- ✅ Melhor custo-benefício para pequeno/médio porte
- ✅ Supabase tem recursos excelentes de RLS para isso

**Desvantagens (mitigadas):**
- ⚠️ Risco de vazamento de dados → **Mitigado com RLS rigoroso**
- ⚠️ Performance com muitos tenants → **Mitigado com índices e particionamento**
- ⚠️ Limites por tenant → **Controlado via planos e quotas**

### Alternativas Consideradas

#### 1. Database per Tenant (Descartada)
- ❌ Alto custo (cada empresa = um banco)
- ❌ Complexidade operacional
- ❌ Difícil fazer relatórios cross-tenant
- ✅ Isolamento máximo

#### 2. Schema per Tenant (Descartada)
- ❌ Limite de schemas no Postgres
- ❌ Migrations complexas
- ❌ Difícil gerenciar muitos schemas
- ✅ Bom isolamento

#### 3. **Shared Database + Shared Schema (ESCOLHIDA)**
- ✅ Melhor custo-benefício
- ✅ Operacionalmente simples
- ✅ Escalabilidade adequada
- ✅ RLS do Supabase resolve isolamento

---

## 🏗️ ARQUITETURA PROPOSTA

### Diagrama de Hierarquia

```
┌─────────────────────────────────────────────────────┐
│                     PLATAFORMA                       │
│                    (GestaoLoja)                      │
└─────────────────────────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          │                               │
    ┌─────▼─────┐                   ┌─────▼─────┐
    │ EMPRESA A │                   │ EMPRESA B │
    │  (tenant) │                   │  (tenant) │
    └─────┬─────┘                   └─────┬─────┘
          │                               │
    ┌─────┴─────┐                   ┌─────┴─────┐
    │           │                   │           │
┌───▼───┐   ┌───▼───┐         ┌───▼───┐   ┌───▼───┐
│FILIAL │   │FILIAL │         │FILIAL │   │FILIAL │
│  #1   │   │  #2   │         │  #1   │   │  #2   │
└───┬───┘   └───┬───┘         └───┬───┘   └───┬───┘
    │           │                 │           │
┌───▼───────────▼───┐         ┌───▼───────────▼───┐
│    USUÁRIOS       │         │    USUÁRIOS       │
│    PRODUTOS       │         │    PRODUTOS       │
│    CLIENTES       │         │    CLIENTES       │
│    PEDIDOS        │         │    PEDIDOS        │
│    ESTOQUE        │         │    ESTOQUE        │
└───────────────────┘         └───────────────────┘
```

### Conceitos Principais

#### 1. **Empresa (Tenant)**
- Entidade principal do multi-tenancy
- Dados completamente isolados entre empresas
- Possui configurações próprias
- Pode ter múltiplas filiais
- Vinculada a um plano de assinatura

#### 2. **Filial (Branch/Location)**
- Subdivisão de uma empresa
- Pode ter estoque independente
- Pode ter usuários específicos
- Relatórios podem ser por filial ou consolidados
- Herda configurações da empresa (mas pode sobrescrever)

#### 3. **Usuário**
- Pertence a uma empresa
- Pode ter acesso a uma ou mais filiais
- Possui um perfil de permissões
- Permissões podem variar por filial

---

## 💾 MODELO DE DADOS MULTI-TENANT

### Novas Tabelas

#### 1. **empresas** (Tabela Central do Multi-Tenancy)

```sql
CREATE TABLE empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identificação
    nome VARCHAR(255) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    
    -- Informações de Contato
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
    
    -- Configurações
    configuracoes JSONB DEFAULT '{}'::jsonb,
    personalizacao JSONB DEFAULT '{}'::jsonb,  -- Tema, logo, etc
    
    -- Assinatura e Limites
    plano_id UUID REFERENCES planos(id),
    data_assinatura TIMESTAMP WITH TIME ZONE,
    data_expiracao TIMESTAMP WITH TIME ZONE,
    status_assinatura VARCHAR(20) DEFAULT 'trial',  -- trial, active, suspended, cancelled
    limites JSONB DEFAULT '{}'::jsonb,  -- Limites do plano
    
    -- Controle
    ativo BOOLEAN DEFAULT TRUE,
    bloqueado BOOLEAN DEFAULT FALSE,
    motivo_bloqueio TEXT,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por UUID,
    
    -- Configurações de Segurança
    configuracoes_seguranca JSONB DEFAULT '{
        "requer_2fa": false,
        "tempo_expiracao_sessao": 480,
        "max_tentativas_login": 5,
        "tempo_bloqueio_login": 30
    }'::jsonb
);

-- Índices
CREATE INDEX idx_empresas_cnpj ON empresas(cnpj);
CREATE INDEX idx_empresas_status ON empresas(status_assinatura);
CREATE INDEX idx_empresas_plano ON empresas(plano_id);

-- Comentários
COMMENT ON TABLE empresas IS 'Tabela central do multi-tenancy - cada empresa é um tenant isolado';
COMMENT ON COLUMN empresas.limites IS 'Limites do plano: max_usuarios, max_filiais, max_produtos, max_pedidos_mes, storage_gb, etc';
COMMENT ON COLUMN empresas.configuracoes IS 'Configurações gerais: timezone, moeda, idioma, formato_data, etc';
```

#### 2. **filiais** (Unidades/Branches da Empresa)

```sql
CREATE TABLE filiais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    -- Identificação
    nome VARCHAR(255) NOT NULL,
    codigo VARCHAR(50),  -- Código interno da filial
    tipo VARCHAR(50) DEFAULT 'loja',  -- loja, deposito, escritorio, fabrica, etc
    
    -- Informações
    cnpj VARCHAR(18),  -- Pode ter CNPJ próprio
    inscricao_estadual VARCHAR(20),
    inscricao_municipal VARCHAR(20),
    
    -- Contato
    email VARCHAR(255),
    telefone VARCHAR(20),
    telefone_2 VARCHAR(20),
    
    -- Endereço Completo
    endereco_rua VARCHAR(255) NOT NULL,
    endereco_numero VARCHAR(20),
    endereco_complemento VARCHAR(100),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100) NOT NULL,
    endereco_estado CHAR(2) NOT NULL,
    endereco_cep VARCHAR(10),
    coordenadas_gps POINT,  -- Para mapa
    
    -- Configurações Específicas
    configuracoes JSONB DEFAULT '{}'::jsonb,
    horario_funcionamento JSONB,  -- { "seg": "08:00-18:00", ... }
    
    -- Controle
    ativo BOOLEAN DEFAULT TRUE,
    eh_matriz BOOLEAN DEFAULT FALSE,
    ordem_exibicao INTEGER DEFAULT 0,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por UUID,
    
    -- Constraints
    UNIQUE(empresa_id, codigo),
    UNIQUE(empresa_id, cnpj)
);

-- Índices
CREATE INDEX idx_filiais_empresa ON filiais(empresa_id);
CREATE INDEX idx_filiais_ativo ON filiais(ativo);
CREATE INDEX idx_filiais_tipo ON filiais(tipo);
CREATE INDEX idx_filiais_matriz ON filiais(empresa_id, eh_matriz) WHERE eh_matriz = true;

-- Garantir que cada empresa tem apenas uma matriz
CREATE UNIQUE INDEX idx_filiais_uma_matriz_por_empresa 
ON filiais(empresa_id) WHERE eh_matriz = true;

COMMENT ON TABLE filiais IS 'Filiais/unidades de cada empresa - permite gestão multi-loja';
```

#### 3. **planos** (Planos de Assinatura)

```sql
CREATE TABLE planos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identificação
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    tipo VARCHAR(20) DEFAULT 'mensal',  -- mensal, trimestral, semestral, anual
    
    -- Preços
    preco_mensal DECIMAL(10,2),
    preco_anual DECIMAL(10,2),
    desconto_anual DECIMAL(5,2),  -- Percentual de desconto no anual
    moeda VARCHAR(3) DEFAULT 'BRL',
    
    -- Limites
    max_usuarios INTEGER DEFAULT 5,
    max_filiais INTEGER DEFAULT 1,
    max_produtos INTEGER DEFAULT 100,
    max_clientes INTEGER,
    max_pedidos_mes INTEGER,
    storage_gb INTEGER DEFAULT 1,
    
    -- Features
    features JSONB DEFAULT '[]'::jsonb,  -- ["relatorios_avancados", "api_acesso", ...]
    modulos_disponiveis JSONB DEFAULT '[]'::jsonb,  -- Módulos que podem ser habilitados
    
    -- Visibilidade
    ativo BOOLEAN DEFAULT TRUE,
    publico BOOLEAN DEFAULT TRUE,  -- Se aparece na página de preços
    ordem_exibicao INTEGER DEFAULT 0,
    
    -- Controle
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_planos_ativo ON planos(ativo);
CREATE INDEX idx_planos_publico ON planos(publico);

-- Planos iniciais
INSERT INTO planos (nome, descricao, preco_mensal, preco_anual, max_usuarios, max_filiais, max_produtos, max_pedidos_mes, storage_gb, features) VALUES
('Trial', 'Plano de teste gratuito por 14 dias', 0, 0, 2, 1, 50, 50, 0.5, 
 '["suporte_email"]'::jsonb),
 
('Starter', 'Ideal para pequenos negócios', 97.00, 970.00, 5, 1, 500, NULL, 2,
 '["suporte_email", "backup_diario", "relatorios_basicos"]'::jsonb),
 
('Professional', 'Para empresas em crescimento', 197.00, 1970.00, 15, 5, 2000, NULL, 10,
 '["suporte_prioritario", "backup_diario", "relatorios_avancados", "api_acesso", "multi_filiais"]'::jsonb),
 
('Enterprise', 'Para grandes operações', 497.00, 4970.00, NULL, NULL, NULL, NULL, 50,
 '["suporte_dedicado", "backup_horario", "relatorios_customizados", "api_ilimitada", "white_label", "sla_garantido"]'::jsonb);

COMMENT ON TABLE planos IS 'Planos de assinatura do SaaS com limites e features';
```

#### 4. **usuarios_empresas** (Relacionamento User ↔ Empresa)

```sql
CREATE TABLE usuarios_empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    -- Papel na Empresa
    papel VARCHAR(50) DEFAULT 'usuario',  -- proprietario, admin, gerente, usuario
    
    -- Filiais com Acesso
    filiais_acesso UUID[] DEFAULT ARRAY[]::UUID[],  -- Array de IDs de filiais
    acesso_todas_filiais BOOLEAN DEFAULT FALSE,
    
    -- Status
    ativo BOOLEAN DEFAULT TRUE,
    convite_aceito BOOLEAN DEFAULT FALSE,
    data_convite TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_aceite TIMESTAMP WITH TIME ZONE,
    convite_token VARCHAR(255),
    convite_expira TIMESTAMP WITH TIME ZONE,
    
    -- Controle
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    convidado_por UUID REFERENCES usuarios(id),
    
    -- Constraint: Um usuário não pode estar duplicado na mesma empresa
    UNIQUE(usuario_id, empresa_id)
);

-- Índices
CREATE INDEX idx_usuarios_empresas_usuario ON usuarios_empresas(usuario_id);
CREATE INDEX idx_usuarios_empresas_empresa ON usuarios_empresas(empresa_id);
CREATE INDEX idx_usuarios_empresas_ativo ON usuarios_empresas(ativo);

COMMENT ON TABLE usuarios_empresas IS 'Relacionamento many-to-many entre usuários e empresas';
COMMENT ON COLUMN usuarios_empresas.papel IS 'proprietario = dono da conta, admin = administrador total, gerente = gerente de filiais, usuario = operador';
```

### Modificação de Tabelas Existentes

#### Adicionar `empresa_id` e `filial_id` em TODAS as tabelas de dados

```sql
-- Tabela: usuarios (modificação)
ALTER TABLE usuarios 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_padrao_id UUID REFERENCES filiais(id);

-- Índice
CREATE INDEX idx_usuarios_empresa ON usuarios(empresa_id);

-- Tabela: clientes (modificação)
ALTER TABLE clientes 
ADD COLUMN empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID REFERENCES filiais(id);

-- Índices
CREATE INDEX idx_clientes_empresa ON clientes(empresa_id);
CREATE INDEX idx_clientes_filial ON clientes(filial_id);

-- Tabela: produtos (modificação)
ALTER TABLE produtos 
ADD COLUMN empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE;

-- Índice
CREATE INDEX idx_produtos_empresa ON produtos(empresa_id);

-- Tabela: estoque (modificação)
ALTER TABLE estoque 
ADD COLUMN empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID NOT NULL REFERENCES filiais(id) ON DELETE CASCADE;

-- Índices
CREATE INDEX idx_estoque_empresa ON estoque(empresa_id);
CREATE INDEX idx_estoque_filial ON estoque(filial_id);

-- IMPORTANTE: Estoque agora é POR FILIAL
-- Cada filial tem seu próprio controle de estoque
-- Constraint: Um produto só pode ter um registro de estoque por filial
ALTER TABLE estoque ADD CONSTRAINT unique_produto_filial UNIQUE(produto_id, filial_id);

-- Tabela: pedidos (modificação)
ALTER TABLE pedidos 
ADD COLUMN empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID NOT NULL REFERENCES filiais(id) ON DELETE CASCADE;

-- Índices
CREATE INDEX idx_pedidos_empresa ON pedidos(empresa_id);
CREATE INDEX idx_pedidos_filial ON pedidos(filial_id);

-- Tabela: entregas (modificação)
ALTER TABLE entregas 
ADD COLUMN empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID NOT NULL REFERENCES filiais(id);

-- Índices
CREATE INDEX idx_entregas_empresa ON entregas(empresa_id);
CREATE INDEX idx_entregas_filial ON entregas(filial_id);

-- Tabela: movimentacoes_estoque (modificação)
ALTER TABLE movimentacoes_estoque 
ADD COLUMN empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN filial_id UUID NOT NULL REFERENCES filiais(id) ON DELETE CASCADE;

-- Índices
CREATE INDEX idx_movimentacoes_empresa ON movimentacoes_estoque(empresa_id);
CREATE INDEX idx_movimentacoes_filial ON movimentacoes_estoque(filial_id);

-- Tabela: auditoria (modificação)
ALTER TABLE auditoria 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;

-- Índice
CREATE INDEX idx_auditoria_empresa ON auditoria(empresa_id);

-- Tabela: perfis (modificação)
ALTER TABLE perfis 
ADD COLUMN empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
ADD COLUMN eh_global BOOLEAN DEFAULT FALSE;

-- Índice
CREATE INDEX idx_perfis_empresa ON perfis(empresa_id);

-- IMPORTANTE: Perfis podem ser globais (sistema) ou por empresa
-- Perfis globais (eh_global=true): Disponíveis para todas as empresas
-- Perfis customizados (eh_global=false): Específicos de uma empresa
```

#### Tabelas de Controle Adicional

```sql
-- Tabela: limites_uso (Controle de Uso dos Limites)
CREATE TABLE limites_uso (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    -- Período
    mes_referencia DATE NOT NULL,  -- Primeiro dia do mês
    
    -- Contadores
    total_usuarios INTEGER DEFAULT 0,
    total_filiais INTEGER DEFAULT 0,
    total_produtos INTEGER DEFAULT 0,
    total_clientes INTEGER DEFAULT 0,
    total_pedidos_mes INTEGER DEFAULT 0,
    storage_usado_gb DECIMAL(10,2) DEFAULT 0,
    
    -- API (se tiver)
    total_chamadas_api INTEGER DEFAULT 0,
    
    -- Controle
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(empresa_id, mes_referencia)
);

CREATE INDEX idx_limites_uso_empresa ON limites_uso(empresa_id);
CREATE INDEX idx_limites_uso_mes ON limites_uso(mes_referencia);

-- Tabela: historico_assinaturas (Histórico de Mudanças de Plano)
CREATE TABLE historico_assinaturas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    -- Mudança
    plano_anterior_id UUID REFERENCES planos(id),
    plano_novo_id UUID REFERENCES planos(id),
    tipo_mudanca VARCHAR(50),  -- upgrade, downgrade, cancelamento, reativacao
    
    -- Valores
    valor_antigo DECIMAL(10,2),
    valor_novo DECIMAL(10,2),
    
    -- Controle
    data_mudanca TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    motivo TEXT,
    realizado_por UUID REFERENCES usuarios(id)
);

CREATE INDEX idx_historico_assinaturas_empresa ON historico_assinaturas(empresa_id);

-- Tabela: convites_pendentes (Convites de Usuários)
CREATE TABLE convites_pendentes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    
    -- Dados do Convite
    email VARCHAR(255) NOT NULL,
    perfil_id INTEGER REFERENCES perfis(id),
    papel VARCHAR(50) DEFAULT 'usuario',
    filiais_acesso UUID[],
    
    -- Token
    token VARCHAR(255) NOT NULL UNIQUE,
    data_expiracao TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pendente',  -- pendente, aceito, expirado, cancelado
    data_aceite TIMESTAMP WITH TIME ZONE,
    
    -- Controle
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por UUID REFERENCES usuarios(id),
    mensagem_personalizada TEXT
);

CREATE INDEX idx_convites_empresa ON convites_pendentes(empresa_id);
CREATE INDEX idx_convites_email ON convites_pendentes(email);
CREATE INDEX idx_convites_token ON convites_pendentes(token);

COMMENT ON TABLE convites_pendentes IS 'Convites enviados para novos usuários entrarem na empresa';
```

---

## 🔐 SISTEMA DE AUTENTICAÇÃO E AUTORIZAÇÃO

### Mudança para Supabase Auth

#### Por quê migrar?

**Vantagens:**
- ✅ Sistema robusto e testado
- ✅ Suporte nativo a JWT
- ✅ Integração perfeita com RLS
- ✅ OAuth/SSO out-of-the-box
- ✅ 2FA nativo
- ✅ Menos código para manter
- ✅ Mais seguro

**Migração:**
- Manter tabela `usuarios` atual
- Criar relacionamento com `auth.users` do Supabase
- Migrar senhas (avisar usuários ou forçar reset)

#### Estrutura Proposta

```sql
-- Vincular usuários com auth do Supabase
ALTER TABLE usuarios 
ADD COLUMN auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE;

-- Índice
CREATE INDEX idx_usuarios_auth ON usuarios(auth_user_id);

-- Trigger para criar usuário na nossa tabela quando criar no auth
CREATE OR REPLACE FUNCTION handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.usuarios (auth_user_id, email, nome, ativo)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'nome', NEW.email), TRUE);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### Fluxo de Autenticação Multi-Tenant

#### 1. **Cadastro de Nova Empresa (Sign Up)**

```typescript
// Fluxo:
// 1. Usuário preenche formulário (empresa + usuário)
// 2. Sistema cria empresa
// 3. Sistema cria usuário no Supabase Auth
// 4. Sistema vincula usuário à empresa como proprietário
// 5. Sistema cria filial matriz
// 6. Sistema envia email de confirmação

async function cadastrarEmpresa(dados) {
  // 1. Criar empresa
  const empresa = await criarEmpresa({
    nome: dados.nomeEmpresa,
    cnpj: dados.cnpj,
    email: dados.emailEmpresa,
    plano_id: 'plano_trial_id',
    status_assinatura: 'trial'
  });
  
  // 2. Criar filial matriz
  const filialMatriz = await criarFilial({
    empresa_id: empresa.id,
    nome: 'Matriz',
    eh_matriz: true,
    endereco_cidade: dados.cidade,
    endereco_estado: dados.estado
  });
  
  // 3. Criar usuário no Supabase Auth
  const { data: authUser, error } = await supabase.auth.signUp({
    email: dados.emailUsuario,
    password: dados.senha,
    options: {
      data: {
        nome: dados.nomeUsuario,
        empresa_id: empresa.id
      }
    }
  });
  
  // 4. Vincular usuário à empresa (trigger já cria o usuário)
  await vincularUsuarioEmpresa({
    usuario_id: authUser.user.id,
    empresa_id: empresa.id,
    papel: 'proprietario',
    acesso_todas_filiais: true,
    convite_aceito: true
  });
  
  // 5. Atribuir perfil Administrador
  await atribuirPerfil(authUser.user.id, 'Administrador');
  
  return { empresa, usuario: authUser.user };
}
```

#### 2. **Login Multi-Tenant**

```typescript
// Fluxo:
// 1. Usuário faz login (email + senha)
// 2. Sistema busca empresas do usuário
// 3. Se múltiplas empresas: usuário escolhe
// 4. Sistema seta contexto da empresa escolhida
// 5. Sistema carrega permissões e filiais

async function login(email, senha) {
  // 1. Login no Supabase
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password: senha
  });
  
  if (error) throw error;
  
  // 2. Buscar empresas do usuário
  const empresas = await buscarEmpresasUsuario(data.user.id);
  
  // 3. Se múltiplas empresas, salvar no state para escolha
  if (empresas.length > 1) {
    return {
      requerEscolhaEmpresa: true,
      empresas: empresas,
      user: data.user
    };
  }
  
  // 4. Setar contexto da empresa
  const empresaSelecionada = empresas[0];
  await setarContextoEmpresa(empresaSelecionada.id);
  
  // 5. Carregar permissões
  const permissoes = await carregarPermissoesUsuario(
    data.user.id, 
    empresaSelecionada.id
  );
  
  return {
    user: data.user,
    empresa: empresaSelecionada,
    permissoes
  };
}
```

#### 3. **Context de Empresa (Frontend)**

```typescript
// src/contexts/EmpresaContext.tsx

interface EmpresaContextType {
  empresaAtual: Empresa | null;
  filialAtual: Filial | null;
  empresas: Empresa[];
  filiais: Filial[];
  trocarEmpresa: (empresaId: string) => Promise<void>;
  trocarFilial: (filialId: string) => void;
  loading: boolean;
}

export const EmpresaProvider = ({ children }) => {
  const { user } = useAuth();
  const [empresaAtual, setEmpresaAtual] = useState<Empresa | null>(null);
  const [filialAtual, setFilialAtual] = useState<Filial | null>(null);
  const [empresas, setEmpresas] = useState<Empresa[]>([]);
  const [filiais, setFiliais] = useState<Filial[]>([]);

  // Carregar empresas do usuário ao logar
  useEffect(() => {
    if (user) {
      carregarEmpresasUsuario();
    }
  }, [user]);

  const carregarEmpresasUsuario = async () => {
    const { data } = await supabase
      .from('usuarios_empresas')
      .select('empresa:empresas(*)')
      .eq('usuario_id', user.id)
      .eq('ativo', true);
      
    setEmpresas(data.map(item => item.empresa));
    
    // Setar primeira empresa como padrão
    if (data.length > 0) {
      await trocarEmpresa(data[0].empresa.id);
    }
  };

  const trocarEmpresa = async (empresaId: string) => {
    // Buscar empresa
    const empresa = empresas.find(e => e.id === empresaId);
    setEmpresaAtual(empresa);
    
    // Buscar filiais da empresa
    const { data: filiaisData } = await supabase
      .from('filiais')
      .select('*')
      .eq('empresa_id', empresaId)
      .eq('ativo', true)
      .order('ordem_exibicao');
      
    setFiliais(filiaisData);
    
    // Setar primeira filial ou matriz como padrão
    const filialPadrao = filiaisData.find(f => f.eh_matriz) || filiaisData[0];
    setFilialAtual(filialPadrao);
    
    // Salvar no localStorage
    localStorage.setItem('empresaAtualId', empresaId);
    localStorage.setItem('filialAtualId', filialPadrao?.id);
  };

  const trocarFilial = (filialId: string) => {
    const filial = filiais.find(f => f.id === filialId);
    setFilialAtual(filial);
    localStorage.setItem('filialAtualId', filialId);
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

## 🛡️ ROW LEVEL SECURITY (RLS)

### Conceito

RLS é o mecanismo do PostgreSQL/Supabase que garante que **cada query retorna apenas dados do tenant corrente**, protegendo a nível de banco de dados.

### Implementação Completa

#### 1. **Habilitar RLS em TODAS as tabelas**

```sql
-- Habilitar RLS
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE filiais ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE entregas ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;
-- ... todas as outras tabelas
```

#### 2. **Função para pegar empresa_id do contexto**

```sql
-- Função que retorna o empresa_id do usuário autenticado
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

-- Função que retorna array de filiais que o usuário tem acesso
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

-- Função que verifica se usuário tem papel específico
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
```

#### 3. **Policies RLS para cada tabela**

```sql
-- ========================================
-- EMPRESAS
-- ========================================

-- Usuários podem ver apenas suas empresas
CREATE POLICY "Users can view their companies" ON empresas
FOR SELECT
USING (
  id IN (
    SELECT ue.empresa_id 
    FROM usuarios_empresas ue
    JOIN usuarios u ON u.id = ue.usuario_id
    WHERE u.auth_user_id = auth.uid() AND ue.ativo = true
  )
);

-- Apenas proprietários podem editar empresa
CREATE POLICY "Company owners can update" ON empresas
FOR UPDATE
USING (user_has_papel('proprietario'));

-- ========================================
-- FILIAIS
-- ========================================

-- Ver apenas filiais da empresa atual
CREATE POLICY "Users can view company branches" ON filiais
FOR SELECT
USING (empresa_id = get_current_empresa_id());

-- Proprietários e admins podem inserir filiais
CREATE POLICY "Owners and admins can insert branches" ON filiais
FOR INSERT
WITH CHECK (
  empresa_id = get_current_empresa_id() AND
  (user_has_papel('proprietario') OR user_has_papel('admin'))
);

-- Proprietários e admins podem editar filiais
CREATE POLICY "Owners and admins can update branches" ON filiais
FOR UPDATE
USING (
  empresa_id = get_current_empresa_id() AND
  (user_has_papel('proprietario') OR user_has_papel('admin'))
);

-- ========================================
-- CLIENTES
-- ========================================

-- Ver apenas clientes da empresa
CREATE POLICY "Users can view company clients" ON clientes
FOR SELECT
USING (empresa_id = get_current_empresa_id());

-- Inserir apenas na empresa atual
CREATE POLICY "Users can insert clients in their company" ON clientes
FOR INSERT
WITH CHECK (empresa_id = get_current_empresa_id());

-- Editar apenas clientes da empresa
CREATE POLICY "Users can update company clients" ON clientes
FOR UPDATE
USING (empresa_id = get_current_empresa_id());

-- Excluir apenas clientes da empresa (se tiver permissão)
CREATE POLICY "Users can delete company clients" ON clientes
FOR DELETE
USING (empresa_id = get_current_empresa_id());

-- ========================================
-- PRODUTOS
-- ========================================

-- Ver apenas produtos da empresa
CREATE POLICY "Users can view company products" ON produtos
FOR SELECT
USING (empresa_id = get_current_empresa_id());

-- Inserir apenas na empresa atual
CREATE POLICY "Users can insert products in their company" ON produtos
FOR INSERT
WITH CHECK (empresa_id = get_current_empresa_id());

-- Editar apenas produtos da empresa
CREATE POLICY "Users can update company products" ON produtos
FOR UPDATE
USING (empresa_id = get_current_empresa_id());

-- ========================================
-- ESTOQUE (Por Filial)
-- ========================================

-- Ver apenas estoque das filiais que tem acesso
CREATE POLICY "Users can view branch stock" ON estoque
FOR SELECT
USING (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- Inserir apenas em filiais que tem acesso
CREATE POLICY "Users can insert stock in their branches" ON estoque
FOR INSERT
WITH CHECK (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- Editar apenas estoque das filiais que tem acesso
CREATE POLICY "Users can update branch stock" ON estoque
FOR UPDATE
USING (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- ========================================
-- PEDIDOS (Por Filial)
-- ========================================

-- Ver pedidos das filiais que tem acesso
CREATE POLICY "Users can view branch orders" ON pedidos
FOR SELECT
USING (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- Inserir pedidos em filiais que tem acesso
CREATE POLICY "Users can insert orders in their branches" ON pedidos
FOR INSERT
WITH CHECK (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- Editar pedidos das filiais que tem acesso
CREATE POLICY "Users can update branch orders" ON pedidos
FOR UPDATE
USING (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- ========================================
-- ITENS_PEDIDO
-- ========================================

-- Ver itens apenas de pedidos da empresa
CREATE POLICY "Users can view order items" ON itens_pedido
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.id = itens_pedido.pedido_id
      AND p.empresa_id = get_current_empresa_id()
      AND p.filial_id = ANY(get_user_filiais_acesso())
  )
);

-- Inserir itens apenas em pedidos da empresa
CREATE POLICY "Users can insert order items" ON itens_pedido
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.id = itens_pedido.pedido_id
      AND p.empresa_id = get_current_empresa_id()
      AND p.filial_id = ANY(get_user_filiais_acesso())
  )
);

-- ========================================
-- MOVIMENTACOES_ESTOQUE
-- ========================================

-- Ver movimentações das filiais que tem acesso
CREATE POLICY "Users can view branch stock movements" ON movimentacoes_estoque
FOR SELECT
USING (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- Inserir movimentações nas filiais que tem acesso
CREATE POLICY "Users can insert stock movements" ON movimentacoes_estoque
FOR INSERT
WITH CHECK (
  empresa_id = get_current_empresa_id() AND
  filial_id = ANY(get_user_filiais_acesso())
);

-- ========================================
-- AUDITORIA
-- ========================================

-- Ver auditoria apenas da empresa
-- (Apenas proprietários e admins)
CREATE POLICY "Owners and admins can view audit logs" ON auditoria
FOR SELECT
USING (
  empresa_id = get_current_empresa_id() AND
  (user_has_papel('proprietario') OR user_has_papel('admin'))
);

-- ========================================
-- USUARIOS
-- ========================================

-- Ver usuários da empresa
CREATE POLICY "Users can view company users" ON usuarios
FOR SELECT
USING (empresa_id = get_current_empresa_id());

-- Proprietários e admins podem criar usuários
CREATE POLICY "Owners and admins can insert users" ON usuarios
FOR INSERT
WITH CHECK (
  empresa_id = get_current_empresa_id() AND
  (user_has_papel('proprietario') OR user_has_papel('admin'))
);

-- Proprietários e admins podem editar usuários
-- Qualquer usuário pode editar a si mesmo (nome, senha)
CREATE POLICY "Users can update company users" ON usuarios
FOR UPDATE
USING (
  empresa_id = get_current_empresa_id() AND
  (
    (user_has_papel('proprietario') OR user_has_papel('admin')) OR
    auth_user_id = auth.uid()  -- Permite editar a si mesmo
  )
);
```

#### 4. **Setar contexto da empresa no backend**

```typescript
// src/lib/supabase.ts

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)

// Função para setar contexto da empresa
export const setEmpresaContext = async (empresaId: string) => {
  // Isso seta uma variável de sessão no Postgres que o RLS pode ler
  await supabase.rpc('set_config', {
    setting: 'app.current_empresa_id',
    value: empresaId
  });
};

// Criar RPC no Supabase
-- SQL:
CREATE OR REPLACE FUNCTION set_config(setting TEXT, value TEXT)
RETURNS VOID AS $$
BEGIN
  PERFORM set_config(setting, value, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### 5. **Hook para garantir contexto sempre setado**

```typescript
// src/hooks/useEmpresaContext.ts

import { useEffect } from 'react';
import { useEmpresa } from '../contexts/EmpresaContext';
import { setEmpresaContext } from '../lib/supabase';

export const useEmpresaContext = () => {
  const { empresaAtual } = useEmpresa();
  
  useEffect(() => {
    if (empresaAtual?.id) {
      // Setar contexto sempre que mudar de empresa
      setEmpresaContext(empresaAtual.id);
    }
  }, [empresaAtual]);
  
  return empresaAtual;
};

// Usar em App.tsx ou no AuthProvider
```

---

## 👥 GERENCIAMENTO DE EMPRESAS E FILIAIS

### Interface de Administração

#### 1. **Seletor de Empresa (Navbar)**

```typescript
// Componente no topo da aplicação
<Select value={empresaAtual?.id} onValueChange={trocarEmpresa}>
  <SelectTrigger>
    <Building2 className="mr-2 h-4 w-4" />
    {empresaAtual?.nome || 'Selecionar Empresa'}
  </SelectTrigger>
  <SelectContent>
    {empresas.map(empresa => (
      <SelectItem key={empresa.id} value={empresa.id}>
        <div className="flex flex-col">
          <span className="font-medium">{empresa.nome}</span>
          <span className="text-xs text-muted-foreground">
            {empresa.cnpj}
          </span>
        </div>
      </SelectItem>
    ))}
  </SelectContent>
</Select>
```

#### 2. **Seletor de Filial (Contexto)**

```typescript
// Componente de seleção de filial (pode estar na navbar ou sidebar)
<Select value={filialAtual?.id} onValueChange={trocarFilial}>
  <SelectTrigger>
    <Store className="mr-2 h-4 w-4" />
    {filialAtual?.nome || 'Todas as Filiais'}
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="todas">📊 Visão Consolidada</SelectItem>
    <SelectSeparator />
    {filiais.map(filial => (
      <SelectItem key={filial.id} value={filial.id}>
        <div className="flex items-center">
          {filial.eh_matriz && <Star className="mr-2 h-3 w-3 text-yellow-500" />}
          {filial.nome}
        </div>
      </SelectItem>
    ))}
  </SelectContent>
</Select>
```

#### 3. **Tela de Gestão de Filiais**

```typescript
// /dashboard/configuracoes/filiais

const FiliaisPage = () => {
  const { empresaAtual, filiais } = useEmpresa();
  const { canCreate, canEdit, canDelete } = usePagePermission('configuracoes');

  return (
    <div>
      <PageHeader
        title="Filiais"
        description="Gerencie as filiais da sua empresa"
        action={
          canCreate && (
            <Button onClick={() => setModalOpen(true)}>
              <Plus className="mr-2 h-4 w-4" />
              Nova Filial
            </Button>
          )
        }
      />

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filiais.map(filial => (
          <Card key={filial.id}>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center">
                  {filial.eh_matriz && (
                    <Badge variant="default" className="mr-2">
                      Matriz
                    </Badge>
                  )}
                  {filial.nome}
                </CardTitle>
                <DropdownMenu>
                  {/* Ações: editar, desativar, etc */}
                </DropdownMenu>
              </div>
              <CardDescription>{filial.tipo}</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-2 text-sm">
                <div className="flex items-center">
                  <MapPin className="mr-2 h-4 w-4 text-muted-foreground" />
                  {filial.endereco_cidade}, {filial.endereco_estado}
                </div>
                {filial.telefone && (
                  <div className="flex items-center">
                    <Phone className="mr-2 h-4 w-4 text-muted-foreground" />
                    {filial.telefone}
                  </div>
                )}
                {filial.email && (
                  <div className="flex items-center">
                    <Mail className="mr-2 h-4 w-4 text-muted-foreground" />
                    {filial.email}
                  </div>
                )}
              </div>
            </CardContent>
            <CardFooter>
              <div className="flex w-full justify-between text-xs text-muted-foreground">
                <span>Código: {filial.codigo}</span>
                <Badge variant={filial.ativo ? 'success' : 'secondary'}>
                  {filial.ativo ? 'Ativa' : 'Inativa'}
                </Badge>
              </div>
            </CardFooter>
          </Card>
        ))}
      </div>
    </div>
  );
};
```

#### 4. **Modal de Criar/Editar Filial**

```typescript
const FilialFormModal = ({ filial, isOpen, onClose, onSuccess }) => {
  const form = useForm({
    defaultValues: {
      nome: filial?.nome || '',
      codigo: filial?.codigo || '',
      tipo: filial?.tipo || 'loja',
      cnpj: filial?.cnpj || '',
      email: filial?.email || '',
      telefone: filial?.telefone || '',
      endereco_rua: filial?.endereco_rua || '',
      endereco_numero: filial?.endereco_numero || '',
      endereco_bairro: filial?.endereco_bairro || '',
      endereco_cidade: filial?.endereco_cidade || '',
      endereco_estado: filial?.endereco_estado || '',
      endereco_cep: filial?.endereco_cep || '',
      eh_matriz: filial?.eh_matriz || false,
      ativo: filial?.ativo ?? true,
    }
  });

  const onSubmit = async (data) => {
    if (filial) {
      await atualizarFilial(filial.id, data);
    } else {
      await criarFilial(data);
    }
    onSuccess();
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {filial ? 'Editar Filial' : 'Nova Filial'}
          </DialogTitle>
        </DialogHeader>
        
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <Tabs defaultValue="geral">
              <TabsList>
                <TabsTrigger value="geral">Informações Gerais</TabsTrigger>
                <TabsTrigger value="endereco">Endereço</TabsTrigger>
                <TabsTrigger value="contato">Contato</TabsTrigger>
              </TabsList>

              <TabsContent value="geral" className="space-y-4">
                <FormField name="nome" label="Nome da Filial" required />
                <FormField name="codigo" label="Código" />
                <FormField name="tipo" label="Tipo" type="select">
                  <option value="loja">Loja</option>
                  <option value="deposito">Depósito</option>
                  <option value="escritorio">Escritório</option>
                  <option value="fabrica">Fábrica</option>
                </FormField>
                <FormField name="cnpj" label="CNPJ (opcional)" />
                <FormField name="eh_matriz" label="É matriz?" type="checkbox" />
                <FormField name="ativo" label="Ativa" type="checkbox" />
              </TabsContent>

              <TabsContent value="endereco" className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <FormField name="endereco_cep" label="CEP" />
                  <Button type="button" onClick={buscarCep}>
                    Buscar CEP
                  </Button>
                </div>
                <FormField name="endereco_rua" label="Rua" required />
                <div className="grid grid-cols-4 gap-4">
                  <FormField name="endereco_numero" label="Número" className="col-span-1" />
                  <FormField name="endereco_complemento" label="Complemento" className="col-span-3" />
                </div>
                <FormField name="endereco_bairro" label="Bairro" />
                <div className="grid grid-cols-3 gap-4">
                  <FormField name="endereco_cidade" label="Cidade" required className="col-span-2" />
                  <FormField name="endereco_estado" label="UF" required />
                </div>
              </TabsContent>

              <TabsContent value="contato" className="space-y-4">
                <FormField name="email" label="Email" type="email" />
                <FormField name="telefone" label="Telefone" />
                <FormField name="telefone_2" label="Telefone 2" />
              </TabsContent>
            </Tabs>

            <DialogFooter>
              <Button type="button" variant="outline" onClick={onClose}>
                Cancelar
              </Button>
              <Button type="submit">
                {filial ? 'Salvar Alterações' : 'Criar Filial'}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
};
```

---

**CONTINUA NO PRÓXIMO DOCUMENTO...**

Este documento está ficando muito grande. Vou criar arquivos separados para:
- Sistema de Permissões Hierárquico
- Planos e Limites (Billing)
- Migração de Dados
- Plano de Implementação Detalhado

Deseja que eu continue com esses documentos complementares?

