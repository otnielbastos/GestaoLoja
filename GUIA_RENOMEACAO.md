# Guia de Renomeação: Silo → GestaoLoja

Este guia contém as instruções para renomear o projeto de **Silo** para **GestaoLoja** na Vercel, Supabase e GitHub.

## ✅ Alterações já realizadas no projeto local

- ✅ Removido site institucional (componentes e páginas)
- ✅ Atualizado `package.json` (nome: `gestao-loja`)
- ✅ Atualizado `README.md`
- ✅ Atualizado rotas do sistema (removida rota `/` do site, mantido apenas sistema de gestão)
- ✅ Renomeado "SiloSystem" para "GestaoLoja" em componentes e páginas
- ✅ Atualizado `index.html` com novo título

## 📁 Sobre renomear a pasta local

**Importante**: O nome da pasta local (`C:\dev\Silo`) **não causa conflito** no Git/GitHub, pois o Git rastreia o **conteúdo** dos arquivos, não o nome da pasta. Porém, para manter consistência, recomenda-se renomear a pasta local **após** renomear no GitHub.

### Ordem recomendada de operações:

1. ✅ **Primeiro**: Renomear no GitHub (passo mais importante)
2. ✅ **Segundo**: Atualizar o remote local
3. ✅ **Terceiro**: Renomear a pasta local (opcional, mas recomendado)
4. ✅ **Quarto**: Renomear na Vercel e Supabase

### Como renomear a pasta local (Windows):

**Opção 1: Via Explorer**
1. Feche o VS Code/Cursor e qualquer terminal que esteja usando a pasta
2. Navegue até `C:\dev\`
3. Clique com botão direito na pasta `Silo`
4. Selecione **Renomear**
5. Digite `GestaoLoja` e pressione Enter

**Opção 2: Via PowerShell (com a pasta fechada)**
```powershell
# Navegue até a pasta pai
cd C:\dev

# Renomeie a pasta
Rename-Item -Path "Silo" -NewName "GestaoLoja"
```

**Opção 3: Via CMD (com a pasta fechada)**
```cmd
cd C:\dev
ren Silo GestaoLoja
```

⚠️ **IMPORTANTE**: 
- Feche todos os editores e terminais antes de renomear
- Após renomear, abra o projeto na nova pasta
- O Git continuará funcionando normalmente, pois o remote já estará atualizado

## 📋 Passos para renomear na Vercel

### 1. Renomear o projeto na Vercel

1. Acesse o [Dashboard da Vercel](https://vercel.com/dashboard)
2. Encontre o projeto **Silo** (ou o nome atual)
3. Clique em **Settings** (Configurações)
4. Na seção **General**, encontre o campo **Project Name**
5. Altere de `Silo` para `GestaoLoja`
6. Clique em **Save**

### 2. Atualizar variáveis de ambiente (se necessário)

1. Ainda em **Settings**, vá para **Environment Variables**
2. Verifique se há variáveis que referenciam "Silo" no nome ou valor
3. Atualize conforme necessário

### 3. Verificar domínio (se aplicável)

1. Em **Settings** → **Domains**
2. Se houver domínios configurados, verifique se precisam ser atualizados
3. O domínio em si não precisa mudar, apenas o nome do projeto

## 📋 Passos para renomear no Supabase

### 1. Renomear o projeto no Supabase

1. Acesse o [Dashboard do Supabase](https://app.supabase.com)
2. Encontre o projeto **Silo** (ou o nome atual)
3. Clique no ícone de **Settings** (⚙️) do projeto
4. Vá para **General Settings**
5. Encontre o campo **Project Name**
6. Altere de `Silo` para `GestaoLoja`
7. Clique em **Save**

### 2. Atualizar referências no código (se houver)

Se você tiver referências ao `project_id` ou outras configurações do Supabase no código:
- Verifique arquivos `.env` ou `.env.local`
- Verifique se há referências ao nome antigo do projeto
- Atualize `VITE_SUPABASE_URL` se necessário (geralmente não precisa mudar)

### 3. Verificar configurações de autenticação

1. Em **Settings** → **Authentication** → **URL Configuration**
2. Verifique as **Site URL** e **Redirect URLs**
3. Atualize se houver referências ao nome antigo do projeto

## 📋 Passos para renomear no GitHub

### 1. Renomear o repositório no GitHub

1. Acesse o repositório no GitHub
2. Clique em **Settings** (Configurações)
3. Role até a seção **Repository name**
4. Altere de `Silo` para `GestaoLoja` (ou `gestao-loja` se preferir kebab-case)
5. Clique em **Rename**

⚠️ **Importante**: O GitHub avisará que todas as referências ao repositório antigo serão redirecionadas automaticamente, mas é recomendado atualizar:
- URLs em documentação
- Links em outros projetos
- Webhooks e integrações

### 2. Atualizar a descrição do repositório

1. Ainda em **Settings** → **General**
2. Atualize a **Description** do repositório se mencionar "Silo"
3. Atualize o **Website** se houver

### 3. Atualizar README e documentação

1. Verifique se o `README.md` já foi atualizado (já feito ✅)
2. Atualize outros arquivos de documentação se necessário

### 4. Atualizar remote local (OBRIGATÓRIO após renomear no GitHub)

Após renomear no GitHub, você **DEVE** atualizar o remote local:

```bash
# 1. Verificar remote atual
git remote -v
# Isso mostrará algo como: origin  https://github.com/SEU_USUARIO/Silo.git

# 2. Atualizar a URL do remote
git remote set-url origin https://github.com/SEU_USUARIO/GestaoLoja.git

