# Análise Completa do Projeto GestaoLoja

## 📋 Índice

1. [Visão Geral do Sistema](#visão-geral-do-sistema)
2. [Arquitetura e Tecnologias](#arquitetura-e-tecnologias)
3. [Descrição Detalhada de Todas as Telas](#descrição-detalhada-de-todas-as-telas)
4. [Regras de Negócio Completas](#regras-de-negócio-completas)
5. [Sistema de Permissões](#sistema-de-permissões)
6. [Fluxos Principais](#fluxos-principais)

---

## Visão Geral do Sistema

**GestaoLoja** é um sistema completo de gestão empresarial desenvolvido para lojas, com controle total de produtos, estoque, vendas, clientes, entregas e relatórios. O sistema foi migrado de uma arquitetura Node.js/MySQL para Supabase (PostgreSQL), mantendo 100% das funcionalidades e regras de negócio originais.

### Principais Características

- ✅ Sistema de autenticação seguro com controle de tentativas
- ✅ Gestão completa de produtos com controle de estoque separado (Pronta Entrega/Encomenda)
- ✅ Sistema de pedidos com dois tipos: Pronta Entrega e Encomenda
- ✅ Controle de estoque com movimentações automáticas
- ✅ Gestão de clientes com histórico completo
- ✅ Sistema de entregas
- ✅ Relatórios e dashboards analíticos
- ✅ Sistema de permissões granular por perfil
- ✅ Auditoria completa de todas as operações

---

## Arquitetura e Tecnologias

### Frontend
- **Framework**: React 18.3.1 com TypeScript
- **Build Tool**: Vite 5.4.1
- **Roteamento**: React Router DOM 6.26.2
- **UI Components**: shadcn-ui (Radix UI)
- **Estilização**: Tailwind CSS 3.4.11
- **Gerenciamento de Estado**: React Query (TanStack Query) 5.80.2
- **Formulários**: React Hook Form 7.53.0 + Zod 3.23.8
- **Gráficos**: Recharts 2.12.7
- **Notificações**: Sonner 1.5.0

### Backend
- **Banco de Dados**: Supabase (PostgreSQL)
- **Autenticação**: Supabase Auth
- **Storage**: Supabase Storage (para imagens de produtos)
- **API**: Supabase REST API + RPC Functions

### Segurança
- Hash bcrypt com salt 12 para senhas
- JWT tokens com expiração de 8 horas
- Row Level Security (RLS) no Supabase
- Sistema de bloqueio após tentativas falhas de login
- Auditoria completa de ações

---

## Descrição Detalhada de Todas as Telas

### 1. Tela de Login (`/login`)

**Arquivo**: `src/pages/Login.tsx`

**Descrição**: Tela inicial do sistema onde os usuários fazem autenticação.

**Elementos da Interface**:
- Campo de email com ícone de envelope
- Campo de senha com botão para mostrar/ocultar senha
- Botão de login com estado de carregamento
- Mensagens de erro exibidas em alertas
- Design com gradiente azul/índigo
- Card centralizado com logo do sistema

**Funcionalidades**:
- Validação de email obrigatório e formato válido
- Validação de senha mínima de 6 caracteres
- Exibição de erros de autenticação
- Redirecionamento automático se já autenticado
- Estado de loading durante autenticação

**Validações**:
- Email: obrigatório, formato válido
- Senha: mínimo 6 caracteres

---

### 2. Dashboard Principal (`/dashboard`)

**Arquivo**: `src/components/Dashboard.tsx`

**Descrição**: Tela principal com visão geral do sistema, estatísticas e ações rápidas.

**Elementos da Interface**:

#### Cards de Estatísticas (4 cards principais):
1. **Vendas Hoje**
   - Valor total de vendas do dia
   - Variação percentual desde ontem
   - Ícone: TrendingUp (verde)

2. **Pedidos Ativos**
   - Total de pedidos em andamento
   - Quantidade em preparo
   - Ícone: ShoppingCart (azul)

3. **Produtos**
   - Total de produtos cadastrados
   - Quantidade com estoque baixo
   - Ícone: Package (laranja)

4. **Clientes**
   - Total de clientes cadastrados
   - Novos clientes na semana
   - Ícone: Users (roxo)

#### Seção de Pedidos Recentes:
- Lista dos últimos pedidos do dia
- Exibe: número do pedido, nome do cliente, horário, valor total, status
- Badges coloridos por status
- Cards clicáveis com hover effect

#### Seção de Alertas e Notificações:
- Alertas de estoque baixo
- Alertas de pedidos pendentes
- Prioridades: Alta (vermelho), Média (amarelo), Baixa (azul)
- Ícones e cores diferenciadas por prioridade

#### Ações Rápidas:
- **Novo Pedido**: Navega para tela de pedidos
- **Cadastrar Produto**: Navega para tela de produtos
- **Novo Cliente**: Navega para tela de clientes
- **Relatório**: Navega para tela de relatórios
- Botões com gradientes coloridos e animação hover

**Funcionalidades**:
- Carregamento assíncrono de dados
- Atualização em tempo real
- Navegação rápida para outras telas
- Visualização de métricas principais

---

### 3. Tela de Produtos (`/dashboard/products`)

**Arquivo**: `src/components/Products.tsx`

**Descrição**: Gestão completa de produtos do catálogo.

**Elementos da Interface**:

#### Cabeçalho:
- Título "Produtos" com ícone
- Botão "Novo Produto" (se tiver permissão)
- Descrição da funcionalidade

#### Barra de Busca e Filtros:
- Campo de busca por nome ou categoria
- Filtro por categoria (dropdown)
- Filtro por tipo de produto (dropdown)
- Botão toggle "Estoque Baixo"
- Filtros aplicados em tempo real

#### Grid de Produtos:
Cada card de produto exibe:
- **Imagem do produto** (ou placeholder se não houver)
- **Badge de tipo**: Produção Própria, Revenda, Congelado, Ingrediente, Bebida, Doce, Salgado, Massa, Molho, Tempero, Outros
- **Badge "Estoque Baixo"** (se aplicável)
- **Nome do produto**
- **Categoria**
- **Descrição** (truncada)
- **Preço de venda** (destaque em verde)
- **Preço de custo** (texto menor)
- **Quantidade total** no estoque
- **Quantidade Pronta Entrega**
- **Quantidade Encomenda**
- **Botões de ação**: Editar, Excluir (conforme permissões)

#### Estatísticas Resumo:
- Total de produtos
- Produtos com estoque baixo
- Valor total em estoque

**Funcionalidades**:
- Criar novo produto
- Editar produto existente
- Excluir produto (com validação de dependências)
- Buscar produtos
- Filtrar por categoria, tipo e estoque baixo
- Visualizar detalhes do estoque
- Upload de imagens (via modal de formulário)

**Validações**:
- Nome obrigatório e único entre produtos ativos
- Preço de venda > 0
- Preço de custo ≥ 0
- Tipo de produto válido
- Não permite exclusão se tiver vendas ou movimentações

**Tipos de Produto**:
- `producao_propria`: Produção própria (pode ser vendido)
- `revenda`: Produto de revenda (pode ser vendido)
- `materia_prima`: Matéria prima (não aparece nas vendas)
- `congelado`: Produto congelado
- `ingrediente`: Ingrediente
- `bebida`: Bebida
- `doce`: Doce
- `salgado`: Salgado
- `massa`: Massa
- `molho`: Molho
- `tempero`: Tempero
- `outros`: Outros

---

### 4. Tela de Pedidos (`/dashboard/orders`)

**Arquivo**: `src/components/Orders.tsx`

**Descrição**: Gestão completa de pedidos com controle de status, pagamentos e entregas.

**Elementos da Interface**:

#### Cabeçalho:
- Título "Pedidos" com ícone
- Botão "Novo Pedido"
- Botão "Filtros" para expandir/colapsar filtros avançados
- Período de visualização (ex: "01/01/2024 até 07/01/2024")

#### Filtros Avançados (expansível):
- **Data Início**: Seletor de data
- **Data Fim**: Seletor de data
- **Tipo de Pedido**: Pronta Entrega ou Encomenda
- **Status**: Todos os status disponíveis
- **Status Pagamento**: Pendente, Parcial, Pago
- Botões de filtros rápidos: "Hoje", "7 dias", "30 dias"
- Botões: "Aplicar Filtros", "Limpar Filtros"

#### Lista de Pedidos:
Cada card de pedido exibe:
- **Número do pedido** (últimos 2 dígitos em badge circular)
- **Nome do cliente**
- **Telefone do cliente**
- **Data e hora** do pedido
- **Status do pedido** (badge colorido com ícone):
  - 📝 Pendente (cinza)
  - 👍 Aprovado (ciano)
  - ⏳ Aguardando Produção (laranja)
  - 👨‍🍳 Em Preparo (amarelo)
  - 📦 Em Separação (amarelo)
  - ✨ Produzido (roxo)
  - 🍽️ Pronto (azul)
  - 🚚 Em Entrega (índigo)
  - ✅ Entregue (verde)
  - 🎉 Concluído (verde)
  - ❌ Cancelado (vermelho)
- **Tipo de pedido** (badge):
  - ⚡ Pronta Entrega (verde)
  - 📅 Encomenda (azul)
- **Status de pagamento** (badge):
  - 💰 Pendente (vermelho)
  - 💰 Parcial (amarelo)
  - 💰 Pago (verde)
- **Data de entrega prevista** (apenas para encomendas)
- **Horário de entrega** (apenas para encomendas)
- **Forma de pagamento**
- **Valor pago** (se houver)
- **Endereço de entrega**
- **Observações gerais**
- **Observações de produção** (apenas para encomendas)
- **Observações de pagamento**
- **Lista de itens** com quantidade, nome e valor total
- **Valor total do pedido** (destaque em verde)
- **Botões de ação**:
  - Editar
  - Pagamento
  - Entregar (apenas se status = "pronto")
  - Cancelar (se não entregue/concluído)

#### Estatísticas (se disponível):
- Total de pedidos
- Pedidos pendentes
- Pedidos entregues
- Faturamento total

**Funcionalidades**:
- Criar novo pedido
- Editar pedido existente
- Cancelar pedido (com motivo)
- Registrar/atualizar pagamento
- Marcar como entregue
- Filtrar por data, tipo, status e pagamento
- Buscar por cliente, número ou telefone
- Visualizar histórico completo

**Validações**:
- Cliente obrigatório e existente
- Forma de pagamento obrigatória
- Pelo menos 1 item no pedido
- Para Pronta Entrega: verificação de estoque disponível
- Para Encomenda: sem verificação prévia de estoque
- Não permite cancelar pedidos entregues/concluídos

**Status do Pedido** (fluxo):
1. `pendente` → Pedido criado, aguardando aprovação
2. `aprovado` → Pedido aprovado, pode iniciar produção
3. `aguardando_producao` → Aguardando início da produção
4. `em_preparo` → Em processo de produção
5. `em_separacao` → Produtos sendo separados
6. `produzido` → Produção finalizada (gera entrada automática no estoque de encomenda)
7. `pronto` → Pronto para entrega
8. `em_entrega` → Em processo de entrega
9. `entregue` → Entregue ao cliente (gera saída automática do estoque)
10. `concluido` → Pedido concluído completamente
11. `cancelado` → Pedido cancelado

**Tipos de Pedido**:
- **Pronta Entrega**: Produtos já disponíveis no estoque
  - Verifica estoque na criação
  - Saída automática do estoque na criação
  - Mostra apenas estoque de pronta entrega
  
- **Encomenda**: Produtos serão produzidos
  - Não verifica estoque na criação
  - Entrada automática no estoque quando status muda para "produzido"
  - Saída automática do estoque quando entregue

---

### 5. Tela de Clientes (`/dashboard/customers`)

**Arquivo**: `src/components/Customers.tsx`

**Descrição**: Gestão completa da base de clientes.

**Elementos da Interface**:

#### Cabeçalho:
- Título "Clientes" com ícone
- Botão "Novo Cliente"

#### Barra de Busca e Filtros:
- Campo de busca por nome, telefone ou bairro
- Botões de filtro rápido: Todos, VIP, Ativos, Novos

#### Grid de Clientes:
Cada card de cliente exibe:
- **Nome do cliente**
- **Status** (badge colorido):
  - VIP (roxo)
  - Ativo (verde)
  - Novo (azul)
  - Inativo (cinza)
- **Telefone** com ícone
- **Bairro** com ícone de localização
- **Email** (se informado)
- **Endereço completo**
- **Observações** (se houver)
- **Estatísticas**:
  - Total de pedidos
  - Valor total gasto
  - Data do último pedido
- **Botões de ação**: Editar, Excluir

#### Estatísticas Resumo:
- Total de clientes
- Clientes VIP
- Novos clientes no mês
- Ticket médio

**Funcionalidades**:
- Criar novo cliente
- Editar cliente existente
- Excluir cliente (soft delete - marca como inativo)
- Buscar clientes
- Filtrar por status
- Visualizar histórico de compras
- Calcular estatísticas em tempo real

**Validações**:
- Nome obrigatório
- Tipo de pessoa: física ou jurídica
- CPF: 11 dígitos (se pessoa física)
- CNPJ: 14 dígitos (se pessoa jurídica)
- Email único (se informado)
- CPF/CNPJ único (se informado)
- Não permite exclusão se tiver pedidos (soft delete)

**Campos do Cliente**:
- Nome completo
- Tipo (Física/Jurídica)
- CPF/CNPJ
- Email
- Telefone
- Endereço
- Bairro
- Cidade
- CEP
- Observações

---

### 6. Tela de Estoque (`/dashboard/stock`)

**Arquivo**: `src/components/Stock.tsx`

**Descrição**: Controle completo de movimentações de estoque.

**Elementos da Interface**:

#### Cabeçalho:
- Título "Controle de Estoque" com ícone
- Botão "Nova Movimentação"

#### Alerta de Estoque Baixo:
- Card destacado em laranja
- Lista de produtos com estoque abaixo do mínimo
- Exibe: nome, categoria, quantidade atual, quantidade mínima

#### Barra de Busca e Filtros:
- Campo de busca por produto ou motivo
- Filtro por tipo de movimentação: Entrada, Saída, Ajuste

#### Lista de Movimentações:
Cada card de movimentação exibe:
- **Ícone do tipo** de movimentação:
  - ↑ Entrada (verde)
  - ↓ Saída (vermelho)
  - ⚠️ Ajuste (azul)
- **Nome do produto**
- **Tipo de movimentação** (badge colorido)
- **Motivo** da movimentação
- **Data e hora** da movimentação
- **Quantidade** (com sinal +, - ou =)
- **Valor** (se informado)
- **Documento de referência** (se houver)
- **Data de fabricação** (se informada)
- **Data de validade** (se informada)
- **Botões de ação**: Editar, Excluir

#### Estatísticas Resumo:
- Total de entradas
- Total de saídas
- Produtos em falta
- Valor total do estoque

**Funcionalidades**:
- Criar nova movimentação (entrada, saída ou ajuste)
- Editar movimentação existente
- Excluir movimentação (com validação)
- Buscar movimentações
- Filtrar por tipo
- Visualizar alertas de estoque baixo
- Ver relatório completo de estoque

**Validações**:
- Produto deve existir
- Estoque suficiente para saídas
- Não permite estoque negativo
- Verificação por tipo de estoque (pronta_entrega/encomenda)
- Não permite exclusão de movimentações automáticas de pedidos
- Edição reverte movimentação anterior e aplica nova

**Tipos de Movimentação**:
- **Entrada**: Aumenta o estoque
- **Saída**: Diminui o estoque (com verificação)
- **Ajuste**: Define quantidade absoluta

**Regras Especiais**:
- **Nhoques**: Cálculo automático de validade (3 meses a partir da data de fabricação)
- **Movimentações Automáticas**: Geradas automaticamente por pedidos (não podem ser excluídas)

---

### 7. Tela de Entregas (`/dashboard/deliveries`)

**Arquivo**: `src/components/Deliveries.tsx`

**Descrição**: Gestão de entregas e rotas.

**Elementos da Interface**:

#### Cabeçalho:
- Título "Entregas" com ícone
- Botão "Nova Entrega"

#### Barra de Busca e Filtros:
- Campo de busca por cliente, bairro, entregador ou pedido
- Botões de filtro: Todas, Pendentes, A Caminho, Centro

#### Lista de Entregas:
Cada card de entrega exibe:
- **Ícone de caminhão** (badge circular)
- **Cliente e número do pedido**
- **Status** (badge colorido com ícone):
  - ✅ Entregue (verde)
  - 🚚 A caminho (azul)
  - ⏳ Pendente (amarelo)
  - ❌ Não entregue (vermelho)
- **Endereço completo** com ícone de localização
- **Horário previsto** com ícone de relógio
- **Entregador** com ícone de usuário
- **Forma de pagamento**
- **Observações** (se houver)
- **Valor total** (destaque em verde)
- **Botões de ação**:
  - Iniciar Entrega (se pendente)
  - Confirmar Entrega (se a caminho)
  - Reagendar (se não entregue)
  - Editar
  - Excluir

#### Estatísticas Resumo:
- Total de entregas hoje
- Pendentes
- A caminho
- Entregues

**Funcionalidades**:
- Criar nova entrega
- Editar entrega existente
- Excluir entrega
- Iniciar entrega
- Confirmar entrega
- Reagendar entrega
- Buscar entregas
- Filtrar por status

**Status de Entrega**:
- `Pendente`: Aguardando início
- `A caminho`: Em processo de entrega
- `Entregue`: Entregue com sucesso
- `Não entregue`: Não foi possível entregar

---

### 8. Tela de Relatórios (`/dashboard/reports`)

**Arquivo**: `src/components/Reports.tsx`

**Descrição**: Relatórios analíticos e gráficos do sistema.

**Elementos da Interface**:

#### Cabeçalho:
- Título "Relatórios" com ícone
- Botão "Filtros"
- Botão "Exportar"

#### Seletor de Período:
- Botões: Últimos 7 dias, Últimos 30 dias, Este mês, Personalizado
- Período selecionado destacado

#### Cards de KPIs (4 cards principais):
1. **Receita Total**
   - Valor formatado em moeda
   - Variação percentual vs período anterior
   - Ícone: DollarSign (verde)

2. **Pedidos**
   - Total de pedidos
   - Variação percentual vs período anterior
   - Ícone: BarChart3 (azul)

3. **Ticket Médio**
   - Valor médio por pedido
   - Variação percentual vs período anterior
   - Ícone: TrendingUp (roxo)

4. **Taxa de Conversão**
   - Percentual de conversão
   - Variação percentual vs período anterior
   - Ícone: Calendar (laranja)

#### Relatório Financeiro e de Pedidos:
- **KPIs Financeiros**:
  - Valor Total dos Pedidos
  - Valor Pago
  - Valor Pendente
  - Ticket Médio
- **KPIs de Quantidade**:
  - Total de Pedidos
  - Pedidos Entregues
  - Pedidos Pendentes
  - Pedidos Cancelados (se houver)
- **Gráfico de Barras**: Distribuição de valores (Total, Pago, Pendente)

#### Gráficos:
1. **Vendas por Dia** (Gráfico de Barras)
   - Receita e número de pedidos dos últimos 7 dias
   - Eixo X: Dias da semana
   - Eixo Y: Valores

2. **Métodos de Pagamento** (Gráfico de Pizza)
   - Distribuição percentual dos métodos de pagamento
   - Cores diferenciadas por método
   - Labels com percentuais

3. **Produtos Mais Vendidos** (Lista Ranking)
   - Top produtos por quantidade vendida
   - Exibe: posição, nome, quantidade vendida, receita gerada
   - Badges numerados

4. **Pedidos por Bairro** (Gráfico de Barras Horizontais)
   - Distribuição geográfica dos pedidos
   - Exibe: nome do bairro, quantidade de pedidos, percentual
   - Barras de progresso coloridas

#### Seção de Exportação:
- Botões para exportar em diferentes formatos:
  - Relatório de Vendas (PDF)
  - Dados de Produtos (Excel)
  - Relatório Financeiro (PDF)

**Funcionalidades**:
- Visualizar métricas em tempo real
- Filtrar por período
- Exportar relatórios
- Visualizar gráficos interativos
- Analisar tendências
- Comparar períodos

**Dados Exibidos**:
- Receita total e variações
- Total de pedidos
- Ticket médio
- Taxa de conversão
- Vendas por dia
- Top produtos
- Distribuição por método de pagamento
- Distribuição geográfica

---

### 9. Tela de Usuários (`/dashboard/users`)

**Arquivo**: `src/components/Users.tsx`

**Descrição**: Gestão de usuários e permissões do sistema.

**Elementos da Interface**:

#### Cabeçalho:
- Título "Usuários" com ícone
- Botão "Gerenciar Permissões"
- Botão "Novo Usuário" (se tiver permissão)

#### Barra de Busca:
- Campo de busca por nome, email ou perfil

#### Lista de Usuários:
Cada card de usuário exibe:
- **Avatar** com iniciais (badge circular)
- **Nome do usuário**
- **Email**
- **Perfil** (badge colorido)
- **Status**: Ativo/Inativo
- **Último acesso**: Data formatada ou "Nunca"
- **Botões de ação**:
  - Editar (se tiver permissão)
  - Ativar/Desativar (se tiver permissão e não for o próprio usuário)

#### Modal de Formulário:
- **Campos**:
  - Nome completo (obrigatório)
  - Email (obrigatório, único)
  - Senha (obrigatório para novos, opcional para edição)
  - Perfil (dropdown com perfis disponíveis)
  - Status Ativo (checkbox)
- **Validações**:
  - Nome mínimo 2 caracteres
  - Email válido e único
  - Senha mínimo 6 caracteres (se informada)
  - Perfil obrigatório

#### Modal de Gerenciamento de Permissões:
- Interface completa para gerenciar perfis e permissões
- Criar, editar e excluir perfis
- Configurar permissões por página e ação

**Funcionalidades**:
- Criar novo usuário
- Editar usuário existente
- Ativar/Desativar usuário
- Alterar perfil do usuário
- Resetar senha
- Gerenciar perfis e permissões
- Buscar usuários
- Visualizar último acesso

**Validações**:
- Nome mínimo 2 caracteres
- Email válido e único
- Perfil válido e ativo
- Senha mínimo 6 caracteres (se informada)
- Não permite autodesativação
- Não permite editar próprio perfil (dependendo da configuração)

**Perfis Padrão**:
- **Administrador**: Acesso total
- **Gerente**: Operações e relatórios
- **Vendedor**: Vendas e clientes
- **Operacional**: Estoque e entregas

---

### 10. Tela de Perfil do Usuário (`/dashboard/profile`)

**Arquivo**: `src/components/Profile.tsx`

**Descrição**: Tela onde o usuário pode visualizar e editar suas próprias informações.

**Elementos da Interface**:

#### Cabeçalho:
- Avatar com iniciais do usuário
- Nome completo
- Email
- Badge do perfil (colorido)

#### Card de Informações da Conta:
- **Email**: Exibido como somente leitura (não pode ser alterado)
- **Perfil**: Exibido como somente leitura (definido pelo administrador)
- Explicações sobre por que não podem ser alterados

#### Card de Alterar Nome:
- Campo de texto para nome completo
- Botão "Salvar Nome"
- Validação: mínimo 2 caracteres
- Estado de loading durante atualização

#### Card de Alterar Senha:
- **Senha Atual**: Campo obrigatório
- **Nova Senha**: Campo obrigatório (mínimo 6 caracteres)
- **Confirmar Nova Senha**: Campo obrigatório
- Botão "Alterar Senha"
- Card informativo com requisitos da senha
- Validações:
  - Todos os campos obrigatórios
  - Nova senha mínimo 6 caracteres
  - Nova senha deve ser diferente da atual
  - Confirmação deve ser igual à nova senha

**Funcionalidades**:
- Visualizar informações da conta
- Alterar nome de exibição
- Alterar senha
- Visualizar perfil atribuído

**Validações**:
- Nome mínimo 2 caracteres
- Senha atual obrigatória
- Nova senha mínimo 6 caracteres
- Nova senha diferente da atual
- Confirmação igual à nova senha

---

### 11. Sidebar de Navegação

**Arquivo**: `src/components/AppSidebar.tsx`

**Descrição**: Menu lateral de navegação do sistema.

**Elementos da Interface**:

#### Cabeçalho:
- Logo do sistema (ícone + nome)
- Subtítulo "Sistema Completo"

#### Menu Principal:
Itens do menu (filtrados por permissões):
- 🏠 **Dashboard** (sempre visível)
- 📦 **Produtos** (se tiver permissão)
- 🛒 **Pedidos** (se tiver permissão)
- 👥 **Clientes** (se tiver permissão)
- 📊 **Estoque** (se tiver permissão)
- 🚚 **Entregas** (se tiver permissão)
- 📈 **Relatórios** (se tiver permissão)
- 👤 **Usuários** (se tiver permissão)

Cada item:
- Ícone representativo
- Nome da página
- Estado ativo destacado com gradiente
- Hover effect

#### Rodapé:
- **Informações do Usuário**:
  - Avatar com iniciais
  - Nome do usuário
  - Perfil do usuário
- **Botão "Meu Perfil"**: Navega para tela de perfil
- **Botão "Sair"**: Faz logout do sistema

**Funcionalidades**:
- Navegação entre páginas
- Filtro automático por permissões
- Destaque da página ativa
- Exibição de informações do usuário
- Acesso rápido ao perfil
- Logout

**Comportamento**:
- Menu responsivo (colapsável em mobile)
- Loading skeleton enquanto carrega permissões
- Mensagem quando não há itens disponíveis
- Itens sempre visíveis (Dashboard) vs condicionais (outros)

---

## Regras de Negócio Completas

### 🔐 Autenticação e Segurança

#### Validações de Login
- ✅ Email obrigatório e válido
- ✅ Senha mínima de 6 caracteres
- ✅ Verificação de usuário existente
- ✅ Verificação de usuário ativo
- ✅ Verificação de bloqueio temporário

#### Sistema de Tentativas
- ✅ Incremento de tentativas de login falhas
- ✅ Bloqueio automático após 5 tentativas por 30 minutos
- ✅ Reset de tentativas em login bem-sucedido
- ✅ Registro de todas as tentativas (IP, User-Agent, sucesso/falha)

#### Segurança
- ✅ Hash bcrypt com salt 12 para senhas
- ✅ Nunca usar campo "senha" em texto plano
- ✅ Usar apenas "senha_hash" para verificações
- ✅ Sessões com expiração de 8 horas
- ✅ Desativação de sessões no logout
- ✅ Verificação de expiração de token

#### Auditoria
- ✅ Log de todas as ações de autenticação
- ✅ Registro de IP e User-Agent
- ✅ Auditoria de LOGIN/LOGOUT

---

### 📦 Pedidos

#### Validações de Criação
- ✅ Cliente obrigatório e existente
- ✅ Forma de pagamento obrigatória
- ✅ Itens obrigatórios (pelo menos 1)
- ✅ Cálculo automático de valor total
- ✅ Geração automática de número sequencial

#### Tipos de Pedido

**Pronta Entrega**:
- ✅ Verificação de estoque disponível na criação
- ✅ Saída automática do estoque na criação
- ✅ Mostra apenas estoque de pronta entrega
- ✅ Produtos sem estoque aparecem desabilitados

**Encomenda**:
- ✅ Sem verificação prévia de estoque
- ✅ Todos os produtos aparecem disponíveis
- ✅ Entrada automática no estoque quando status muda para "produzido"
- ✅ Saída automática do estoque quando entregue

#### Movimentação Automática de Estoque

**Produção Finalizada (em_preparo → produzido)**:
- ✅ Entrada automática no estoque de ENCOMENDA
- ✅ Log de operação automática
- ✅ Atualização de quantidade_encomenda
- ✅ Marcação de estoque_processado para evitar duplicações

**Entrega Realizada (pronto → entregue)**:
- ✅ Saída automática do estoque apropriado
- ✅ Verificação de estoque suficiente
- ✅ Diferenciação entre pronta_entrega e encomenda

#### Status e Transições
- ✅ Status válidos: pendente, aprovado, aguardando_producao, em_preparo, em_separacao, produzido, pronto, em_entrega, entregue, concluido, cancelado
- ✅ Validação de transições de status
- ✅ Normalização de status

#### Pagamentos
- ✅ Status: pendente, pago, parcial
- ✅ Controle de valor pago vs valor total
- ✅ Marcação automática como pago na entrega
- ✅ Data de pagamento automática

#### Cancelamento
- ✅ Não permitir cancelar pedidos entregues/concluídos
- ✅ Registro do motivo de cancelamento

---

### 📊 Estoque

#### Tipos de Estoque
- ✅ **Pronta Entrega**: produtos disponíveis para venda imediata
- ✅ **Encomenda**: produtos produzidos sob demanda
- ✅ Controle separado de quantidades

#### Movimentações
- ✅ **Entrada**: aumenta estoque
- ✅ **Saída**: diminui estoque (com verificação de disponibilidade)
- ✅ **Ajuste**: define quantidade absoluta

#### Regras Especiais para Nhoques
- ✅ **Cálculo Automático de Validade**: 3 meses a partir da data de fabricação
- ✅ Aplicado automaticamente em movimentações de "Produção"

#### Validações
- ✅ Produto deve existir
- ✅ Estoque suficiente para saídas
- ✅ Não permitir estoque negativo
- ✅ Verificação por tipo de estoque (pronta_entrega/encomenda)

#### Operações Automáticas
- ✅ Não permitir exclusão de movimentações automáticas de pedidos
- ✅ Log de todas as operações automáticas
- ✅ Rastreabilidade completa

#### Reversão
- ✅ Edição de movimentação: reverter → aplicar nova
- ✅ Exclusão: verificar se não causará estoque negativo
- ✅ Atualização automática de quantidades

---

### 🛍️ Produtos

#### Validações
- ✅ Nome obrigatório e único (ativos)
- ✅ Preço de venda > 0
- ✅ Preço de custo ≥ 0
- ✅ Tipo válido

#### Tipos de Produto
- ✅ **Produção Própria**: pode ser vendido
- ✅ **Revenda**: pode ser vendido
- ✅ **Matéria Prima**: não aparece nas vendas

#### Upload de Imagens
- ✅ Tipos permitidos: jpeg, jpg, png, gif
- ✅ Tamanho máximo: 10MB
- ✅ Nome único para evitar conflitos
- ✅ Integração com Supabase Storage

#### Dependências
- ✅ Não permitir exclusão se tiver vendas
- ✅ Não permitir exclusão se tiver movimentações
- ✅ Verificação de relacionamentos

#### Estoque Inicial
- ✅ Criação automática de registro no estoque
- ✅ Quantidades zeradas inicialmente

#### Formatação
- ✅ Conversão e validação de tipos numéricos
- ✅ Tratamento de campos nulos/undefined
- ✅ Unidade de medida padrão

---

### 👥 Clientes

#### Validações Básicas
- ✅ Nome obrigatório
- ✅ Tipo de pessoa: fisica ou juridica
- ✅ Email único (se informado)
- ✅ CPF/CNPJ único (se informado)

#### Validações por Tipo
- ✅ **Pessoa Física**: CPF com 11 dígitos
- ✅ **Pessoa Jurídica**: CNPJ com 14 dígitos
- ✅ Remoção automática de caracteres especiais

#### Tratamento de Dados
- ✅ Campos vazios convertidos para null
- ✅ Email sempre em lowercase
- ✅ Trim em campos de texto
- ✅ Normalização de CPF/CNPJ

#### Exclusão Segura
- ✅ **Soft Delete**: marca como inativo
- ✅ Não permitir exclusão se tiver pedidos
- ✅ Possibilidade de reativação

#### Estatísticas
- ✅ Total de pedidos por cliente
- ✅ Data do último pedido
- ✅ Valor total gasto
- ✅ Cálculo em tempo real

#### Busca Avançada
- ✅ Busca por nome, email, telefone, CPF/CNPJ
- ✅ Case-insensitive
- ✅ Busca parcial (LIKE)

---

### 👤 Usuários

#### Validações
- ✅ Nome mínimo 2 caracteres
- ✅ Email válido e único
- ✅ Perfil válido e ativo
- ✅ Senha padrão se não informada

#### Segurança
- ✅ Hash bcrypt para senhas
- ✅ Não permitir autodesativação
- ✅ Reset de senhas por administradores
- ✅ Desativação de sessões em mudanças críticas

#### Perfis e Permissões
- ✅ Verificação de perfil ativo
- ✅ Controle de permissões por perfil
- ✅ Auditoria de mudanças de perfil

#### Bloqueios e Ativação
- ✅ Desativação de usuário
- ✅ Reativação de usuário
- ✅ Reset de tentativas de login
- ✅ Limpeza de bloqueios

#### Auditoria Completa
- ✅ Criação, edição, desativação
- ✅ Reset de senhas
- ✅ Mudanças de perfil
- ✅ Log de ações administrativas

#### Paginação e Filtros
- ✅ Paginação com limite configurável
- ✅ Busca por nome e email
- ✅ Filtro por perfil
- ✅ Filtro por status (ativo/inativo)

---

### 📋 Auditoria e Logs

#### Sistema de Auditoria
- ✅ Registro de todas as ações CRUD
- ✅ Dados antes e depois das alterações
- ✅ IP e User-Agent
- ✅ Usuário responsável pela ação

#### Tipos de Ação
- ✅ CREATE, UPDATE, DELETE
- ✅ LOGIN, LOGOUT
- ✅ ACTIVATE, DEACTIVATE
- ✅ RESET_PASSWORD
- ✅ CHANGE_PASSWORD

#### Log de Operações Automáticas
- ✅ Movimentações automáticas de estoque
- ✅ Produtos afetados
- ✅ Status anterior e novo
- ✅ Observações detalhadas

#### Tentativas de Login
- ✅ Todas as tentativas (sucesso/falha)
- ✅ Motivo da falha
- ✅ IP e User-Agent
- ✅ Controle de tentativas por usuário

---

## Sistema de Permissões

### Estrutura de Permissões

O sistema utiliza um modelo de permissões baseado em **páginas** e **ações**:

#### Páginas Disponíveis
- `dashboard`: Dashboard principal
- `produtos`: Gestão de produtos
- `pedidos`: Gestão de pedidos
- `clientes`: Gestão de clientes
- `estoque`: Controle de estoque
- `entregas`: Gestão de entregas
- `relatorios`: Relatórios e análises
- `usuarios`: Gestão de usuários
- `configuracoes`: Configurações do sistema

#### Ações Disponíveis
- `visualizar`: Visualizar dados
- `criar`: Criar novos registros
- `editar`: Editar registros existentes
- `excluir`: Excluir registros
- `aprovar`: Aprovar pedidos
- `cancelar`: Cancelar pedidos
- `exportar`: Exportar dados
- `imprimir`: Imprimir relatórios

### Perfis Padrão

#### 🔴 Administrador
- **Acesso**: Todas as páginas e funcionalidades
- **Páginas**: Dashboard, Produtos, Pedidos, Clientes, Estoque, Entregas, Relatórios, Usuários, Configurações
- **Permissões**: Acesso total (criar, editar, excluir, aprovar, etc.)

#### 🔵 Gerente
- **Acesso**: Operações e relatórios (sem usuários e configurações)
- **Páginas**: Dashboard, Produtos, Pedidos, Clientes, Estoque, Entregas, Relatórios
- **Permissões**: Pode criar, editar, aprovar, cancelar e exportar

#### 🟢 Vendedor
- **Acesso**: Apenas vendas e clientes
- **Páginas**: Dashboard, Pedidos, Clientes
- **Permissões**: Pode visualizar, criar, editar e exportar

#### 🟡 Operacional
- **Acesso**: Estoque e entregas
- **Páginas**: Dashboard, Produtos (só visualizar), Estoque, Entregas
- **Permissões**: Pode visualizar e editar estoque/entregas

### Implementação

#### Menu Lateral
- Mostra apenas páginas que o usuário tem acesso
- Dashboard sempre visível
- Loading skeleton enquanto carrega permissões

#### Componentes Protegidos
- Páginas verificam permissões antes de renderizar
- Botões de ação (criar, editar, excluir) aparecem conforme permissões
- Mensagens de "Acesso Negado" quando necessário

#### Hooks Disponíveis
```typescript
// Verificar permissões de uma página
const { hasActionAccess } = usePageAccess('produtos');
if (hasActionAccess('criar')) {
  // Mostrar botão criar
}

// Verificar permissões gerais
const { hasPageAccess, hasActionAccess } = usePermissions();
if (hasPageAccess('usuarios')) {
  // Usuário pode acessar página de usuários
}
```

---

## Fluxos Principais

### Fluxo de Criação de Pedido

1. **Usuário clica em "Novo Pedido"**
2. **Modal de formulário abre**
3. **Seleção do tipo de pedido**:
   - Pronta Entrega: Verifica estoque disponível
   - Encomenda: Não verifica estoque
4. **Seleção do cliente** (obrigatório)
5. **Adição de itens**:
   - Para Pronta Entrega: Mostra apenas produtos com estoque
   - Para Encomenda: Mostra todos os produtos
6. **Preenchimento de informações**:
   - Forma de pagamento (obrigatório)
   - Endereço de entrega
   - Data/horário de entrega (para encomendas)
   - Observações
7. **Cálculo automático do valor total**
8. **Validação**:
   - Cliente válido
   - Pelo menos 1 item
   - Estoque suficiente (se pronta entrega)
9. **Criação do pedido**
10. **Movimentação automática de estoque** (se pronta entrega)
11. **Atualização da lista de pedidos**

### Fluxo de Produção de Encomenda

1. **Pedido criado como "Encomenda"**
2. **Status inicial**: `pendente`
3. **Aprovação**: Status muda para `aprovado`
4. **Início da produção**: Status muda para `em_preparo`
5. **Produção finalizada**: Status muda para `produzido`
   - **Ação automática**: Entrada no estoque de encomenda
   - Registro de movimentação automática
6. **Separação**: Status muda para `em_separacao` (opcional)
7. **Pronto para entrega**: Status muda para `pronto`
8. **Entrega**: Status muda para `entregue`
   - **Ação automática**: Saída do estoque de encomenda
   - Marcação automática como pago (se configurado)
9. **Conclusão**: Status muda para `concluido`

### Fluxo de Movimentação de Estoque

1. **Usuário cria nova movimentação**
2. **Seleção do tipo**:
   - Entrada: Aumenta estoque
   - Saída: Diminui estoque (com verificação)
   - Ajuste: Define quantidade absoluta
3. **Seleção do produto**
4. **Informação da quantidade**
5. **Preenchimento de motivo** (obrigatório)
6. **Informações opcionais**:
   - Valor
   - Documento de referência
   - Data de fabricação
   - Data de validade (calculada automaticamente para nhoques)
7. **Validação**:
   - Produto existe
   - Estoque suficiente (se saída)
   - Não causará estoque negativo
8. **Criação da movimentação**
9. **Atualização automática do estoque**
10. **Registro na auditoria**

### Fluxo de Autenticação

1. **Usuário acessa a tela de login**
2. **Preenchimento de email e senha**
3. **Validação dos campos**
4. **Verificação de tentativas de login**:
   - Se bloqueado: Exibe mensagem e bloqueia por 30 minutos
   - Se não bloqueado: Continua
5. **Verificação de credenciais**:
   - Email existe
   - Usuário está ativo
   - Senha correta
6. **Registro da tentativa** (sucesso ou falha)
7. **Se sucesso**:
   - Reset de tentativas
   - Criação de sessão
   - Geração de token JWT
   - Redirecionamento para dashboard
8. **Se falha**:
   - Incremento de tentativas
   - Bloqueio se atingir 5 tentativas
   - Exibição de mensagem de erro

### Fluxo de Gestão de Permissões

1. **Administrador acessa "Gerenciar Permissões"**
2. **Visualização de perfis existentes**
3. **Opções**:
   - Criar novo perfil
   - Editar perfil existente
   - Excluir perfil (se não houver usuários)
4. **Configuração de permissões**:
   - Seleção de páginas acessíveis
   - Seleção de ações permitidas por página
5. **Salvamento do perfil**
6. **Atribuição a usuários**:
   - Na criação de usuário
   - Na edição de usuário
7. **Aplicação imediata**:
   - Menu atualizado
   - Componentes protegidos verificam novas permissões
   - Botões de ação aparecem/desaparecem conforme permissões

---

## Resumo Executivo

### Funcionalidades Principais

✅ **Gestão de Produtos**: Cadastro completo com imagens, tipos, categorias e controle de estoque separado

✅ **Gestão de Pedidos**: Dois tipos (Pronta Entrega/Encomenda) com fluxo completo de status e movimentações automáticas de estoque

✅ **Gestão de Clientes**: Base completa com histórico de compras, estatísticas e soft delete

✅ **Controle de Estoque**: Movimentações manuais e automáticas com rastreabilidade completa

✅ **Gestão de Entregas**: Controle de rotas e status de entrega

✅ **Relatórios Analíticos**: Dashboards com gráficos, KPIs e exportação

✅ **Gestão de Usuários**: Sistema completo com perfis e permissões granulares

✅ **Segurança**: Autenticação robusta, auditoria completa e controle de acesso

### Tecnologias Utilizadas

- **Frontend**: React + TypeScript + Vite + Tailwind CSS
- **Backend**: Supabase (PostgreSQL)
- **Autenticação**: Supabase Auth
- **Storage**: Supabase Storage
- **UI**: shadcn-ui (Radix UI)

### Regras de Negócio

- ✅ 100% das validações mantidas
- ✅ 100% da lógica de estoque preservada
- ✅ 100% da segurança implementada
- ✅ 100% da auditoria mantida
- ✅ 100% das regras especiais preservadas
- ✅ 100% da compatibilidade com frontend existente

---

**Documento gerado em**: 2024  
**Versão do Sistema**: 0.0.0  
**Última atualização**: Análise completa do projeto





