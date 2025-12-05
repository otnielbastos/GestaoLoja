# Análise Profunda da Arquitetura Atual - GestaoLoja

## 📊 RESUMO EXECUTIVO

**GestaoLoja** é um sistema de gestão empresarial completo desenvolvido em **React + TypeScript + Supabase (PostgreSQL)**, focado em controle de produtos, estoque, vendas, clientes, entregas e relatórios.

**Status Atual:** Sistema monolítico single-tenant operacional em produção
**Objetivo:** Transformar em solução SaaS Multi-Tenant com isolamento total de dados por empresa e filial

---

## 🏗️ ARQUITETURA ATUAL

### Stack Tecnológico

#### Frontend
- **Framework:** React 18.3.1 com TypeScript 5.5.3
- **Build Tool:** Vite 5.4.1
- **Roteamento:** React Router DOM 6.26.2
- **UI Components:** shadcn-ui (baseado em Radix UI)
- **Estilização:** Tailwind CSS 3.4.11
- **Gerenciamento de Estado:** 
  - React Query (TanStack Query) 5.80.2 para estado servidor
  - Context API para autenticação e navegação
- **Formulários:** React Hook Form 7.53.0 + Zod 3.23.8
- **Gráficos:** Recharts 2.12.7
- **Notificações:** Sonner 1.5.0
- **HTTP Client:** Axios 1.9.0

#### Backend/Infraestrutura
- **Banco de Dados:** Supabase (PostgreSQL 15+)
- **Autenticação:** Sistema customizado com bcrypt (hash salt 12)
- **Storage:** Supabase Storage para imagens de produtos
- **API:** Supabase REST API + RPC Functions
- **Segurança:** 
  - JWT tokens com expiração 8 horas
  - Row Level Security (RLS) - preparado mas não totalmente implementado
  - Sistema de bloqueio após tentativas falhas

### Estrutura do Projeto

```
GestaoLoja/
├── src/
│   ├── components/          # Componentes React
│   │   ├── ui/              # Componentes base (shadcn)
│   │   ├── auth/            # Componentes de autenticação
│   │   ├── Dashboard.tsx    # Dashboard principal
│   │   ├── Products.tsx     # Gestão de produtos
│   │   ├── Orders.tsx       # Gestão de pedidos
│   │   ├── Customers.tsx    # Gestão de clientes
│   │   ├── Stock.tsx        # Controle de estoque
│   │   ├── Deliveries.tsx   # Gestão de entregas
│   │   ├── Reports.tsx      # Relatórios e dashboards
│   │   ├── Users.tsx        # Gestão de usuários
│   │   └── ...
│   ├── contexts/
│   │   ├── AuthContext.tsx      # Contexto de autenticação
│   │   └── NavigationContext.tsx # Contexto de navegação
│   ├── hooks/               # Custom hooks
│   │   ├── usePermissions.ts    # Gerenciamento de permissões
│   │   ├── useProducts.ts       # Gestão de produtos
│   │   ├── useOrders.ts         # Gestão de pedidos
│   │   └── ...
│   ├── services/            # Serviços de integração
│   │   ├── api.ts               # Configuração Axios
│   │   ├── supabaseAuth.ts      # Autenticação
│   │   ├── supabaseProdutos.ts  # Produtos
│   │   ├── supabasePedidos.ts   # Pedidos
│   │   ├── supabaseEstoque.ts   # Estoque
│   │   ├── supabaseClientes.ts  # Clientes
│   │   ├── supabaseUsuarios.ts  # Usuários
│   │   ├── supabaseRelatorios.ts # Relatórios
│   │   └── supabaseDashboard.ts # Dashboard
│   ├── pages/               # Páginas principais
│   ├── lib/
│   │   ├── supabase.ts          # Cliente Supabase
│   │   └── utils.ts             # Utilitários
│   └── types/               # Definições TypeScript
├── supabase/
│   ├── migrations/          # Migrações do banco
│   │   ├── 01_initial_schema.sql
│   │   ├── 02_storage_setup.sql
│   │   └── 03_add_desconto_pedidos.sql
│   ├── scripts/             # Scripts utilitários
│   └── seed.sql             # Dados iniciais
├── docs/                    # Documentação completa
│   ├── ANALISE_COMPLETA_PROJETO.md
│   ├── regras/
│   └── implementacao/
└── BancoDados/
    └── script/              # Scripts SQL legados
```

---

## 💾 MODELO DE DADOS ATUAL

