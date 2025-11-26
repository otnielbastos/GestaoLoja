# Sistema de Permissões - GestaoLoja

## 📋 Visão Geral

O sistema de permissões foi implementado para controlar o acesso às páginas e funcionalidades do sistema baseado no perfil do usuário. Agora o sistema respeita as permissões definidas para cada perfil, mostrando apenas os menus e funcionalidades que o usuário tem acesso.

## 🔧 Como Funciona

### 1. **Estrutura de Permissões**

Cada perfil possui:
- **Páginas**: Lista de páginas que o usuário pode acessar
- **Ações**: Para cada página, lista de ações permitidas (visualizar, criar, editar, excluir, etc.)

### 2. **Perfis Padrão**

O sistema inclui 4 perfis pré-configurados:

#### 🔴 **Administrador**
- **Acesso**: Todas as páginas e funcionalidades
- **Páginas**: Dashboard, Produtos, Pedidos, Clientes, Estoque, Entregas, Relatórios, Usuários, Configurações
- **Permissões**: Acesso total (criar, editar, excluir, aprovar, etc.)

#### 🔵 **Gerente** 
- **Acesso**: Operações e relatórios (sem usuários e configurações)
- **Páginas**: Dashboard, Produtos, Pedidos, Clientes, Estoque, Entregas, Relatórios
- **Permissões**: Pode criar, editar, aprovar, cancelar e exportar

#### 🟢 **Vendedor**
- **Acesso**: Apenas vendas e clientes
- **Páginas**: Dashboard, Pedidos, Clientes
- **Permissões**: Pode visualizar, criar, editar e exportar

#### 🟡 **Operacional**
- **Acesso**: Estoque e entregas
- **Páginas**: Dashboard, Produtos (só visualizar), Estoque, Entregas
- **Permissões**: Pode visualizar e editar estoque/entregas

## 🚀 Implementação

### 1. **Configurar Banco de Dados**

Execute o script SQL para criar os perfis padrão:

```bash
# Execute no Supabase SQL Editor
cat supabase_insert_default_profiles.sql
```

### 2. **Atribuir Perfis aos Usuários**

1. Acesse **Usuários** no sistema
2. Clique em **Gerenciar Permissões**
3. Os perfis padrão estarão disponíveis
4. Edite usuários e atribua o perfil adequado

### 3. **Como o Sistema Funciona**

#### **Menu Lateral**
- Mostra apenas páginas que o usuário tem acesso
- Dashboard sempre visível
- Loading skeleton enquanto carrega permissões

#### **Componentes Protegidos**
- Páginas verificam permissões antes de renderizar
- Botões de ação (criar, editar, excluir) aparecem conforme permissões
- Mensagens de "Acesso Negado" quando necessário

#### **Hooks Disponíveis**

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

## 📱 Exemplos de Uso

### **Vendedor**
- Vê apenas: Dashboard, Pedidos, Clientes
- Pode: Criar pedidos, editar clientes, exportar dados
- Não pode: Acessar produtos, usuários, configurações

### **Operacional**
- Vê apenas: Dashboard, Produtos (visualizar), Estoque, Entregas
- Pode: Atualizar estoque, gerenciar entregas
- Não pode: Criar produtos, acessar relatórios

### **Gerente**
- Vê: Todas as páginas exceto Usuários e Configurações
- Pode: Aprovar pedidos, gerenciar operações, ver relatórios
- Não pode: Gerenciar usuários do sistema

## 🔒 Segurança

### **Frontend**
- Menus ocultos baseado em permissões
- Componentes protegidos com verificação
- Botões de ação condicionais

### **Backend** (Recomendado)
- Validar permissões no servidor
- Verificar acesso em cada endpoint
- Logs de auditoria para ações sensíveis

## 🛠️ Personalização

### **Criar Novo Perfil**
1. Acesse **Usuários** → **Gerenciar Permissões**
2. Clique **Novo Perfil**
3. Configure páginas e ações permitidas
4. Salve e atribua aos usuários

### **Modificar Perfil Existente**
1. Na lista de perfis, clique **Editar**
2. Ajuste permissões conforme necessário
3. Salve as alterações

### **Adicionar Nova Página**
1. Adicione a página em `PagePermission` (types/permissions.ts)
2. Configure ações padrão em `DEFAULT_PAGE_ACTIONS`
3. Adicione label em `PAGE_LABELS`
4. Atualize menu em `AppSidebar.tsx`
5. Proteja o componente com `ProtectedComponent`

## 📊 Monitoramento

### **Verificar Permissões**
- Console do navegador mostra logs de carregamento
- Erros de permissão são logados
- Sistema gracioso com fallbacks

### **Auditoria**
- Todas as ações são registradas na tabela `auditoria`
- Logs incluem usuário, ação, IP e timestamp
- Histórico completo de mudanças

## 🎯 Benefícios

✅ **Segurança**: Controle granular de acesso  
✅ **Flexibilidade**: Perfis customizáveis  
✅ **Usabilidade**: Interface limpa e intuitiva  
✅ **Escalabilidade**: Fácil adição de novas permissões  
✅ **Auditoria**: Rastreamento completo de ações  

## 🔄 Próximos Passos

1. **Implementar validação no backend**
2. **Adicionar mais tipos de ação** (aprovar, cancelar, etc.)
3. **Criar relatórios de uso por perfil**
4. **Implementar permissões temporárias**
5. **Adicionar notificações de mudanças de permissão**

---

**Nota**: Este sistema garante que cada usuário veja apenas o que tem permissão para acessar, melhorando a segurança e experiência do usuário. 