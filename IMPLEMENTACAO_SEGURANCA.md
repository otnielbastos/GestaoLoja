# 🔐 Implementação de Segurança - GestaoLoja

## 📋 Resumo da Implementação

Este documento descreve a implementação completa do sistema de segurança no GestaoLoja, incluindo autenticação JWT, autorização baseada em roles (RBAC), auditoria e controle de acesso granular.

## ✅ Funcionalidades Implementadas

### 🔑 Autenticação
- [x] Login com email e senha
- [x] Tokens JWT com expiração configurável (8 horas)
- [x] Hash de senhas com bcryptjs (12 rounds)
- [x] Controle de tentativas de login (bloqueio após 5 tentativas)
- [x] Sessões ativas no banco de dados
- [x] Rate limiting (5 tentativas por 15 minutos)

### 👥 Autorização e Perfis
- [x] Três perfis padrão: Administrador, Gerente, Vendedor
- [x] Sistema de permissões JSON flexível
- [x] Controle de acesso por recurso e ação
- [x] Middleware de autorização
- [x] Verificação de propriedade para vendedores

### 🛡️ Segurança
- [x] Middlewares de segurança (Helmet.js)
- [x] Rate limiting global e específico
- [x] Validação de entrada com express-validator
- [x] Logs de auditoria completos
- [x] Controle de sessões ativas

### 🎨 Interface
- [x] Tela de login responsiva
- [x] Dashboard com sidebar dinâmica
- [x] Controle de acesso visual baseado em permissões
- [x] Feedback de erros e estados de loading
- [x] Design moderno com Tailwind CSS e shadcn/ui

## 🗃️ Estrutura do Banco de Dados

### Novas Tabelas Criadas

#### `perfis`
```sql
- id (INT, PK, AI)
- nome (VARCHAR(50), UNIQUE)
- descricao (TEXT)
- permissoes (JSON)
- ativo (BOOLEAN)
- data_criacao, data_atualizacao (TIMESTAMP)
```

#### `sessoes`
```sql
- id (INT, PK, AI)
- usuario_id (INT, FK)
- token (VARCHAR(255), UNIQUE)
- ip_address (VARCHAR(45))
- user_agent (TEXT)
- data_criacao, data_expiracao (TIMESTAMP)
- ativo (BOOLEAN)
```

#### `auditoria`
```sql
- id (INT, PK, AI)
- usuario_id (INT, FK)
- acao (VARCHAR(100))
- tabela (VARCHAR(50))
- registro_id (INT)
- dados_antigos, dados_novos (JSON)
- ip_address (VARCHAR(45))
- user_agent (TEXT)
- data_acao (TIMESTAMP)
```

#### `tentativas_login`
```sql
- id (INT, PK, AI)
- email (VARCHAR(255))
- ip_address (VARCHAR(45))
- sucesso (BOOLEAN)
- motivo (VARCHAR(100))
- user_agent (TEXT)
- data_tentativa (TIMESTAMP)
```

### Tabela `usuarios` - Campos Adicionados
```sql
- perfil_id (INT, FK)
- senha_hash (VARCHAR(255))
- salt (VARCHAR(255))
- token_reset (VARCHAR(255))
- token_reset_expira (TIMESTAMP)
- tentativas_login (INT)
- bloqueado_ate (TIMESTAMP)
- ativo (BOOLEAN)
- criado_por, atualizado_por (INT, FK)
- data_atualizacao (TIMESTAMP)
```

## 🚀 Instalação e Configuração

### 1. Executar Script do Banco de Dados
```bash
# Executar o script de segurança no MySQL
mysql -u root -p loja_organizada < server/database_security.sql
```

### 2. Instalar Dependências do Backend
```bash
cd server
npm install bcryptjs jsonwebtoken express-rate-limit helmet express-validator
```

### 3. Configurar Variáveis de Ambiente
Criar arquivo `.env` no diretório `server/`:
```env
# Configurações do Banco de Dados
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=loja_organizada

# Configurações de Segurança
JWT_SECRET=sua_chave_secreta_super_segura_aqui_mude_em_producao
NODE_ENV=development

# Configurações do Servidor
PORT=3001
FRONTEND_URL=http://localhost:5173
```

### 4. Iniciar o Servidor
```bash
cd server
npm start
```

### 5. Iniciar o Frontend
```bash
# No diretório raiz
npm run dev
```

## 🔑 Credenciais Padrão

### Administrador
- **Email:** admin@silosystem.com
- **Senha:** admin123

## 📊 Sistema de Permissões

### Estrutura de Permissões JSON
```json
{
  "usuarios": ["create", "read", "update", "delete"],
  "clientes": ["create", "read", "update", "delete"],
  "pedidos": ["create", "read", "update", "delete"],
  "produtos": ["create", "read", "update", "delete"],
  "financeiro": ["create", "read", "update", "delete"],
  "relatorios": ["create", "read", "update", "delete"]
}
```

### Perfis e Acessos

