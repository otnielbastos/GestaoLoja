# Guia: Como Trocar Entre Instâncias do Supabase Local

Este guia explica como alternar entre as duas instâncias do Supabase local disponíveis no projeto.

## Instâncias Disponíveis

### 1. Instância Original (GestaoLoja)
- **URL API:** http://127.0.0.1:54321
- **Studio:** http://127.0.0.1:54323
- **Database:** postgresql://postgres:postgres@127.0.0.1:54322/postgres

### 2. Instância Cópia (GestaoLoja-Prod_Local)
- **URL API:** http://127.0.0.1:54331
- **Studio:** http://127.0.0.1:54333
- **Database:** postgresql://postgres:postgres@127.0.0.1:54332/postgres

## Método 1: Usando o Script Automatizado (Recomendado)

Execute o script PowerShell para trocar entre instâncias:

```powershell
.\supabase\scripts\trocar_instancia.ps1
```

O script vai:
1. Mostrar as opções disponíveis
2. Solicitar qual instância deseja usar
3. Atualizar o arquivo `.env.local` automaticamente
4. Informar que você precisa reiniciar o servidor

### Opções do Script

Você também pode especificar a instância diretamente:

```powershell
# Para usar a instância original
.\supabase\scripts\trocar_instancia.ps1 -Instancia original

# Para usar a instância cópia
.\supabase\scripts\trocar_instancia.ps1 -Instancia copia

# Ou usar os nomes completos
.\supabase\scripts\trocar_instancia.ps1 -Instancia GestaoLoja
.\supabase\scripts\trocar_instancia.ps1 -Instancia GestaoLoja-Prod_Local
```

## Método 2: Edição Manual do .env.local

1. Abra o arquivo `.env.local` na raiz do projeto
2. Localize as seções das instâncias
3. Para ativar uma instância:
   - **Remova o `#`** das linhas `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` da instância desejada
   - **Adicione o `#`** nas linhas correspondentes da instância atual
4. Salve o arquivo

**Exemplo:**

Instância Original ativa:
```env
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=eyJhbGci...

# VITE_SUPABASE_URL=http://127.0.0.1:54331
# VITE_SUPABASE_ANON_KEY=eyJhbGci...
```

Instância Cópia ativa:
```env
# VITE_SUPABASE_URL=http://127.0.0.1:54321
# VITE_SUPABASE_ANON_KEY=eyJhbGci...

VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_ANON_KEY=eyJhbGci...
```

## Passo Final: Reiniciar o Servidor

Após alterar a instância (por qualquer método), você **deve reiniciar** o servidor de desenvolvimento:

1. Pressione `Ctrl+C` no terminal onde o `npm run dev` está rodando
2. Execute novamente: `npm run dev`

As mudanças no `.env.local` só são carregadas quando o servidor é iniciado.

## Verificar Qual Instância Está Ativa

Para verificar qual instância está configurada no momento:

```powershell
Get-Content .env.local | Select-String -Pattern "^VITE_SUPABASE_URL|ATIVA"
```

Ou simplesmente abra o arquivo `.env.local` e procure pela seção marcada como **"ATIVA"**.

## Dicas

- ✨ Use o **script automatizado** para evitar erros de formatação
- 🔄 Sempre **reinicie o servidor** após trocar de instância
- 📝 O arquivo `.env.local` contém comentários explicativos sobre cada instância
- 🔍 Você pode acessar o Studio de ambas as instâncias simultaneamente (em portas diferentes)

## Resolução de Problemas

### A aplicação não está conectando à instância correta
- Verifique se reiniciou o servidor após alterar o `.env.local`
- Confirme que não há erros de sintaxe no arquivo (linhas comentadas corretamente)
- Verifique se a instância do Supabase está rodando: `npx supabase status`

### Erro ao executar o script
- Certifique-se de estar na raiz do projeto
- Verifique se tem permissões para executar scripts PowerShell
- Se necessário, execute: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned`