### Tabelas Principais

#### 1. **perfis** (Perfis de Acesso)
```sql
- id (SERIAL PRIMARY KEY)
- nome (VARCHAR UNIQUE)
- descricao (TEXT)
- permissoes (JSONB)          # Estrutura: { pages: [], actions: {} }
- ativo (BOOLEAN)
- data_criacao, data_atualizacao
```

#### 2. **usuarios** (Usuários do Sistema)
```sql
- id (SERIAL PRIMARY KEY)
- nome (VARCHAR)
- email (VARCHAR UNIQUE)
- senha (VARCHAR)             # Deprecated - usar senha_hash
- senha_hash (VARCHAR)        # Hash bcrypt
- perfil_id (FK → perfis)
- status (ENUM: ativo/inativo)
- tentativas_login (INTEGER)
- bloqueado_ate (TIMESTAMP)
- ultimo_acesso (TIMESTAMP)
- criado_por, atualizado_por (FK → usuarios)
- ativo (BOOLEAN)
```

#### 3. **clientes** (Base de Clientes)
```sql
- id (SERIAL PRIMARY KEY)
- nome (VARCHAR)
- email (VARCHAR UNIQUE)
- telefone (VARCHAR)
- cpf_cnpj (VARCHAR UNIQUE)
- tipo_pessoa (ENUM: fisica/juridica)
- endereco_* (múltiplos campos)
- observacoes (TEXT)
- status (ENUM: ativo/inativo)
- criado_por (FK → usuarios)
```

#### 4. **produtos** (Catálogo de Produtos)
```sql
- id (SERIAL PRIMARY KEY)
- nome (VARCHAR)
- descricao (TEXT)
- preco_venda (DECIMAL)
- preco_custo (DECIMAL)
- quantidade_minima (INTEGER)
- categoria (VARCHAR)
- tipo_produto (ENUM: producao_propria/revenda/materia_prima)
- unidade_medida (VARCHAR)
- imagem_url (VARCHAR)
- status (ENUM: ativo/inativo)
```

#### 5. **estoque** (Controle de Estoque)
```sql
- id (SERIAL PRIMARY KEY)
- produto_id (FK → produtos)
- quantidade_atual (INTEGER)           # Total geral
- quantidade_pronta_entrega (INTEGER)  # Disponível para venda
- quantidade_encomenda (INTEGER)       # Produzido sob demanda
- ultima_atualizacao (TIMESTAMP)
```

#### 6. **pedidos** (Pedidos de Venda)
```sql
- id (SERIAL PRIMARY KEY)
- cliente_id (FK → clientes)
- numero_pedido (VARCHAR UNIQUE)
- data_pedido (TIMESTAMP)
- status (ENUM: 11 status diferentes)
- tipo (ENUM: pronta_entrega/encomenda)
- data_entrega_prevista (DATE)
- horario_entrega (TIME)
- valor_total (DECIMAL)
- forma_pagamento (VARCHAR)
- status_pagamento (ENUM: pendente/pago/parcial)
- valor_pago (DECIMAL)
- observacoes, observacoes_producao (TEXT)
- estoque_processado (BOOLEAN)        # Controle de duplicação
- criado_por (FK → usuarios)
```

#### 7. **itens_pedido** (Itens dos Pedidos)
```sql
- id (SERIAL PRIMARY KEY)
- pedido_id (FK → pedidos)
- produto_id (FK → produtos)
- quantidade (INTEGER)
- preco_unitario (DECIMAL)
- desconto_valor (DECIMAL)
- desconto_percentual (DECIMAL)
- tipo_desconto (ENUM: valor/percentual)
- preco_unitario_com_desconto (DECIMAL)
- subtotal (DECIMAL)
```

#### 8. **movimentacoes_estoque** (Movimentações de Estoque)
```sql
- id (SERIAL PRIMARY KEY)
- produto_id (FK → produtos)
- tipo_movimento (ENUM: entrada/saida/ajuste)
- quantidade (INTEGER)
- motivo (VARCHAR)
- pedido_id (FK → pedidos)            # Para movimentações automáticas
- tipo_operacao (ENUM: manual/automatica)
- tipo_estoque (ENUM: pronta_entrega/encomenda)
- data_fabricacao, data_validade (DATE)
- usuario_id (FK → usuarios)
```

