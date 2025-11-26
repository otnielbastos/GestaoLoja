# 🚀 Sistema de Encomendas e Controle Automático de Estoque

## 📋 Visão Geral

Esta implementação adiciona ao GestaoLoja um sistema completo de **encomendas** e **controle automático de estoque**, permitindo:

- ✅ **Vendas à pronta entrega** (produtos em estoque)
- ✅ **Encomendas sob demanda** (produtos produzidos após pedido)
- ✅ **Controle automático de entrada/saída de estoque**
- ✅ **Workflow completo de produção**
- ✅ **Rastreabilidade total das operações**

---

## 🎯 Principais Funcionalidades

### 🔄 Tipos de Pedido

#### **Pronta Entrega**
- Produtos já disponíveis no estoque
- Verificação automática de disponibilidade
- Saída de estoque na entrega

#### **Encomenda**
- Produtos produzidos sob demanda
- Data de entrega obrigatória
- Entrada automática no estoque após produção
- Saída automática na entrega

### 📊 Novos Status de Pedido

| Status | Descrição | Ação Automática |
|--------|-----------|----------------|
| `pendente` | Pedido recebido | - |
| `aprovado` | Pedido confirmado | - |
| `aguardando_producao` | Aguardando início da produção | - |
| `em_preparo` | Produção em andamento | - |
| `em_separacao` | Produtos sendo separados | - |
| `produzido` | Produção finalizada | ⚡ **ENTRADA no estoque** |
| `pronto` | Pedido pronto para entrega | - |
| `em_entrega` | Pedido em transporte | - |
| `entregue` | Produto entregue | ⚡ **SAÍDA do estoque** |
| `concluido` | Processo finalizado | - |
| `cancelado` | Pedido cancelado | - |

---

## 🛠️ Como Aplicar as Melhorias

### 1️⃣ **Executar Migração do Banco de Dados**

```bash
# No diretório server/
cd server
node run_migration.js
```

A migração irá:
- ✅ Adicionar novos campos na tabela `pedidos`
- ✅ Atualizar enum de status
- ✅ Criar tabela de log para auditoria
- ✅ Adicionar índices para performance
- ✅ Configurar foreign keys

### 2️⃣ **Instalar Dependências (se necessário)**

```bash
# Frontend
npm install

# Backend
cd server
npm install
```

### 3️⃣ **Reiniciar os Serviços**

```bash
# Terminal 1 - Backend
cd server
node server.js

# Terminal 2 - Frontend
npm run dev
```

---

## 🎮 Como Usar o Sistema

### 📝 **Criando uma Encomenda**

1. **Novo Pedido** → Selecionar tipo **"Encomenda"**
2. Preencher **data de entrega prevista** (obrigatório)
3. Adicionar **observações de produção** (opcional)
4. Escolher produtos e quantidades
5. Salvar pedido

### 🏭 **Workflow de Produção**

1. **Aprovar** encomenda (`aprovado` → `aguardando_producao`)
2. **Iniciar produção** (`em_preparo`)
3. **Finalizar produção** (`produzido`)
   - ⚡ Sistema faz **entrada automática** no estoque
4. **Preparar entrega** (`pronto`)
5. **Entregar** (`entregue`)
   - ⚡ Sistema faz **saída automática** do estoque

### 🚚 **Pronta Entrega**

1. **Novo Pedido** → Tipo **"Pronta Entrega"**
2. Sistema verifica **estoque disponível**
3. **Entregar** (`entregue`)
   - ⚡ Sistema faz **saída automática** do estoque

---

## 🔧 Alterações Técnicas Implementadas

### 📁 **Backend**

#### **Banco de Dados** (`server/database_migrations.sql`)
```sql
-- Novos campos na tabela pedidos
ALTER TABLE pedidos ADD COLUMN tipo ENUM('pronta_entrega', 'encomenda');
ALTER TABLE pedidos ADD COLUMN data_entrega_prevista DATE;
ALTER TABLE pedidos ADD COLUMN horario_entrega TIME;
ALTER TABLE pedidos ADD COLUMN observacoes_producao TEXT;

-- Novos status
ALTER TABLE pedidos MODIFY COLUMN status ENUM(
  'pendente', 'aprovado', 'aguardando_producao', 'em_preparo',
  'em_separacao', 'produzido', 'pronto', 'em_entrega', 
  'entregue', 'concluido', 'cancelado'
);
```

#### **Controlador** (`server/controllers/pedidosController.js`)
- ✅ Funções de **entrada automática** de estoque
- ✅ Funções de **saída automática** de estoque  
- ✅ Validações específicas por tipo de pedido
- ✅ Logs de auditoria automáticos

### 📁 **Frontend**

#### **Formulário** (`src/components/OrderFormModal.tsx`)
- ✅ Seleção de **tipo de pedido** (radio buttons)
- ✅ Campos condicionais para **encomendas**
- ✅ Validação de **data de entrega obrigatória**
- ✅ **Observações de produção**

