# 🚀 Resumo: Deploy Unificado - Site + Admin

## ✅ Implementação Concluída

O projeto foi configurado com sucesso para servir **duas aplicações** a partir do **mesmo domínio** na Vercel:

### URLs em Produção

```
https://silosaboresgourmet.com.br        → Site Institucional
https://silosaboresgourmet.com.br/admin  → Sistema de Gestão
```

## 📁 Estrutura de Deploy

Quando você faz o build, a seguinte estrutura é criada:

```
dist/
├── index.html          ← Site Institucional (raiz)
├── assets/
│   ├── index-xxx.js   ← JavaScript do Site
│   └── index-xxx.css  ← CSS do Site
├── robots.txt
├── sitemap.xml
└── admin/              ← Sistema de Gestão
    ├── index.html     ← Login/Dashboard do Admin
    ├── assets/
    │   ├── index-yyy.js   ← JavaScript do Admin
    │   └── index-yyy.css  ← CSS do Admin
    ├── favicon.ico
    └── robots.txt
```

## 🔧 Arquivos Modificados/Criados

### Arquivos Criados:
1. **`build-all.cjs`** - Script que compila ambos os projetos e organiza na estrutura correta
2. **`RESUMO_DEPLOY_UNIFICADO.md`** - Este arquivo

### Arquivos Modificados:
1. **`vite.config.ts`** (raiz)
   - Alterado `base: "/"` → `base: "/admin"`
   - Alterado porta de 8080 → 8081

2. **`vercel.json`**
   - Adicionados rewrites para rotear `/admin/*` corretamente
   - Adicionados headers de cache

3. **`package.json`** (raiz)
   - `npm run dev` → Executa o Site (porta 8080)
   - `npm run dev:admin` → Executa o Admin (porta 8081)
   - `npm run build` → Compila ambos (via build-all.cjs)
   - `npm run vercel-build` → Build para Vercel

4. **`Site/index.html`**
   - Removida referência problemática a `vite.svg`
   - Corrigida URL dinâmica no JSON-LD Schema
   - Adicionadas URLs corretas do domínio

5. **`Site/vite.config.ts`**
   - Alterada porta de 3000 → 8080

6. **`DEPLOY_VERCEL.md`**
   - Atualizada documentação completa de deploy
   - Adicionadas instruções para estrutura unificada
   - Adicionado troubleshooting

7. **`CONFIGURACAO_SITE.md`**
   - Atualizada com informações sobre deploy unificado

## 🎯 Como Funciona

### Desenvolvimento Local

```bash
# Executar Site Institucional (porta 8080)
npm run dev

# Executar Sistema de Gestão (porta 8081)
npm run dev:admin
```

### Build e Deploy

```bash
# Build local (testa antes de fazer push)
npm run build

# Push para repositório (Vercel faz deploy automático)
git add .
git commit -m "Implementação de deploy unificado"
git push
```

### Fluxo do Build

1. **Script `build-all.cjs` executa:**
   - Compila Sistema de Gestão → `dist/` (temporário)
   - Move para `dist-admin/` (temporário)
   - Compila Site Institucional → `Site/out/`
   - Copia `Site/out/*` → `dist/` (raiz)
   - Move `dist-admin/*` → `dist/admin/`
   - Remove temporários

2. **Vercel usa `vercel.json`:**
   - Serve `dist/` como raiz
   - Rotas `/admin/*` → `dist/admin/index.html`
   - Rotas `/*` (exceto /admin) → `dist/index.html`

## ⚙️ Configuração da Vercel

### Install Command:
```bash
npm install && cd Site && npm install && cd ..
```

### Build Command:
```bash
npm run build
```

### Output Directory:
```
dist
```

### Variáveis de Ambiente:
```
VITE_SUPABASE_URL=<sua_url_supabase>
VITE_SUPABASE_ANON_KEY=<sua_chave_supabase>
```

## 🌐 Como as Rotas Funcionam

O `vercel.json` contém rewrites que funcionam assim:

```json
{
  "rewrites": [
    {
      "source": "/admin/:path*",
      "destination": "/admin/index.html"
    },
    {
      "source": "/((?!admin).*)",
      "destination": "/index.html"
    }
  ]
}
```

**Exemplos:**
- `https://silosaboresgourmet.com.br` → `dist/index.html` (Site)
- `https://silosaboresgourmet.com.br/sobre` → `dist/index.html` (Site, roteamento React)
- `https://silosaboresgourmet.com.br/admin` → `dist/admin/index.html` (Admin)
- `https://silosaboresgourmet.com.br/admin/dashboard` → `dist/admin/index.html` (Admin, roteamento React)

## ✅ Vantagens desta Abordagem

1. **✅ Um único domínio** - Tudo em `silosaboresgourmet.com.br`
2. **✅ Deploy unificado** - Um push, ambas aplicações atualizadas
3. **✅ Sem CORS** - Admin e Site no mesmo domínio
4. **✅ SEO otimizado** - Site na raiz para melhor indexação
5. **✅ Separação clara** - `/admin` claramente separado do site público
6. **✅ Custo reduzido** - Um projeto Vercel ao invés de dois

## 📝 Próximos Passos

1. **Configurar domínio na Vercel:**
   - Adicione `silosaboresgourmet.com.br` em Settings → Domains
   - Configure registros DNS conforme instruções

2. **Configurar Supabase:**
   - Adicione `https://silosaboresgourmet.com.br` nas URLs permitidas
   - Configure variáveis de ambiente na Vercel

3. **Testar deploy:**
   - Faça push para o repositório
   - Verifique ambas as URLs após deploy

4. **Monitorar:**
   - Ative Vercel Analytics
   - Configure alerts
   - Monitore logs

## 🆘 Troubleshooting

### Build falha na Vercel
- Verifique o Install Command
- Confirme que `build-all.cjs` está no repositório
- Veja os logs da Vercel para detalhes

### Admin retorna 404
- Verifique se `dist/admin/index.html` existe após build
- Confirme rewrites no `vercel.json`

### Assets não carregam
- Confirme `base: "/admin"` em `vite.config.ts` (raiz)
- Limpe cache do browser

## 📚 Documentação Relacionada

- **Deploy completo**: Ver `DEPLOY_VERCEL.md`
- **Configuração local**: Ver `CONFIGURACAO_SITE.md`
- **Permissões**: Ver `SISTEMA_PERMISSOES.md`
- **Regras de negócio**: Ver `REGRAS_NEGOCIO_IMPLEMENTADAS.md`

---

**Data de implementação:** 13/11/2025  
**Status:** ✅ Implementado e testado localmente