#### 9. **entregas** (Gestão de Entregas)
```sql
- id (SERIAL PRIMARY KEY)
- pedido_id (FK → pedidos)
- status (ENUM: aguardando/em_rota/entregue/cancelada)
- data_agendada (DATE)
- periodo_entrega (ENUM: manha/tarde/noite)
- endereco_entrega_* (múltiplos campos)
- transportadora (VARCHAR)
- codigo_rastreamento (VARCHAR)
```

#### 10. **auditoria** (Registro de Auditoria)
```sql
- id (SERIAL PRIMARY KEY)
- usuario_id (FK → usuarios)
- acao (VARCHAR)
- tabela (VARCHAR)
- registro_id (INTEGER)
- dados_antigos, dados_novos (JSONB)
- ip_address (VARCHAR)
- user_agent (TEXT)
- data_acao (TIMESTAMP)
```

#### 11. **sessoes** (Controle de Sessões)
```sql
- id (SERIAL PRIMARY KEY)
- usuario_id (FK → usuarios)
- token (VARCHAR UNIQUE)
- ip_address, user_agent
- data_criacao, data_expiracao
- ativo (BOOLEAN)
```

#### 12. **tentativas_login** (Controle de Segurança)
```sql
- id (SERIAL PRIMARY KEY)
- email (VARCHAR)
- ip_address (VARCHAR)
- sucesso (BOOLEAN)
- motivo (VARCHAR)
- data_tentativa (TIMESTAMP)
```

### Tabelas Auxiliares
- **transferencias_estoque** - Transferências entre tipos de estoque
- **log_operacoes_automaticas** - Log de operações automáticas do sistema
- **configuracoes_relatorios** - Configurações salvas de relatórios

### Views
- **vw_estoque_completo** - Visão consolidada de produtos e estoque

---

## 🔐 SISTEMA DE AUTENTICAÇÃO E SEGURANÇA

### Autenticação Customizada (Não usa Supabase Auth nativo)

#### Processo de Login
1. Validação de email e senha (mínimo 6 caracteres)
2. Verificação de bloqueio temporário (5 tentativas = 30 min)
3. Verificação de usuário ativo
4. Comparação bcrypt da senha
5. Geração de JWT token (expiração 8 horas)
6. Criação de sessão no banco
7. Reset de tentativas em sucesso
8. Registro em auditoria

#### Segurança
- ✅ Hash bcrypt com salt 12
- ✅ Tokens JWT com expiração
- ✅ Controle de tentativas de login
- ✅ Bloqueio temporário (5 tentativas/30 min)
- ✅ Registro de IP e User-Agent
- ✅ Auditoria completa de ações
- ❌ Row Level Security (RLS) não totalmente implementado
- ❌ Sem suporte multi-tenant

---

## 🎯 SISTEMA DE PERMISSÕES

### Modelo de Permissões

#### Estrutura Atual
```typescript
{
  pages: ['dashboard', 'produtos', 'pedidos', ...],
  actions: {
    'produtos': ['visualizar', 'criar', 'editar', 'excluir'],
    'pedidos': ['visualizar', 'criar', 'editar', 'aprovar', 'cancelar'],
    ...
  }
}
```

#### Páginas Disponíveis
- `dashboard` - Dashboard principal
- `produtos` - Gestão de produtos
- `pedidos` - Gestão de pedidos
- `clientes` - Gestão de clientes
- `estoque` - Controle de estoque
- `entregas` - Gestão de entregas
- `relatorios` - Relatórios e análises
- `usuarios` - Gestão de usuários
- `configuracoes` - Configurações do sistema

#### Ações Disponíveis
- `visualizar` - Ver dados
- `criar` - Criar novos registros
- `editar` - Editar registros
- `excluir` - Excluir registros
- `aprovar` - Aprovar pedidos
- `cancelar` - Cancelar pedidos
- `exportar` - Exportar dados
- `imprimir` - Imprimir relatórios

#### Perfis Padrão

**1. Administrador** (Acesso Total)
- Todas as páginas
- Todas as ações

**2. Gerente** (Operacional + Relatórios)
- Dashboard, Produtos, Pedidos, Clientes, Estoque, Entregas, Relatórios
- Criar, editar, aprovar, cancelar, exportar

**3. Vendedor** (Vendas + Clientes)
- Dashboard, Pedidos, Clientes
- Visualizar, criar, editar, exportar

**4. Operacional** (Estoque + Entregas)
- Dashboard, Produtos (só visualizar), Estoque, Entregas
- Visualizar, editar

