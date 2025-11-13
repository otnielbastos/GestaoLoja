# 📋 Instruções Rápidas - Deploy Unificado

## 🎯 O Que Foi Feito

Configurei o projeto para que ao digitar:
- **`https://silosaboresgourmet.com.br`** → Abre o **Site Institucional**
- **`https://silosaboresgourmet.com.br/admin`** → Abre o **Sistema de Gestão**

Ambos são servidos a partir do **mesmo domínio** na Vercel! 🎉

## 🚀 Para Fazer Deploy na Vercel

### 1. Teste localmente (as dependências do Site serão instaladas automaticamente)
```bash
npm run build
```

Se aparecer "✅ Build concluído com sucesso!", está tudo certo!

### 2. Faça push para o repositório
```bash
git add .
git commit -m "Configuração de deploy unificado"
git push
```

### 3. Configure na Vercel Dashboard

**Install Command:**
```
npm install
```
*Nota: As dependências do Site são instaladas automaticamente pelo script de build.*

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

### 4. Configure o domínio

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

- [ ] Dependências da raiz instaladas (`npm install`)
- [ ] Build local testado (`npm run build`)
- [ ] Variáveis de ambiente configuradas na Vercel
- [ ] Install Command configurado: `npm install`
- [ ] Build Command configurado: `npm run build`
- [ ] Output Directory configurado: `dist`
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

