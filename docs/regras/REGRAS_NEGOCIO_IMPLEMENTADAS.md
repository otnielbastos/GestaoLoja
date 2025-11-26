# REGRAS DE NEGÓCIO IMPLEMENTADAS

Todas as regras de negócio do servidor Node.js/MySQL foram migradas para Supabase mantendo 100% da funcionalidade.

## 🔐 AUTENTICAÇÃO (authService)

### Validações de Login
- ✅ Email obrigatório e válido
- ✅ Senha mínima de 6 caracteres
- ✅ Verificação de usuário existente
- ✅ Verificação de usuário ativo
- ✅ Verificação de bloqueio temporário

### Sistema de Tentativas
- ✅ Incremento de tentativas de login falhas
- ✅ Bloqueio automático após 5 tentativas por 30 minutos
- ✅ Reset de tentativas em login bem-sucedido
- ✅ Registro de todas as tentativas (IP, User-Agent, sucesso/falha)

### Segurança
- ✅ Hash bcrypt com salt 12 para senhas
- ✅ Nunca usar campo "senha" em texto plano
- ✅ Usar apenas "senha_hash" para verificações
- ✅ Sessões com expiração de 8 horas
- ✅ Desativação de sessões no logout
- ✅ Verificação de expiração de token

### Auditoria
- ✅ Log de todas as ações de autenticação
- ✅ Registro de IP e User-Agent
- ✅ Auditoria de LOGIN/LOGOUT

## 📦 PEDIDOS (pedidosService)

### Validações de Criação
- ✅ Cliente obrigatório e existente
- ✅ Forma de pagamento obrigatória
- ✅ Itens obrigatórios (pelo menos 1)
- ✅ Cálculo automático de valor total
- ✅ Geração automática de número sequencial

### Tipos de Pedido
- ✅ Pronta entrega: verificação de estoque disponível
- ✅ Encomenda: sem verificação prévia de estoque
- ✅ Tratamento diferenciado por tipo

### Movimentação Automática de Estoque
- ✅ **Produção Finalizada (em_preparo → produzido)**: 
  - Entrada automática no estoque de ENCOMENDA
  - Log de operação automática
  - Atualização de quantidade_encomenda

- ✅ **Entrega Realizada (pronto → entregue)**:
  - Saída automática do estoque apropriado
  - Verificação de estoque suficiente
  - Diferenciação entre pronta_entrega e encomenda

### Status e Transições
- ✅ Status válidos: pendente, aprovado, aguardando_producao, em_preparo, em_separacao, produzido, pronto, em_entrega, entregue, concluido, cancelado
- ✅ Validação de transições de status
- ✅ Normalização de status

### Pagamentos
- ✅ Status: pendente, pago, parcial
- ✅ Controle de valor pago vs valor total
- ✅ Marcação automática como pago na entrega
- ✅ Data de pagamento automática

### Cancelamento
- ✅ Não permitir cancelar pedidos entregues/concluídos
- ✅ Registro do motivo de cancelamento

## 📊 ESTOQUE (estoqueService)

### Tipos de Estoque
- ✅ **Pronta Entrega**: produtos disponíveis para venda imediata
- ✅ **Encomenda**: produtos produzidos sob demanda
- ✅ Controle separado de quantidades

### Movimentações
- ✅ **Entrada**: aumenta estoque
- ✅ **Saída**: diminui estoque (com verificação de disponibilidade)
- ✅ **Ajuste**: define quantidade absoluta

### Regras Especiais para Nhoques
- ✅ **Cálculo Automático de Validade**: 3 meses a partir da data de fabricação
- ✅ Aplicado automaticamente em movimentações de "Produção"

### Validações
- ✅ Produto deve existir
- ✅ Estoque suficiente para saídas
- ✅ Não permitir estoque negativo
- ✅ Verificação por tipo de estoque (pronta_entrega/encomenda)

### Operações Automáticas
- ✅ Não permitir exclusão de movimentações automáticas de pedidos
- ✅ Log de todas as operações automáticas
- ✅ Rastreabilidade completa

### Reversão
- ✅ Edição de movimentação: reverter → aplicar nova
- ✅ Exclusão: verificar se não causará estoque negativo
- ✅ Atualização automática de quantidades

## 🛍️ PRODUTOS (produtosService)

### Validações
- ✅ Nome obrigatório e único (ativos)
- ✅ Preço de venda > 0
- ✅ Preço de custo ≥ 0
- ✅ Tipo válido: producao_propria, revenda, materia_prima

### Tipos de Produto
- ✅ **Produção Própria**: pode ser vendido
- ✅ **Revenda**: pode ser vendido
- ✅ **Matéria Prima**: não aparece nas vendas

### Upload de Imagens
- ✅ Tipos permitidos: jpeg, jpg, png, gif
- ✅ Tamanho máximo: 10MB
- ✅ Nome único para evitar conflitos
- ✅ Integração com Supabase Storage

### Dependências
- ✅ Não permitir exclusão se tiver vendas
- ✅ Não permitir exclusão se tiver movimentações
- ✅ Verificação de relacionamentos

### Estoque Inicial
- ✅ Criação automática de registro no estoque
- ✅ Quantidades zeradas inicialmente

