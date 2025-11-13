# Deploy na Vercel - Guia Completo

## 📋 Visão Geral

Este projeto contém **duas aplicações** que serão deployadas juntas:

- **Site Institucional** (`/`) - Site público voltado para clientes
- **Sistema de Gestão** (`/admin`) - Sistema administrativo com Supabase

Ambas são servidas a partir do mesmo domínio na Vercel.

## 🔗 URLs de Produção

- `https://silosaboresgourmet.com.br` → Site Institucional
- `https://silosaboresgourmet.com.br/admin` → Sistema de Gestão

## Pré-requisitos

1. Conta na Vercel (https://vercel.com)
2. Projeto configurado no GitHub, GitLab ou Bitbucket
3. Projeto Supabase configurado (https://supabase.com)
4. Node.js 18+ instalado

## Passos para Deploy

### 1. Preparação do Projeto

O projeto já está configurado com:
- ✅ `vercel.json` - Configuração para deployment com rewrites
- ✅ Script `vercel-build` no package.json que executa `build-all.js`
- ✅ Estrutura unificada: Site na raiz + Admin em /admin
- ✅ Build automatizado que compila ambos os projetos

### 2. Instalação de Dependências

Certifique-se de instalar as dependências de ambos os projetos:

```bash
# Dependências do projeto raiz
npm install

# Dependências do Site
cd Site
npm install
cd ..
```

### 3. Configuração das Variáveis de Ambiente

Na Vercel Dashboard, configure as seguintes variáveis:

#### Configurações do Supabase (para Sistema de Gestão)
```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

**Como obter essas informações:**
1. Vá para o dashboard do Supabase (https://supabase.com/dashboard)
2. Selecione seu projeto
3. Vá em Settings → API
4. Copie a `URL` e a `anon key`

### 4. Deploy na Vercel

#### 4.1. Conecte seu Repositório

1. Vá para https://vercel.com/dashboard
2. Clique em "New Project"
3. Importe seu repositório do GitHub/GitLab/Bitbucket

#### 4.2. Configure o Projeto

**Importante:** Use estas configurações exatas:

- **Framework Preset:** Vite
- **Root Directory:** `.` (raiz do projeto)
- **Build Command:** `npm run build` (executará o script build-all.js)
- **Output Directory:** `dist`
- **Install Command:** `npm install && cd Site && npm install && cd ..`

#### 4.3. Adicione as Variáveis de Ambiente

Configure as variáveis do Supabase conforme listado acima.

#### 4.4. Deploy

1. Clique em "Deploy"
2. Aguarde o processo de build (leva alguns minutos)
3. Verifique o log de build para confirmar que ambos os projetos foram compilados

**O que acontece no build:**
```
🔐 BUILD: Sistema de Gestão (Admin)
📱 BUILD: Site Institucional
📦 Organizando Admin em dist/admin/
✅ Build concluído!
```

### 5. Verificação Pós-Deploy

Após o deploy bem-sucedido, teste as seguintes URLs:

#### Site Institucional (`/`)
- ✅ `https://silosaboresgourmet.com.br` carrega corretamente
- ✅ Menu e navegação funcionam
- ✅ Formulário de pedidos funciona
- ✅ Internacionalização (PT/EN) funciona
- ✅ Design responsivo em mobile

#### Sistema de Gestão (`/admin`)
- ✅ `https://silosaboresgourmet.com.br/admin` carrega o login
- ✅ Autenticação do Supabase funciona
- ✅ Dashboard carrega após login
- ✅ CRUD de Pedidos/Clientes/Produtos funciona
- ✅ Relatórios são gerados corretamente
- ✅ Permissões por perfil funcionam

### 6. Configuração Adicional

#### Banco de Dados Supabase
- Configure as tabelas usando `supabase_schema.sql`
- Execute as migrations de segurança
- Configure os perfis e permissões

#### Domínio Customizado
1. Na Vercel Dashboard, vá em Settings → Domains
2. Adicione `silosaboresgourmet.com.br`
3. Configure os registros DNS conforme instruções

## Arquitetura de Deploy

```
┌─────────────────────────────────────────────────┐
│           Vercel Edge Network                   │
│  https://silosaboresgourmet.com.br             │
└─────────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
   ┌────▼─────┐          ┌─────▼────────┐
   │   Site   │          │    Admin     │
   │    (/)   │          │   (/admin)   │
   └──────────┘          └──────┬───────┘
                                │
                         ┌──────▼───────┐
                         │   Supabase   │
                         │ PostgreSQL + │
                         │ Auth + APIs  │
                         └──────────────┘
```

### Estrutura de Arquivos no Deploy

```
dist/
├── index.html              ← Site Institucional (raiz)
├── assets/
│   ├── index-xxx.js       ← JS do Site
│   └── index-xxx.css      ← CSS do Site
├── robots.txt
├── sitemap.xml
└── admin/                  ← Sistema de Gestão
    ├── index.html         ← Login/Dashboard
    ├── assets/
    │   ├── index-yyy.js  ← JS do Admin
    │   └── index-yyy.css ← CSS do Admin
    └── ...
```

## Comandos Úteis

### Desenvolvimento Local

```bash
# Executar Site Institucional (porta 8080)
npm run dev
# ou
npm run dev:site

# Executar Sistema de Gestão (porta 8081)
npm run dev:admin

# Executar ambos (em terminais separados)
# Terminal 1:
npm run dev:site
# Terminal 2:
npm run dev:admin
```

### Build e Testes

```bash
# Build completo (ambos os projetos)
npm run build

# Build apenas do Admin
npm run build:admin

# Build apenas do Site
npm run build:site

# Testar build localmente
npm run preview        # Preview do Site
npm run preview:admin  # Preview do Admin
```

### Verificação Antes do Deploy

```bash
# 1. Limpar node_modules e reinstalar
rm -rf node_modules Site/node_modules
npm install
cd Site && npm install && cd ..

# 2. Testar build localmente
npm run build

# 3. Verificar estrutura do dist
ls -la dist/
ls -la dist/admin/
```

## Problemas Comuns e Soluções

### 1. Build Falha na Vercel

**Sintoma:** Build interrompido com erro

**Soluções:**
- Verifique se o Install Command está correto: `npm install && cd Site && npm install && cd ..`
- Certifique-se que `build-all.js` tem permissões corretas
- Execute `npm run build` localmente para reproduzir o erro

### 2. Admin não carrega (/admin retorna 404)

**Sintoma:** Site funciona mas `/admin` dá erro 404

**Soluções:**
- Verifique se `dist/admin/index.html` existe após o build
- Confirme que `vercel.json` tem os rewrites corretos
- Veja os logs da Vercel para verificar se o build incluiu a pasta admin

### 3. Assets não carregam no Admin

**Sintoma:** Página admin carrega mas sem CSS/JS

**Soluções:**
- Confirme que `base: "/admin"` está configurado em `vite.config.ts` (raiz)
- Verifique se os caminhos dos assets no HTML estão com `/admin/assets/...`
- Limpe o cache do browser e da Vercel

### 4. Erro de Conexão Supabase

**Sintoma:** "Failed to fetch" ou "Network error"

**Soluções:**
- Verifique as variáveis de ambiente na Vercel:
  - `VITE_SUPABASE_URL`
  - `VITE_SUPABASE_ANON_KEY`
- Configure URLs permitidas no Supabase:
  - Supabase Dashboard → Authentication → URL Configuration
  - Adicione: `https://silosaboresgourmet.com.br`

### 5. Rotas SPA não funcionam

**Sintoma:** Refresh na página dá 404

**Soluções:**
- Confirme que `vercel.json` tem os rewrites configurados
- Para o Site: `/((?!admin).*)` → `/index.html`
- Para o Admin: `/admin/:path*` → `/admin/index.html`

## Rollback e Versionamento

### Fazer Rollback na Vercel

1. Vá para o projeto na Vercel Dashboard
2. Clique na aba "Deployments"
3. Encontre a versão anterior que funcionava
4. Clique nos três pontos (...) → "Promote to Production"

### Testar Deploy antes de Produção

```bash
# Deploy para preview (branch diferente de main)
git checkout -b test-deploy
git add .
git commit -m "test: Testando novo deploy"
git push origin test-deploy
```

A Vercel criará automaticamente um preview deployment.

## Otimizações Pós-Deploy

### Performance

1. **Vercel Analytics:** Ative em Settings → Analytics
2. **Compressão:** Já habilitada automaticamente pela Vercel
3. **Cache:** Headers configurados em `vercel.json`
4. **Images:** Use Vercel Image Optimization se adicionar imagens

### Monitoramento

1. **Logs:** Vercel Dashboard → Logs
2. **Performance:** Vercel Analytics
3. **Uptime:** Configure alerts em Settings → Monitoring
4. **Supabase Logs:** Supabase Dashboard → Logs

### Segurança

1. Configure CSP headers se necessário
2. Revise políticas de CORS no Supabase
3. Monitore tentativas de login suspeitas
4. Mantenha dependências atualizadas

## Suporte e Documentação Adicional

- **Vercel:** https://vercel.com/docs
- **Supabase:** https://supabase.com/docs
- **Vite:** https://vitejs.dev/guide/

Para mais detalhes sobre:
- **Permissões do Sistema:** Ver `SISTEMA_PERMISSOES.md`
- **Regras de Negócio:** Ver `REGRAS_NEGOCIO_IMPLEMENTADAS.md`
- **Configuração Local:** Ver `CONFIGURACAO_SITE.md` 