# Ou se usar SSH
git remote set-url origin git@github.com:SEU_USUARIO/GestaoLoja.git

# 3. Verificar se foi atualizado corretamente
git remote -v
# Agora deve mostrar: origin  https://github.com/SEU_USUARIO/GestaoLoja.git
```

### 5. Renomear a pasta local (OPCIONAL, mas recomendado)

Após atualizar o remote, você pode renomear a pasta local de `C:\dev\Silo` para `C:\dev\GestaoLoja`:

**⚠️ IMPORTANTE**: Feche o VS Code/Cursor e todos os terminais antes de renomear!

**Via Explorer:**
1. Feche todos os editores e terminais
2. Navegue até `C:\dev\`
3. Clique com botão direito em `Silo` → **Renomear** → `GestaoLoja`

**Via PowerShell:**
```powershell
cd C:\dev
Rename-Item -Path "Silo" -NewName "GestaoLoja"
```

**Via CMD:**
```cmd
cd C:\dev
ren Silo GestaoLoja
```

Após renomear, abra o projeto na nova pasta. O Git continuará funcionando normalmente!

## 🔄 Ordem completa de operações (RECOMENDADA)

Siga esta ordem para evitar problemas:

### Passo 1: Commit das alterações locais (ANTES de renomear no GitHub)
```bash
git add .
git commit -m "Renomear projeto de Silo para GestaoLoja e remover site institucional"
# NÃO faça push ainda!
```

### Passo 2: Renomear no GitHub
- Siga as instruções da seção "Passos para renomear no GitHub" acima
- Após renomear, o GitHub redirecionará automaticamente, mas você precisa atualizar o remote

### Passo 3: Atualizar remote local
```bash
git remote set-url origin https://github.com/SEU_USUARIO/GestaoLoja.git
git remote -v  # Verificar se foi atualizado
```

### Passo 4: Fazer push das alterações
```bash
git push origin main
```

### Passo 5: Renomear na Vercel e Supabase
- Siga as instruções das seções correspondentes acima

### Passo 6: Renomear pasta local (OPCIONAL)
- Feche editores e terminais
- Renomeie `C:\dev\Silo` para `C:\dev\GestaoLoja`
- Abra o projeto na nova pasta

### Passo 7: Verificar e testar
- Verifique se o deploy na Vercel foi acionado automaticamente
- Teste o sistema:
  - Acesse a URL do projeto na Vercel
  - Verifique se o login funciona
  - Teste as funcionalidades principais

## 📝 Checklist final (siga esta ordem!)

- [ ] **1. Alterações locais commitadas** (sem push ainda)
- [ ] **2. Repositório renomeado no GitHub**
- [ ] **3. Remote local atualizado** (`git remote set-url`)
- [ ] **4. Push das alterações realizado** (`git push`)
- [ ] **5. Projeto renomeado na Vercel**
- [ ] **6. Projeto renomeado no Supabase**
- [ ] **7. Pasta local renomeada** (opcional, mas recomendado)
- [ ] **8. Deploy verificado na Vercel**
- [ ] **9. Sistema testado e funcionando**

## ⚠️ Observações importantes

1. **Domínios**: Se você tiver domínios customizados configurados, eles não precisam ser alterados, apenas o nome do projeto.

2. **URLs de produção**: As URLs de produção (se houver) não mudam automaticamente. Se você quiser uma URL diferente, precisará configurar um novo domínio.

3. **Backup**: Antes de fazer alterações importantes, sempre faça backup das configurações.

4. **Integrações**: Verifique se há outras integrações (CI/CD, webhooks, etc.) que referenciam o nome antigo do projeto.

## ❓ Perguntas Frequentes

### Posso renomear a pasta local antes de renomear no GitHub?

**Resposta curta**: Sim, mas não é recomendado.

**Resposta detalhada**:
- O Git **não se importa** com o nome da pasta local
- O Git rastreia o **conteúdo** dos arquivos e o **remote** configurado
- Porém, se você renomear a pasta local **antes** de renomear no GitHub:
  - O remote ainda apontará para `github.com/.../Silo.git`
  - Quando você renomear no GitHub depois, precisará atualizar o remote de qualquer forma
  - Pode causar confusão sobre qual é o nome "correto"

**Recomendação**: 
1. Primeiro renomeie no GitHub
2. Depois atualize o remote local
3. Por último renomeie a pasta local

Isso mantém tudo sincronizado e evita confusão.

### O nome da pasta local causa conflito no Git?

**Não!** O Git não se importa com o nome da pasta. Você pode ter a pasta chamada `Silo`, `GestaoLoja`, `MeuProjeto` ou qualquer outro nome. O que importa é:
- O conteúdo dos arquivos
- A URL do remote (que aponta para o repositório no GitHub)

### Preciso renomear a pasta local?

**Não é obrigatório**, mas é **recomendado** para:
- Manter consistência entre local e remoto
- Evitar confusão futura
- Facilitar identificação do projeto

Se você não renomear, o Git continuará funcionando normalmente.

## 🆘 Problemas comuns

### Erro ao fazer push após renomear o repositório
**Solução**: Atualize o remote conforme instruções acima.

### Deploy não funciona após renomear
**Solução**: 
1. Verifique se o repositório está conectado corretamente na Vercel
2. Verifique se as variáveis de ambiente estão configuradas
3. Tente fazer um novo deploy manual

### Autenticação não funciona
**Solução**: 
1. Verifique as URLs de redirecionamento no Supabase
2. Verifique se `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` estão corretos