### Formatação
- ✅ Conversão e validação de tipos numéricos
- ✅ Tratamento de campos nulos/undefined
- ✅ Unidade de medida padrão

## 👥 CLIENTES (clientesService)

### Validações Básicas
- ✅ Nome obrigatório
- ✅ Tipo de pessoa: fisica ou juridica
- ✅ Email único (se informado)
- ✅ CPF/CNPJ único (se informado)

### Validações por Tipo
- ✅ **Pessoa Física**: CPF com 11 dígitos
- ✅ **Pessoa Jurídica**: CNPJ com 14 dígitos
- ✅ Remoção automática de caracteres especiais

### Tratamento de Dados
- ✅ Campos vazios convertidos para null
- ✅ Email sempre em lowercase
- ✅ Trim em campos de texto
- ✅ Normalização de CPF/CNPJ

### Exclusão Segura
- ✅ **Soft Delete**: marca como inativo
- ✅ Não permitir exclusão se tiver pedidos
- ✅ Possibilidade de reativação

### Estatísticas
- ✅ Total de pedidos por cliente
- ✅ Data do último pedido
- ✅ Valor total gasto
- ✅ Cálculo em tempo real

### Busca Avançada
- ✅ Busca por nome, email, telefone, CPF/CNPJ
- ✅ Case-insensitive
- ✅ Busca parcial (LIKE)

## 👤 USUÁRIOS (usuariosService)

### Validações
- ✅ Nome mínimo 2 caracteres
- ✅ Email válido e único
- ✅ Perfil válido e ativo
- ✅ Senha padrão se não informada

### Segurança
- ✅ Hash bcrypt para senhas
- ✅ Não permitir autodesativação
- ✅ Reset de senhas por administradores
- ✅ Desativação de sessões em mudanças críticas

### Perfis e Permissões
- ✅ Verificação de perfil ativo
- ✅ Controle de permissões por perfil
- ✅ Auditoria de mudanças de perfil

### Bloqueios e Ativação
- ✅ Desativação de usuário
- ✅ Reativação de usuário
- ✅ Reset de tentativas de login
- ✅ Limpeza de bloqueios

### Auditoria Completa
- ✅ Criação, edição, desativação
- ✅ Reset de senhas
- ✅ Mudanças de perfil
- ✅ Log de ações administrativas

### Paginação e Filtros
- ✅ Paginação com limite configurável
- ✅ Busca por nome e email
- ✅ Filtro por perfil
- ✅ Filtro por status (ativo/inativo)

## 📋 AUDITORIA E LOGS

### Sistema de Auditoria
- ✅ Registro de todas as ações CRUD
- ✅ Dados antes e depois das alterações
- ✅ IP e User-Agent
- ✅ Usuário responsável pela ação

### Tipos de Ação
- ✅ CREATE, UPDATE, DELETE
- ✅ LOGIN, LOGOUT
- ✅ ACTIVATE, DEACTIVATE
- ✅ RESET_PASSWORD
- ✅ CHANGE_PASSWORD

### Log de Operações Automáticas
- ✅ Movimentações automáticas de estoque
- ✅ Produtos afetados
- ✅ Status anterior e novo
- ✅ Observações detalhadas

### Tentativas de Login
- ✅ Todas as tentativas (sucesso/falha)
- ✅ Motivo da falha
- ✅ IP e User-Agent
- ✅ Controle de tentativas por usuário

## 🔄 COMPATIBILIDADE

### API Mantida
- ✅ Mesmas rotas e parâmetros
- ✅ Mesma estrutura de resposta
- ✅ Códigos de erro consistentes
- ✅ Mensagens de erro padronizadas

### Interceptors
- ✅ Verificação automática de autenticação
- ✅ Redirecionamento para login se não autenticado
- ✅ Tratamento de erros globais

### LocalStorage
- ✅ Token de autenticação
- ✅ Dados do usuário
- ✅ Limpeza automática em logout/erro

## 📊 ESTATÍSTICAS E RELATÓRIOS

### Pedidos
- ✅ Total de pedidos
- ✅ Pedidos pendentes
- ✅ Pedidos entregues
- ✅ Faturamento total

### Estoque
- ✅ Produtos com estoque
- ✅ Produtos sem estoque
- ✅ Produtos com estoque baixo
- ✅ Relatório completo de estoque

### Clientes
- ✅ Total de clientes ativos
- ✅ Clientes com pedidos
- ✅ Novos clientes no mês
- ✅ Top clientes por valor

### Usuários
- ✅ Total de usuários
- ✅ Usuários ativos/inativos
- ✅ Distribuição por perfil
- ✅ Últimos acessos

## ✅ RESUMO

**TODAS as regras de negócio do servidor original foram implementadas:**

1. **100% das validações** mantidas
2. **100% da lógica de estoque** preservada
3. **100% da segurança** implementada
4. **100% da auditoria** mantida
5. **100% das regras especiais** (como nhoques) preservadas
6. **100% da compatibilidade** com frontend existente

A migração preserva integralmente o comportamento do sistema original, mantendo todas as regras de negócio, validações, e funcionalidades especiais. 