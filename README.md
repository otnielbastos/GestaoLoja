# GestaoLoja - Sistema de Gestão de Loja

Sistema de gestão completo para lojas, com controle de produtos, estoque, vendas e muito mais.

## 📚 Documentação Completa

Para uma análise detalhada de todas as telas, funcionalidades e regras de negócio, consulte:
- **[Análise Completa do Projeto](./docs/ANALISE_COMPLETA_PROJETO.md)** - Documento completo com descrição de todas as telas e regras

## 🎯 Funcionalidades Principais

- ✅ **Gestão de Produtos**: Cadastro completo com imagens, tipos, categorias e controle de estoque separado
- ✅ **Gestão de Pedidos**: Dois tipos (Pronta Entrega/Encomenda) com fluxo completo de status
- ✅ **Gestão de Clientes**: Base completa com histórico de compras e estatísticas
- ✅ **Controle de Estoque**: Movimentações manuais e automáticas com rastreabilidade
- ✅ **Gestão de Entregas**: Controle de rotas e status de entrega
- ✅ **Relatórios Analíticos**: Dashboards com gráficos, KPIs e exportação
- ✅ **Gestão de Usuários**: Sistema completo com perfis e permissões granulares
- ✅ **Segurança**: Autenticação robusta, auditoria completa e controle de acesso

## Requisitos

- Node.js & npm - [instale com nvm](https://github.com/nvm-sh/nvm#installing-and-updating)
- Supabase (local ou cloud)
- Git

## Configuração Inicial

1. Clone o repositório:
```sh
git clone <YOUR_GIT_URL>
cd GestaoLoja
```

2. Configure as variáveis de ambiente:
Crie um arquivo `.env.local` na raiz do projeto com:
```env
# Para desenvolvimento local com Supabase local
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

# Para produção, substitua pelos valores do seu projeto Supabase
# VITE_SUPABASE_URL=https://your-project.supabase.co
# VITE_SUPABASE_ANON_KEY=your_anon_key
```

3. Configure o Supabase:
```sh
# Instalar Supabase CLI (se não tiver)
npm install -g supabase

# Iniciar Supabase local
npx supabase start

# Executar migrations e seed
npx supabase db reset
```

4. Instale as dependências:
```sh
npm install
```

## Como Executar o Projeto

### Terminal 1 - Supabase (se usando local)
```sh
# Iniciar Supabase local
npx supabase start
```

### Terminal 2 - Frontend
```sh
# Na pasta raiz do projeto
npm run dev
```
Isso iniciará o servidor de desenvolvimento do frontend (geralmente na porta 5173 ou 8080).

## Estrutura do Projeto

- `src/` - Código fonte do frontend (React + TypeScript)
  - `components/` - Componentes React
  - `pages/` - Páginas do sistema
  - `services/` - Serviços de integração com Supabase
  - `hooks/` - Custom hooks
  - `contexts/` - Contextos React (Auth, Navigation)
  - `types/` - Definições TypeScript
- `docs/` - Documentação do projeto
  - `ANALISE_COMPLETA_PROJETO.md` - Análise detalhada de todas as telas e regras
  - `regras/` - Documentação de regras de negócio
  - `implementacao/` - Guias de implementação
- `BancoDados/` - Scripts SQL e migrações
- `supabase/` - Configurações do Supabase

## Tecnologias Utilizadas

### Frontend
- **React** 18.3.1 com TypeScript
- **Vite** 5.4.1 (build tool)
- **React Router DOM** 6.26.2 (roteamento)
- **shadcn-ui** (componentes UI baseados em Radix UI)
- **Tailwind CSS** 3.4.11 (estilização)
- **React Query** 5.80.2 (gerenciamento de estado)
- **React Hook Form** + **Zod** (formulários e validação)
- **Recharts** 2.12.7 (gráficos)
- **Sonner** 1.5.0 (notificações)

### Backend
- **Supabase** (PostgreSQL como banco de dados)
- **Supabase Auth** (autenticação)
- **Supabase Storage** (armazenamento de imagens)
- **Supabase REST API** + **RPC Functions** (API)

## Importante!

Para o funcionamento correto do sistema, certifique-se de que:

1. O Supabase está configurado (local ou cloud)
2. As variáveis de ambiente estão configuradas (`.env.local`)
3. As migrations foram executadas (`npx supabase db reset`)
4. O servidor frontend está rodando (`npm run dev`)

Se encontrar erros, verifique:
- Configuração das variáveis de ambiente
- Conexão com o Supabase
- Execução das migrations
- Console do navegador para erros específicos

## Como Contribuir

1. Crie um branch para sua feature
2. Faça commit das suas alterações
3. Faça push para o branch
4. Crie um Pull Request

## Licença

Este projeto está sob a licença MIT.