### Implementação
- ✅ Controle granular por página e ação
- ✅ Verificação no frontend via hooks
- ✅ Menu dinâmico baseado em permissões
- ✅ Botões condicionais por permissão
- ❌ Validação no backend limitada
- ❌ Não considera multi-tenancy

---

## 📋 REGRAS DE NEGÓCIO PRINCIPAIS

### 1. Gestão de Pedidos

#### Tipos de Pedido

**Pronta Entrega:**
- ✅ Verifica estoque disponível na criação
- ✅ Saída automática do estoque NA CRIAÇÃO
- ✅ Usa apenas estoque de `quantidade_pronta_entrega`
- ✅ Produtos sem estoque ficam desabilitados

**Encomenda:**
- ✅ Não verifica estoque na criação
- ✅ Entrada automática no estoque quando status = "produzido"
- ✅ Saída automática do estoque quando status = "entregue"
- ✅ Usa estoque de `quantidade_encomenda`

#### Fluxo de Status (11 status)
```
pendente → aprovado → aguardando_producao → em_preparo → 
em_separacao → produzido → pronto → em_entrega → 
entregue → concluido / cancelado
```

#### Movimentações Automáticas de Estoque

**Para Pronta Entrega:**
- Na criação: saída automática do estoque de pronta entrega

**Para Encomenda:**
- Status "produzido": entrada automática no estoque de encomenda
- Status "entregue": saída automática do estoque de encomenda

#### Controle de Duplicação
- Campo `estoque_processado` evita múltiplas movimentações
- Validações impedem processamento duplo

### 2. Controle de Estoque

#### Tipos de Estoque Separados
- `quantidade_pronta_entrega` - Produtos prontos para venda
- `quantidade_encomenda` - Produtos produzidos sob demanda
- `quantidade_atual` - Total (pronta_entrega + encomenda)

#### Tipos de Movimentação
- **Entrada:** Aumenta estoque
- **Saída:** Diminui estoque (com verificação)
- **Ajuste:** Define quantidade absoluta

#### Regras Especiais
- **Nhoques:** Cálculo automático de validade (3 meses após fabricação)
- **Estoque Mínimo:** Alertas quando abaixo do mínimo
- **Não permite estoque negativo**
- **Movimentações automáticas não podem ser excluídas**

### 3. Gestão de Produtos

- ✅ Nome único entre produtos ativos
- ✅ Preço venda > 0
- ✅ Preço custo ≥ 0
- ✅ Upload de imagens (Supabase Storage)
- ✅ Tipos: produção própria, revenda, matéria prima
- ✅ Não permite exclusão com vendas/movimentações

### 4. Gestão de Clientes

- ✅ Suporte pessoa física e jurídica
- ✅ Validação CPF (11 dígitos) / CNPJ (14 dígitos)
- ✅ Email e CPF/CNPJ únicos
- ✅ Soft delete (marca como inativo)
- ✅ Histórico completo de compras

### 5. Pagamentos

- ✅ Status: pendente, parcial, pago
- ✅ Controle de valor pago vs valor total
- ✅ Suporte a descontos (valor ou percentual)
- ✅ Marcação automática como pago na entrega

### 6. Auditoria

- ✅ Registro de todas as ações CRUD
- ✅ Dados antes/depois das alterações
- ✅ IP e User-Agent
- ✅ Log de operações automáticas
- ✅ Controle de tentativas de login

---

## 🎨 INTERFACE E EXPERIÊNCIA DO USUÁRIO

### Componentes Principais

#### Dashboard
- 4 cards de KPIs (Vendas, Pedidos, Produtos, Clientes)
- Lista de pedidos recentes
- Alertas e notificações
- Ações rápidas

#### Gestão de Produtos
- Grid de cards com imagens
- Busca e filtros (categoria, tipo, estoque baixo)
- Badge de status e tipo
- Visualização de estoque separado

#### Gestão de Pedidos
- Lista com filtros avançados
- Status coloridos com ícones
- Diferenciação visual entre tipos
- Modal de pagamento
- Controle de entrega

#### Controle de Estoque
- Lista de movimentações
- Alertas de estoque baixo
- Histórico completo
- Separação por tipo de estoque

#### Relatórios
- Gráficos interativos (Recharts)
- KPIs com variações percentuais
- Múltiplas visualizações
- Filtros por período

### UX Features
- ✅ Notificações toast (Sonner)
- ✅ Loading states
- ✅ Skeleton loaders
- ✅ Confirmações para ações destrutivas
- ✅ Formulários com validação em tempo real
- ✅ Responsivo (Tailwind)

