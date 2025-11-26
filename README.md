# GestaoLoja - Sistema de Gestão de Loja

Sistema de gestão completo para lojas, com controle de produtos, estoque, vendas e muito mais.

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

É necessário manter dois terminais abertos, um para o frontend e outro para o backend:

### Terminal 1 - Frontend
```sh
# Na pasta raiz do projeto
npm run dev
```
Isso iniciará o servidor de desenvolvimento do frontend na porta 8080.

### Terminal 2 - Backend
```sh
# Na pasta server
cd server
node server.js
```
Isso iniciará o servidor backend na porta 3001.

## Estrutura do Projeto

- `src/` - Código fonte do frontend (React)
- `server/` - Código fonte do backend (Node.js/Express)
  - `config/` - Configurações do banco de dados
  - `controllers/` - Controladores da API
  - `routes/` - Rotas da API

## Tecnologias Utilizadas

Frontend:
- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS

Backend:
- Node.js
- Express
- MySQL
- CORS

## Importante!

Para o funcionamento correto do sistema, certifique-se de que:

1. O MySQL está rodando no XAMPP
2. O servidor backend está rodando (`node server.js`)
3. O servidor frontend está rodando (`npm run dev`)
4. O banco de dados foi criado e as tabelas foram importadas

Se encontrar o erro "Network Error", verifique se todos os serviços acima estão funcionando corretamente.

## Como Contribuir

1. Crie um branch para sua feature
2. Faça commit das suas alterações
3. Faça push para o branch
4. Crie um Pull Request

## Licença

Este projeto está sob a licença MIT.
