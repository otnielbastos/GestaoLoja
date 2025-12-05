# Módulo de Administração da Plataforma (Super Admin)

## 📋 ÍNDICE

1. [Visão Geral](#visão-geral)
2. [Conceito de Super Admin](#conceito-de-super-admin)
3. [Modelo de Dados](#modelo-de-dados)
4. [Dashboard Administrativo](#dashboard-administrativo)
5. [Gestão de Empresas](#gestão-de-empresas)
6. [Gestão Financeira](#gestão-financeira)
7. [Sistema de Suporte](#sistema-de-suporte)
8. [Monitoramento e Métricas](#monitoramento-e-métricas)
9. [Logs e Auditoria Global](#logs-e-auditoria-global)
10. [Configurações da Plataforma](#configurações-da-plataforma)
11. [Alertas e Notificações](#alertas-e-notificações)
12. [Segurança e Controle](#segurança-e-controle)

---

## 🎯 VISÃO GERAL

### O que é?

O **Módulo de Administração da Plataforma** é uma área exclusiva para os **proprietários/administradores do GestaoLoja** (você e sua equipe) gerenciarem todo o ecossistema SaaS.

Este módulo é **separado** do sistema normal e permite:
- 🔍 Visão global de todas as empresas
- 💰 Gestão financeira e billing
- 🛠️ Suporte técnico às empresas
- 📊 Métricas e analytics da plataforma
- ⚙️ Configurações globais
- 🚨 Monitoramento e alertas

### Por que é essencial?

Sem este módulo, você não conseguiria:
- ❌ Ver quantas empresas estão ativas
- ❌ Identificar problemas rapidamente
- ❌ Gerenciar inadimplência
- ❌ Dar suporte eficiente
- ❌ Tomar decisões baseadas em dados
- ❌ Escalar o negócio

---

## 👑 CONCEITO DE SUPER ADMIN

### Diferença entre Papéis

```
┌─────────────────────────────────────────────────────────┐
│                  HIERARQUIA DE ACESSO                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🔴 SUPER ADMIN (Você - Dono da Plataforma)            │
│  ├─ Acesso a TODAS as empresas                         │
│  ├─ Gestão financeira global                           │
│  ├─ Configurações da plataforma                        │
│  ├─ Pode "entrar" em qualquer empresa                  │
│  └─ Dashboard administrativo exclusivo                 │
│                                                         │
│  ↓                                                      │
│                                                         │
│  🟢 PROPRIETÁRIO (Cliente - Dono da Empresa)           │
│  ├─ Acesso total à SUA empresa                        │
│  ├─ Gerencia usuários e filiais                       │
│  ├─ Gerencia assinatura e pagamentos                  │
│  └─ NÃO vê outras empresas                            │
│                                                         │
│  ↓                                                      │
│                                                         │
│  🔵 ADMIN (Administrador da Empresa)                   │
│  ├─ Acesso administrativo à empresa                   │
│  ├─ NÃO gerencia assinatura                          │
│  └─ NÃO vê outras empresas                            │
│                                                         │
│  ↓                                                      │
│                                                         │
│  🟡 GERENTE/USUÁRIO (Funcionário da Empresa)           │
│  ├─ Acesso limitado                                   │
│  └─ Apenas operacional                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### URLs Separadas

```
┌─────────────────────────────────────────────────────┐
│  APLICAÇÃO NORMAL (Clientes)                        │
│  https://app.gestaoloja.com.br                      │
│  - Login normal                                     │
│  - Acesso apenas à sua empresa                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  PAINEL ADMINISTRATIVO (Você)                       │
│  https://admin.gestaoloja.com.br                    │
│  - Login com credenciais especiais                  │
│  - Acesso a todas as empresas                       │
│  - Dashboard administrativo                         │
└─────────────────────────────────────────────────────┘
```

---

## 💾 MODELO DE DADOS

### Novas Tabelas para Super Admin

```sql
-- ============================================
-- TABELA: super_admins
-- ============================================
CREATE TABLE super_admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento com auth
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Informações
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    
    -- Tipo de Admin
    tipo VARCHAR(50) DEFAULT 'admin',  -- 'owner', 'admin', 'suporte', 'financeiro'
    
    -- Permissões Específicas
    permissoes JSONB DEFAULT '{
        "gestao_empresas": true,
        "gestao_financeira": true,
        "gestao_planos": true,
        "acessar_empresas": true,
        "configuracoes_globais": true,
        "logs_globais": true,
        "suporte": true
    }'::jsonb,
    
    -- Controle
    ativo BOOLEAN DEFAULT TRUE,
    ultimo_acesso TIMESTAMP WITH TIME ZONE,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por UUID REFERENCES super_admins(id),
    
    -- 2FA Obrigatório
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255)
);

-- Índices
CREATE INDEX idx_super_admins_email ON super_admins(email);
CREATE INDEX idx_super_admins_auth ON super_admins(auth_user_id);
CREATE INDEX idx_super_admins_tipo ON super_admins(tipo);

-- ============================================
-- TABELA: acessos_admin_empresa
-- (Log de quando admin acessa empresa de cliente)
-- ============================================
CREATE TABLE acessos_admin_empresa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    super_admin_id UUID NOT NULL REFERENCES super_admins(id),
    empresa_id UUID NOT NULL REFERENCES empresas(id),
    
    -- Detalhes do Acesso
    motivo TEXT NOT NULL,  -- Ex: "Suporte técnico", "Correção de bug"
    ticket_numero VARCHAR(50),  -- Número do ticket de suporte
    
    -- Duração
    data_inicio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_fim TIMESTAMP WITH TIME ZONE,
    duracao_minutos INTEGER,
    
    -- Ações Realizadas
    acoes_realizadas JSONB DEFAULT '[]'::jsonb,
    
    -- Segurança
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'ativo',  -- 'ativo', 'finalizado'
    
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_acessos_admin_empresa ON acessos_admin_empresa(empresa_id);
CREATE INDEX idx_acessos_super_admin ON acessos_admin_empresa(super_admin_id);
CREATE INDEX idx_acessos_data ON acessos_admin_empresa(data_inicio);

-- ============================================
-- TABELA: metricas_plataforma
-- (Métricas agregadas da plataforma)
-- ============================================
CREATE TABLE metricas_plataforma (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_referencia DATE NOT NULL UNIQUE,
    
    -- Empresas
    total_empresas INTEGER DEFAULT 0,
    empresas_ativas INTEGER DEFAULT 0,
    empresas_trial INTEGER DEFAULT 0,
    empresas_pagas INTEGER DEFAULT 0,
    empresas_suspensas INTEGER DEFAULT 0,
    novas_empresas_mes INTEGER DEFAULT 0,
    empresas_canceladas_mes INTEGER DEFAULT 0,
    
    -- Usuários
    total_usuarios INTEGER DEFAULT 0,
    usuarios_ativos_mes INTEGER DEFAULT 0,
    
    -- Financeiro
    mrr DECIMAL(10,2) DEFAULT 0,  -- Monthly Recurring Revenue
    arr DECIMAL(10,2) DEFAULT 0,  -- Annual Recurring Revenue
    receita_mes DECIMAL(10,2) DEFAULT 0,
    ticket_medio DECIMAL(10,2) DEFAULT 0,
    
    -- Uso
    total_pedidos_mes INTEGER DEFAULT 0,
    total_produtos_cadastrados INTEGER DEFAULT 0,
    storage_usado_gb DECIMAL(10,2) DEFAULT 0,
    
    -- Churn
    churn_rate DECIMAL(5,2) DEFAULT 0,  -- Taxa de cancelamento
    
    -- Performance
    tempo_resposta_medio_ms INTEGER DEFAULT 0,
    uptime_percentual DECIMAL(5,2) DEFAULT 100,
    
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_metricas_data ON metricas_plataforma(data_referencia);

-- ============================================
-- TABELA: transacoes_financeiras
-- (Registro de todas as transações)
-- ============================================
CREATE TABLE transacoes_financeiras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    empresa_id UUID NOT NULL REFERENCES empresas(id),
    
    -- Tipo de Transação
    tipo VARCHAR(50) NOT NULL,  -- 'pagamento', 'estorno', 'upgrade', 'downgrade'
    status VARCHAR(50) NOT NULL,  -- 'pendente', 'aprovado', 'falhado', 'estornado'
    
    -- Valores
    valor DECIMAL(10,2) NOT NULL,
    moeda VARCHAR(3) DEFAULT 'BRL',
    
    -- Plano
    plano_id UUID REFERENCES planos(id),
    plano_nome VARCHAR(100),
    
    -- Gateway de Pagamento
    gateway VARCHAR(50),  -- 'stripe', 'pagseguro', 'mercadopago', etc
    gateway_transaction_id VARCHAR(255),
    
    -- Detalhes
    descricao TEXT,
    metodo_pagamento VARCHAR(50),  -- 'cartao_credito', 'boleto', 'pix'
    
    -- Datas
    data_transacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_vencimento DATE,
    data_pagamento TIMESTAMP WITH TIME ZONE,
    
    -- Recorrência
    eh_recorrente BOOLEAN DEFAULT TRUE,
    periodo_referencia DATE,  -- Mês de referência
    
    -- Controle
    processado BOOLEAN DEFAULT FALSE,
    nota_fiscal_emitida BOOLEAN DEFAULT FALSE,
    nota_fiscal_numero VARCHAR(100),
    
    observacoes TEXT,
    
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_transacoes_empresa ON transacoes_financeiras(empresa_id);
CREATE INDEX idx_transacoes_status ON transacoes_financeiras(status);
CREATE INDEX idx_transacoes_data ON transacoes_financeiras(data_transacao);
CREATE INDEX idx_transacoes_periodo ON transacoes_financeiras(periodo_referencia);

-- ============================================
-- TABELA: alertas_plataforma
-- (Alertas e notificações para super admin)
-- ============================================
CREATE TABLE alertas_plataforma (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Tipo de Alerta
    tipo VARCHAR(50) NOT NULL,  -- 'empresa_inadimplente', 'limite_excedido', 'erro_critico', 'uso_excessivo'
    severidade VARCHAR(20) NOT NULL,  -- 'info', 'warning', 'error', 'critical'
    
    -- Relacionamentos
    empresa_id UUID REFERENCES empresas(id),
    usuario_id INTEGER REFERENCES usuarios(id),
    
    -- Conteúdo
    titulo VARCHAR(255) NOT NULL,
    mensagem TEXT NOT NULL,
    detalhes JSONB,
    
    -- Ações
    acao_requerida TEXT,
    acao_tomada TEXT,
    resolvido BOOLEAN DEFAULT FALSE,
    data_resolucao TIMESTAMP WITH TIME ZONE,
    resolvido_por UUID REFERENCES super_admins(id),
    
    -- Notificações
    notificado BOOLEAN DEFAULT FALSE,
    data_notificacao TIMESTAMP WITH TIME ZONE,
    
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_alertas_tipo ON alertas_plataforma(tipo);
CREATE INDEX idx_alertas_severidade ON alertas_plataforma(severidade);
CREATE INDEX idx_alertas_empresa ON alertas_plataforma(empresa_id);
CREATE INDEX idx_alertas_resolvido ON alertas_plataforma(resolvido);
CREATE INDEX idx_alertas_data ON alertas_plataforma(data_criacao);

-- ============================================
-- TABELA: configuracoes_globais
-- (Configurações que afetam toda a plataforma)
-- ============================================
CREATE TABLE configuracoes_globais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    chave VARCHAR(100) NOT NULL UNIQUE,
    valor JSONB NOT NULL,
    tipo VARCHAR(50),  -- 'string', 'number', 'boolean', 'json'
    
    descricao TEXT,
    categoria VARCHAR(50),  -- 'geral', 'financeiro', 'seguranca', 'email', 'integracao'
    
    editavel_por VARCHAR(50) DEFAULT 'owner',  -- 'owner', 'admin'
    requer_reinicio BOOLEAN DEFAULT FALSE,
    
    valor_anterior JSONB,
    data_ultima_alteracao TIMESTAMP WITH TIME ZONE,
    alterado_por UUID REFERENCES super_admins(id),
    
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_config_chave ON configuracoes_globais(chave);
CREATE INDEX idx_config_categoria ON configuracoes_globais(categoria);

-- Configurações Iniciais
INSERT INTO configuracoes_globais (chave, valor, tipo, descricao, categoria) VALUES
('plataforma_em_manutencao', 'false', 'boolean', 'Modo de manutenção - bloqueia acesso', 'geral'),
('novos_cadastros_permitidos', 'true', 'boolean', 'Permitir novos cadastros de empresas', 'geral'),
('dias_trial_padrao', '14', 'number', 'Dias de trial para novas empresas', 'financeiro'),
('max_tentativas_login', '5', 'number', 'Máximo de tentativas de login', 'seguranca'),
('tempo_sessao_minutos', '480', 'number', 'Tempo de expiração da sessão', 'seguranca'),
('smtp_host', '{"host": "", "port": 587}', 'json', 'Configurações SMTP', 'email'),
('gateway_pagamento_ativo', '"stripe"', 'string', 'Gateway de pagamento ativo', 'financeiro'),
('webhook_url', '""', 'string', 'URL para webhooks', 'integracao');
```

### Funções Auxiliares

```sql
-- Função para verificar se é super admin
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM super_admins
    WHERE auth_user_id = auth.uid()
      AND ativo = true
  );
$$ LANGUAGE SQL STABLE;

-- Função para iniciar acesso a empresa (suporte)
CREATE OR REPLACE FUNCTION iniciar_acesso_empresa(
  p_empresa_id UUID,
  p_motivo TEXT,
  p_ticket VARCHAR DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_super_admin_id UUID;
  v_acesso_id UUID;
BEGIN
  -- Verificar se é super admin
  IF NOT is_super_admin() THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admins';
  END IF;
  
  -- Buscar super admin
  SELECT id INTO v_super_admin_id
  FROM super_admins
  WHERE auth_user_id = auth.uid();
  
  -- Criar registro de acesso
  INSERT INTO acessos_admin_empresa (
    super_admin_id,
    empresa_id,
    motivo,
    ticket_numero,
    status
  ) VALUES (
    v_super_admin_id,
    p_empresa_id,
    p_motivo,
    p_ticket,
    'ativo'
  ) RETURNING id INTO v_acesso_id;
  
  -- Setar contexto da empresa
  PERFORM set_config('app.current_empresa_id', p_empresa_id::text, false);
  
  RETURN v_acesso_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para finalizar acesso a empresa
CREATE OR REPLACE FUNCTION finalizar_acesso_empresa(p_acesso_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE acessos_admin_empresa
  SET 
    data_fim = NOW(),
    duracao_minutos = EXTRACT(EPOCH FROM (NOW() - data_inicio)) / 60,
    status = 'finalizado'
  WHERE id = p_acesso_id
    AND status = 'ativo';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Row Level Security para Super Admin

```sql
-- Super admins podem ver tudo
CREATE POLICY "Super admins can view all companies" ON empresas
FOR SELECT
USING (is_super_admin() OR id IN (
  SELECT ue.empresa_id 
  FROM usuarios_empresas ue
  JOIN usuarios u ON u.id = ue.usuario_id
  WHERE u.auth_user_id = auth.uid() AND ue.ativo = true
));

-- Similar para outras tabelas...
```

---

## 📊 DASHBOARD ADMINISTRATIVO

### Tela Principal do Admin

```typescript
// src/pages/admin/AdminDashboard.tsx

const AdminDashboard = () => {
  const [metricas, setMetricas] = useState<MetricasPlataforma | null>(null);
  const [alertas, setAlertas] = useState<Alerta[]>([]);
  
  return (
    <div className="p-6 space-y-6">
      
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Administração da Plataforma</h1>
          <p className="text-muted-foreground">
            Gestão completa do GestaoLoja SaaS
          </p>
        </div>
        
        <div className="flex gap-2">
          <Badge variant={plataformaEmManutencao ? 'destructive' : 'success'}>
            {plataformaEmManutencao ? 'Manutenção' : 'Online'}
          </Badge>
          <Button variant="outline" onClick={abrirConfiguracoes}>
            <Settings className="mr-2 h-4 w-4" />
            Configurações
          </Button>
        </div>
      </div>

      {/* KPIs Principais */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        
        {/* Total de Empresas */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Empresas Ativas
            </CardTitle>
            <Building2 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{metricas?.empresas_ativas}</div>
            <p className="text-xs text-muted-foreground">
              +{metricas?.novas_empresas_mes} este mês
            </p>
            <Progress 
              value={(metricas?.empresas_pagas / metricas?.total_empresas) * 100} 
              className="mt-2"
            />
            <p className="text-xs text-muted-foreground mt-1">
              {metricas?.empresas_pagas} pagantes / {metricas?.empresas_trial} trial
            </p>
          </CardContent>
        </Card>

        {/* MRR */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              MRR (Receita Mensal)
            </CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrency(metricas?.mrr)}
            </div>
            <p className="text-xs text-muted-foreground">
              ARR: {formatCurrency(metricas?.arr)}
            </p>
            <div className="flex items-center gap-2 mt-2">
              <TrendingUp className="h-4 w-4 text-green-500" />
              <span className="text-xs text-green-500">
                +{calcularCrescimento()}% vs mês anterior
              </span>
            </div>
          </CardContent>
        </Card>

        {/* Usuários Ativos */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Usuários Ativos
            </CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {metricas?.usuarios_ativos_mes}
            </div>
            <p className="text-xs text-muted-foreground">
              de {metricas?.total_usuarios} usuários totais
            </p>
            <Progress 
              value={(metricas?.usuarios_ativos_mes / metricas?.total_usuarios) * 100} 
              className="mt-2"
            />
          </CardContent>
        </Card>

        {/* Churn Rate */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Churn Rate
            </CardTitle>
            <AlertTriangle className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {metricas?.churn_rate}%
            </div>
            <p className="text-xs text-muted-foreground">
              {metricas?.empresas_canceladas_mes} cancelamentos este mês
            </p>
            <Badge 
              variant={metricas?.churn_rate < 5 ? 'success' : 'destructive'}
              className="mt-2"
            >
              {metricas?.churn_rate < 5 ? 'Saudável' : 'Atenção'}
            </Badge>
          </CardContent>
        </Card>
      </div>

      {/* Alertas Críticos */}
      {alertas.filter(a => a.severidade === 'critical').length > 0 && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Alertas Críticos</AlertTitle>
          <AlertDescription>
            Você tem {alertas.filter(a => a.severidade === 'critical').length} alertas 
            críticos que requerem atenção imediata.
            <Button variant="link" className="ml-2" onClick={() => navigate('/admin/alertas')}>
              Ver Alertas →
            </Button>
          </AlertDescription>
        </Alert>
      )}

      {/* Gráficos */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        {/* Crescimento de Empresas */}
        <Card>
          <CardHeader>
            <CardTitle>Crescimento de Empresas</CardTitle>
            <CardDescription>Últimos 6 meses</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={dadosCrescimento}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="mes" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="novas" stroke="#10b981" name="Novas" />
                <Line type="monotone" dataKey="canceladas" stroke="#ef4444" name="Canceladas" />
                <Line type="monotone" dataKey="total" stroke="#3b82f6" name="Total Ativas" />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Receita */}
        <Card>
          <CardHeader>
            <CardTitle>Receita Mensal (MRR)</CardTitle>
            <CardDescription>Últimos 6 meses</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={dadosReceita}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="mes" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="mrr" fill="#10b981" name="MRR" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Distribuição por Planos */}
      <Card>
        <CardHeader>
          <CardTitle>Distribuição por Planos</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-4 gap-4">
            {planos.map(plano => {
              const count = empresasPorPlano[plano.id] || 0;
              const percentual = (count / metricas.total_empresas) * 100;
              
              return (
                <div key={plano.id} className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium">{plano.nome}</span>
                    <Badge>{count}</Badge>
                  </div>
                  <Progress value={percentual} />
                  <p className="text-xs text-muted-foreground">
                    {percentual.toFixed(1)}% do total
                  </p>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Atividade Recente */}
      <Card>
        <CardHeader>
          <CardTitle>Atividade Recente</CardTitle>
          <CardDescription>Últimas ações na plataforma</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {atividadeRecente.map((atividade, index) => (
              <div key={index} className="flex items-start gap-4">
                <Avatar className="h-8 w-8">
                  <AvatarFallback>
                    {atividade.empresa?.nome?.substring(0, 2).toUpperCase()}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1">
                  <p className="text-sm">
                    <span className="font-medium">{atividade.empresa?.nome}</span>
                    {' '}{atividade.descricao}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {formatDistanceToNow(new Date(atividade.data), { 
                      addSuffix: true,
                      locale: ptBR 
                    })}
                  </p>
                </div>
                <Badge variant={getVariantByType(atividade.tipo)}>
                  {atividade.tipo}
                </Badge>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

    </div>
  );
};
```

---

## 🏢 GESTÃO DE EMPRESAS

### Tela de Lista de Empresas

```typescript
// src/pages/admin/GestaoEmpresas.tsx

const GestaoEmpresas = () => {
  const [empresas, setEmpresas] = useState<Empresa[]>([]);
  const [filtros, setFiltros] = useState({
    status: 'todas',
    plano: 'todos',
    busca: ''
  });

  return (
    <div className="p-6 space-y-6">
      
      <PageHeader
        title="Gestão de Empresas"
        description="Visualize e gerencie todas as empresas da plataforma"
      />

      {/* Filtros */}
      <Card>
        <CardContent className="pt-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            
            <div>
              <Label>Buscar</Label>
              <Input
                placeholder="Nome, CNPJ ou email..."
                value={filtros.busca}
                onChange={(e) => setFiltros({ ...filtros, busca: e.target.value })}
              />
            </div>

            <div>
              <Label>Status</Label>
              <Select 
                value={filtros.status}
                onValueChange={(value) => setFiltros({ ...filtros, status: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="todas">Todas</SelectItem>
                  <SelectItem value="trial">Trial</SelectItem>
                  <SelectItem value="active">Ativas</SelectItem>
                  <SelectItem value="suspended">Suspensas</SelectItem>
                  <SelectItem value="cancelled">Canceladas</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label>Plano</Label>
              <Select 
                value={filtros.plano}
                onValueChange={(value) => setFiltros({ ...filtros, plano: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="todos">Todos</SelectItem>
                  <SelectItem value="trial">Trial</SelectItem>
                  <SelectItem value="starter">Starter</SelectItem>
                  <SelectItem value="professional">Professional</SelectItem>
                  <SelectItem value="enterprise">Enterprise</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="flex items-end">
              <Button variant="outline" onClick={limparFiltros} className="w-full">
                Limpar Filtros
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Tabela de Empresas */}
      <Card>
        <CardContent className="pt-6">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Empresa</TableHead>
                <TableHead>CNPJ</TableHead>
                <TableHead>Plano</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Usuários</TableHead>
                <TableHead>MRR</TableHead>
                <TableHead>Cadastro</TableHead>
                <TableHead>Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {empresas.map(empresa => (
                <TableRow key={empresa.id}>
                  
                  {/* Empresa */}
                  <TableCell>
                    <div>
                      <div className="font-medium">{empresa.nome}</div>
                      <div className="text-sm text-muted-foreground">
                        {empresa.email}
                      </div>
                    </div>
                  </TableCell>

                  {/* CNPJ */}
                  <TableCell className="font-mono text-sm">
                    {formatCNPJ(empresa.cnpj)}
                  </TableCell>

                  {/* Plano */}
                  <TableCell>
                    <Badge variant={getPlanoVariant(empresa.plano?.nome)}>
                      {empresa.plano?.nome}
                    </Badge>
                  </TableCell>

                  {/* Status */}
                  <TableCell>
                    <Badge variant={getStatusVariant(empresa.status_assinatura)}>
                      {getStatusLabel(empresa.status_assinatura)}
                    </Badge>
                    {empresa.bloqueado && (
                      <Badge variant="destructive" className="ml-1">
                        Bloqueado
                      </Badge>
                    )}
                  </TableCell>

                  {/* Usuários */}
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Users className="h-4 w-4 text-muted-foreground" />
                      {empresa.total_usuarios}
                    </div>
                  </TableCell>

                  {/* MRR */}
                  <TableCell className="font-medium">
                    {formatCurrency(empresa.plano?.preco_mensal || 0)}
                  </TableCell>

                  {/* Data de Cadastro */}
                  <TableCell className="text-sm text-muted-foreground">
                    {format(new Date(empresa.data_criacao), 'dd/MM/yyyy')}
                  </TableCell>

                  {/* Ações */}
                  <TableCell>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon">
                          <MoreVertical className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem onClick={() => visualizarDetalhes(empresa)}>
                          <Eye className="mr-2 h-4 w-4" />
                          Ver Detalhes
                        </DropdownMenuItem>
                        
                        <DropdownMenuItem onClick={() => acessarComoSuporte(empresa)}>
                          <LogIn className="mr-2 h-4 w-4" />
                          Acessar (Suporte)
                        </DropdownMenuItem>
                        
                        <DropdownMenuSeparator />
                        
                        <DropdownMenuItem onClick={() => editarEmpresa(empresa)}>
                          <Edit className="mr-2 h-4 w-4" />
                          Editar
                        </DropdownMenuItem>
                        
                        <DropdownMenuItem onClick={() => gerenciarPlano(empresa)}>
                          <CreditCard className="mr-2 h-4 w-4" />
                          Gerenciar Plano
                        </DropdownMenuItem>
                        
                        <DropdownMenuSeparator />
                        
                        {!empresa.bloqueado ? (
                          <DropdownMenuItem 
                            onClick={() => suspenderEmpresa(empresa)}
                            className="text-orange-600"
                          >
                            <Ban className="mr-2 h-4 w-4" />
                            Suspender
                          </DropdownMenuItem>
                        ) : (
                          <DropdownMenuItem 
                            onClick={() => ativarEmpresa(empresa)}
                            className="text-green-600"
                          >
                            <CheckCircle className="mr-2 h-4 w-4" />
                            Ativar
                          </DropdownMenuItem>
                        )}
                        
                        <DropdownMenuSeparator />
                        
                        <DropdownMenuItem 
                          onClick={() => excluirEmpresa(empresa)}
                          className="text-red-600"
                        >
                          <Trash className="mr-2 h-4 w-4" />
                          Excluir
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

    </div>
  );
};
```

---

**CONTINUA NO PRÓXIMO DOCUMENTO...**

Este documento está ficando muito grande. Vou criar arquivos complementares para:
- Gestão Financeira Detalhada
- Sistema de Suporte
- Monitoramento e Logs
- Configurações da Plataforma

Deseja que eu continue com esses documentos complementares?