---

## 🔍 PONTOS FORTES DA ARQUITETURA ATUAL

### ✅ Tecnologias Modernas
- React + TypeScript = Type safety
- Vite = Build rápido
- Supabase = Infraestrutura escalável
- shadcn-ui = Componentes de alta qualidade

### ✅ Regras de Negócio Bem Definidas
- Lógica complexa de estoque implementada
- Movimentações automáticas funcionais
- Validações consistentes
- Auditoria completa

### ✅ Segurança Implementada
- Autenticação robusta
- Controle de tentativas
- Auditoria de ações
- Hash de senhas

### ✅ Código Organizado
- Separação clara de responsabilidades
- Serviços especializados
- Hooks reutilizáveis
- Componentes modulares

### ✅ Documentação Completa
- Regras de negócio documentadas
- Análise completa do projeto
- Guias de implementação

---

## ⚠️ LIMITAÇÕES E DESAFIOS ATUAIS

### 🚫 Single-Tenant
- **Todos os dados compartilhados:** Não há isolamento entre empresas
- **Sem suporte multi-empresa:** Arquitetura não preparada para SaaS
- **Sem conceito de filial:** Não há estrutura para múltiplas filiais
- **Risco de dados:** Um usuário pode ver dados de outras empresas

### 🚫 Autenticação Customizada
- **Não usa Supabase Auth:** Sistema de autenticação próprio
- **Gerenciamento manual de sessões:** Mais complexo e propenso a erros
- **Tokens custom:** Não aproveita recursos nativos do Supabase
- **Sem OAuth/SSO:** Não suporta login social

### 🚫 RLS Não Implementado
- **Segurança apenas no frontend:** Fácil de burlar
- **Sem proteção a nível de banco:** Qualquer query pode acessar tudo
- **Risco em APIs diretas:** Supabase REST API exposta

### 🚫 Permissões Limitadas
- **Apenas por perfil:** Não considera hierarquia de empresas
- **Sem permissões por filial:** Não há conceito de acesso por filial
- **Validação só no frontend:** Backend não valida totalmente

### 🚫 Estrutura Monolítica
- **Acoplamento alto:** Difícil adicionar multi-tenancy
- **Migrações complexas:** Mudança de arquitetura requer refatoração grande
- **Escalabilidade limitada:** Não preparado para crescimento exponencial

### 🚫 Relatórios e Dashboards
- **Não segmentados:** Não filtra por empresa
- **Dados globais:** Mostra tudo para todos
- **Performance:** Pode degradar com muitos dados

---

## 📊 MÉTRICAS E COMPLEXIDADE

### Tamanho do Projeto
- **Linhas de código (estimativa):** ~15.000 linhas
- **Componentes React:** ~40 componentes
- **Serviços:** 9 serviços principais
- **Hooks customizados:** 9 hooks
- **Tabelas no banco:** 12 tabelas principais + auxiliares
- **Migrações:** 3 migrações

### Complexidade
- **Alta complexidade de negócio:** Regras de estoque sofisticadas
- **Média complexidade técnica:** Stack moderno mas direto
- **Alta dependência de lógica no frontend:** Validações e regras
- **Baixa preparação para escala:** Arquitetura single-tenant

---

## 🎯 CONCLUSÃO DA ANÁLISE

### Avaliação Geral
O **GestaoLoja** é um sistema **bem estruturado e funcional** para um cenário **single-tenant**, com:
- ✅ Regras de negócio complexas e bem implementadas
- ✅ Interface moderna e amigável
- ✅ Código organizado e documentado
- ✅ Tecnologias modernas e escaláveis (Supabase)

Porém, para transformação em **SaaS Multi-Tenant**, requer:
- 🔄 **Refatoração profunda da arquitetura**
- 🔄 **Implementação completa de isolamento de dados**
- 🔄 **Migração para Supabase Auth ou autenticação multi-tenant**
- 🔄 **Implementação de RLS em todas as tabelas**
- 🔄 **Criação de estrutura de empresas e filiais**
- 🔄 **Redesenho de permissões considerando hierarquia**

### Próximos Passos
Ver documento: **PROPOSTA_ARQUITETURA_MULTITENANT.md**

---

**Documento gerado em:** Dezembro 2025  
**Versão:** 1.0  
**Autor:** Análise Automatizada do Sistema