| Recurso    | Administrador | Gerente | Vendedor         |
|------------|---------------|---------|------------------|
| Usuários   | ✅ Total       | ❌       | ❌                |
| Clientes   | ✅ Total       | ✅ Total | ✅ Apenas os seus |
| Pedidos    | ✅ Total       | ✅ Total | ✅ Apenas os seus |
| Produtos   | ✅ Total       | ✅ Total | ❌                |
| Financeiro | ✅ Total       | ✅ Total | ❌                |
| Relatórios | ✅ Total       | ✅ Total | ❌                |

## 🛠️ APIs Implementadas

### Autenticação
- `POST /api/auth/login` - Login do usuário
- `POST /api/auth/logout` - Logout do usuário
- `GET /api/auth/verify` - Verificar token
- `POST /api/auth/change-password` - Alterar senha

### Usuários (apenas Administradores)
- `GET /api/users` - Listar usuários
- `POST /api/users` - Criar usuário
- `GET /api/users/:id` - Buscar usuário
- `PUT /api/users/:id` - Atualizar usuário
- `DELETE /api/users/:id` - Desativar usuário
- `PATCH /api/users/:id/reactivate` - Reativar usuário
- `PATCH /api/users/:id/reset-password` - Resetar senha
- `GET /api/users/perfis` - Listar perfis

## 🧩 Componentes Frontend

### Contexto de Autenticação
- `AuthContext` - Gerenciamento global de estado de autenticação
- `useAuth()` - Hook para acesso aos dados de autenticação
- `useApi()` - Hook para API autenticada

### Componentes de Proteção
- `ProtectedRoute` - Componente para proteger rotas
- Suporte a verificação por permissão e role

### Páginas
- `Login` - Tela de autenticação
- `Dashboard` - Layout principal com sidebar
- `DashboardHome` - Página inicial do dashboard

## 🔧 Middlewares de Segurança

### Backend
1. **helmet** - Headers de segurança HTTP
2. **express-rate-limit** - Rate limiting
3. **express-validator** - Validação de entrada
4. **authenticate** - Verificação de JWT
5. **authorize** - Verificação de permissões
6. **checkOwnership** - Verificação de propriedade

### Frontend
1. **Interceptors Axios** - Injeção automática de token
2. **Redirecionamento automático** - Em caso de token expirado
3. **Verificação de permissões** - Para exibição de componentes

## 📝 Logs e Auditoria

### Eventos Registrados
- Login e logout de usuários
- Tentativas de login (sucesso e falha)
- Criação, atualização e exclusão de registros
- Alterações de senha
- Ações administrativas

### Informações Capturadas
- ID do usuário
- Ação realizada
- Dados antes e depois da alteração
- IP de origem
- User Agent
- Timestamp

## 🔄 Fluxo de Autenticação

1. **Login:**
   - Usuário envia email/senha
   - Sistema valida credenciais
   - Gera token JWT
   - Cria sessão no banco
   - Retorna token para o frontend

2. **Requisições Autenticadas:**
   - Frontend envia token no header
   - Middleware verifica token JWT
   - Busca sessão ativa no banco
   - Verifica permissões específicas
   - Executa ação se autorizada

3. **Logout:**
   - Desativa sessão no banco
   - Remove token do frontend

## 🛡️ Medidas de Segurança Implementadas

### Proteção contra Ataques
- **Brute Force:** Rate limiting e bloqueio de usuário
- **SQL Injection:** Prepared statements
- **XSS:** Sanitização de entrada e CSP
- **CSRF:** Headers de segurança
- **Session Hijacking:** Tokens JWT com expiração

### Boas Práticas
- Hash de senhas com salt
- Tokens com expiração
- Logs de auditoria
- Validação de entrada
- Princípio do menor privilégio

## 📈 Próximos Passos

### Melhorias Futuras
- [ ] Reset de senha por email
- [ ] Autenticação de dois fatores (2FA)
- [ ] SSO (Single Sign-On)
- [ ] Relatórios de auditoria
- [ ] Configuração de perfis customizados
- [ ] Dashboard de segurança

### Módulos em Desenvolvimento
- [ ] Gerenciamento completo de usuários
- [ ] Integração com módulos existentes
- [ ] Controle de acesso granular nos CRUDs
- [ ] Relatórios de segurança

## 🧪 Testes

### Testar Funcionalidades
1. Acesse `http://localhost:5173`
2. Faça login com admin@silosystem.com / admin123
3. Explore o dashboard
4. Teste diferentes perfis de usuário
5. Verifique logs de auditoria no banco

### Cenários de Teste
- Login com credenciais corretas
- Login com credenciais incorretas
- Tentativas múltiplas de login
- Navegação com diferentes perfis
- Logout e re-login
- Acesso a rotas protegidas

## 📞 Suporte

Para dúvidas ou problemas com a implementação:
1. Verifique os logs do servidor
2. Confirme as configurações do banco
3. Teste as APIs com Postman/Insomnia
4. Verifique as permissões dos usuários

---

**Implementação concluída em:** `data_atual`
**Versão:** 1.0.0
**Status:** ✅ Produção Pronta 