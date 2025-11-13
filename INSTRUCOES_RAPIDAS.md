# 📋 Instruções Rápidas - Deploy Unificado

## 🎯 O Que Foi Feito

Configurei o projeto para que ao digitar:
- **`https://silosaboresgourmet.com.br`** → Abre o **Site Institucional**
- **`https://silosaboresgourmet.com.br/admin`** → Abre o **Sistema de Gestão**

Ambos são servidos a partir do **mesmo domínio** na Vercel! 🎉

## 🚀 Para Fazer Deploy na Vercel

### 1. Instale as dependências do Site (se ainda não fez)
```bash
cd Site
npm install
cd ..
```

### 2. Teste localmente
```bash
npm run build
```

Se aparecer "✅ Build concluído com sucesso!", está tudo certo!

### 3. Faça push para o repositório
```bash
git add .
git commit -m "Configuração de deploy unificado"
git push
```

### 4. Configure na Vercel Dashboard

**Install Command:**
```
npm install && cd Site && npm install && cd ..
```

**Build Command:**
```
npm run build
```

**Output Directory:**
```
dist
```

**Variáveis de Ambiente:**
- `VITE_SUPABASE_URL` - URL do seu projeto Supabase
- `VITE_SUPABASE_ANON_KEY` - Chave anônima do Supabase

### 5. Configure o domínio

Na Vercel:
1. Vá em **Settings** → **Domains**
2. Adicione `silosaboresgourmet.com.br`
3. Configure o DNS conforme instruções da Vercel

## 💻 Para Desenvolvimento Local

### Executar o Site (porta 8080)
```bash
npm run dev
```
Acesse: http://localhost:8080

### Executar o Admin (porta 8081)
```bash
npm run dev:admin
```
Acesse: http://localhost:8081/admin

### Executar ambos (em terminais separados)
**Terminal 1:**
```bash
npm run dev
```

**Terminal 2:**
```bash
npm run dev:admin
```

## ✅ Checklist Antes do Deploy

- [ ] Dependências instaladas (`npm install` na raiz e em `Site/`)
- [ ] Build local testado (`npm run build`)
- [ ] Variáveis de ambiente configuradas na Vercel
- [ ] Install Command configurado corretamente
- [ ] Domínio configurado na Vercel
- [ ] URLs permitidas configuradas no Supabase

## 📚 Documentação Detalhada

- **Guia completo de deploy:** `DEPLOY_VERCEL.md`
- **Resumo da implementação:** `RESUMO_DEPLOY_UNIFICADO.md`
- **Configuração local:** `CONFIGURACAO_SITE.md`

## 🆘 Problemas?

1. **Build falha?**
   - Execute `npm run build` localmente para ver o erro
   - Verifique se todas as dependências estão instaladas

2. **Admin retorna 404?**
   - Confirme que `dist/admin/` existe após o build
   - Verifique o `vercel.json`

3. **Supabase não conecta?**
   - Verifique as variáveis de ambiente
   - Adicione o domínio nas URLs permitidas do Supabase

---

**Dúvidas?** Consulte `DEPLOY_VERCEL.md` para documentação completa!