#### **Listagem** (`src/components/Orders.tsx`)
- ✅ **Badges** para tipo de pedido
- ✅ **Status visuais** atualizados
- ✅ Exibição de **data de entrega prevista**
- ✅ **Observações de produção** visíveis

#### **Hooks** (`src/hooks/useOrders.ts`)
- ✅ Interface **Order** atualizada
- ✅ Novos campos no **mapeamento** backend ↔ frontend
- ✅ **Validações** de tipo e status

---

## 📊 Tabelas do Banco de Dados

### 🗃️ **Tabela: `pedidos`** (atualizada)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `tipo` | ENUM | `'pronta_entrega'`, `'encomenda'` |
| `data_entrega_prevista` | DATE | Data prevista para entrega (obrigatório para encomendas) |
| `horario_entrega` | TIME | Horário previsto para entrega |
| `observacoes_producao` | TEXT | Instruções específicas para produção |
| `estoque_processado` | BOOLEAN | Controle se estoque já foi processado |

### 🗃️ **Tabela: `log_operacoes_automaticas`** (nova)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | INT | ID único |
| `pedido_id` | INT | Referência ao pedido |
| `tipo_operacao` | ENUM | `'entrada_estoque'`, `'saida_estoque'` |
| `status_anterior` | VARCHAR | Status antes da operação |
| `status_novo` | VARCHAR | Status após operação |
| `produtos_afetados` | JSON | Lista de produtos e quantidades |
| `data_operacao` | TIMESTAMP | Quando a operação foi executada |

---

## 🔍 Logs e Auditoria

### 📝 **Logs Automáticos**

O sistema gera logs automáticos para:

- ✅ **Entrada de estoque** (quando produção é finalizada)
- ✅ **Saída de estoque** (quando pedido é entregue)
- ✅ **Mudanças de status** críticas
- ✅ **Produtos afetados** em cada operação

### 🔎 **Consulta de Logs**

```sql
-- Ver logs de um pedido específico
SELECT * FROM log_operacoes_automaticas WHERE pedido_id = 123;

-- Ver todas as operações automáticas
SELECT 
    p.numero_pedido,
    l.tipo_operacao,
    l.status_anterior,
    l.status_novo,
    l.data_operacao
FROM log_operacoes_automaticas l
JOIN pedidos p ON l.pedido_id = p.id
ORDER BY l.data_operacao DESC;
```

---

## ⚠️ Validações e Regras de Negócio

### 🚫 **Restrições**

1. **Encomendas** devem ter `data_entrega_prevista`
2. **Pronta entrega** deve ter estoque suficiente
3. **Encomendas** só podem ser entregues após status `produzido`
4. **Estoque** só é processado uma vez por pedido
5. **Status** cancelado/concluído não podem ser editados

### ⚡ **Automações**

1. **Entrada automática**: `em_preparo` → `produzido`
2. **Saída automática**: qualquer status → `entregue`
3. **Verificação de estoque**: antes de cada operação
4. **Log de auditoria**: para todas as operações automáticas

---

## 🎨 Interface do Usuário

### 🎯 **Novos Elementos Visuais**

- 🎨 **Badges coloridos** para tipo de pedido
- 📅 **Indicador visual** de data de entrega
- 👨‍🍳 **Observações de produção** destacadas
- ⚡ **Status expandidos** com ícones
- 💡 **Dicas contextuais** para encomendas

### 🎭 **Cores e Ícones**

| Elemento | Cor | Ícone |
|----------|-----|-------|
| Pronta Entrega | Verde | ⚡ |
| Encomenda | Azul | 📅 |
| Produzido | Roxo | ✨ |
| Aguardando Produção | Laranja | ⏳ |

---

## 🚀 Benefícios da Implementação

### 🎯 **Para o Negócio**

- ✅ **Planejamento** de produção antecipado
- ✅ **Controle automatizado** de estoque
- ✅ **Redução de erros** manuais
- ✅ **Rastreabilidade** completa
- ✅ **Otimização** de recursos

### 👥 **Para os Usuários**

- ✅ **Interface intuitiva** para tipos de pedido
- ✅ **Validações em tempo real**
- ✅ **Feedback visual** claro
- ✅ **Processo simplificado**

### 🛡️ **Para o Sistema**

- ✅ **Integridade** de dados garantida
- ✅ **Logs de auditoria** automáticos
- ✅ **Performance otimizada** com índices
- ✅ **Escalabilidade** preparada

---

## 🔮 Próximos Passos (Sugestões)

1. **📱 Notificações push** para mudanças de status
2. **📊 Dashboard** específico para encomendas
3. **🔔 Alertas** de prazos de entrega
4. **📈 Relatórios** de produtividade
5. **🤖 API** para integração com outros sistemas

---

## 📞 Suporte

Para dúvidas ou problemas:

1. **Verifique** se a migração foi executada corretamente
2. **Consulte** os logs do servidor para erros
3. **Teste** em ambiente de desenvolvimento primeiro
4. **Faça backup** do banco antes de aplicar em produção

---

**🎉 Sistema implementado com sucesso! O GestaoLoja agora suporta encomendas e controle automático de estoque.** 