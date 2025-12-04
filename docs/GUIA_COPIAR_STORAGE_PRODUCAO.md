# Guia: Copiar Storage (Imagens) de Produção para Local

Este guia explica como copiar todas as imagens do Supabase Storage de produção para o ambiente local.

## 📋 Opções Disponíveis

### Opção 1: Script Automatizado (Recomendado) ⚡

Use o script PowerShell que automatiza todo o processo:

```powershell
.\supabase\scripts\copiar_storage_producao.ps1
```

O script vai solicitar:
- URL do Supabase de produção
- Chave ANON do Supabase de produção

**O que o script faz:**
1. ✅ Verifica/cria o bucket no local
2. ✅ Lista todos os arquivos de produção
3. ✅ Baixa cada arquivo
4. ✅ Faz upload para o local
5. ✅ Mantém a mesma estrutura de pastas

### Opção 2: Manual via Supabase Studio 🖱️

1. **Acesse o Supabase Studio de produção:**
   - Vá em: Storage → uploads
   - Selecione todos os arquivos
   - Baixe manualmente

2. **Acesse o Supabase Studio local:**
   - http://127.0.0.1:54323
   - Vá em: Storage → uploads
   - Faça upload dos arquivos manualmente

**Limitação:** Pode ser demorado se houver muitos arquivos.

### Opção 3: Via API REST (Avançado) 🔧

Use a API REST do Supabase para copiar programaticamente:

```powershell
# Listar arquivos de produção
$prodUrl = "https://seu-projeto.supabase.co"
$prodKey = "sua-chave-anon"

# Listar todos os arquivos
$files = Invoke-RestMethod -Uri "$prodUrl/storage/v1/object/list/uploads" `
    -Headers @{ "apikey" = $prodKey; "Authorization" = "Bearer $prodKey" }

# Para cada arquivo, baixar e fazer upload
foreach ($file in $files) {
    # Baixar de produção
    $downloadUrl = "$prodUrl/storage/v1/object/public/uploads/$($file.name)"
    # Fazer upload para local
    # ...
}
```

## 🔐 Políticas de Storage

### Políticas de Produção

As políticas de storage de produção já foram restauradas junto com o banco de dados. Elas estão na tabela `storage.objects` e foram aplicadas durante o restore.

### Verificar Políticas Atuais

```sql
-- Ver políticas de storage
SELECT 
    policyname, 
    cmd, 
    qual 
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects';
```

### Aplicar Políticas Iguais à Produção

Se as políticas não foram restauradas corretamente, você pode:

1. **Usar a migration existente:**
   ```bash
   # Executar a migration que cria as políticas
   docker exec supabase_db_GestaoLoja psql -U postgres -d postgres -f /path/to/supabase/migrations/02_storage_setup.sql
   ```

2. **Ou aplicar manualmente via SQL:**
   ```sql
   -- Criar bucket se não existir
   INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
   VALUES (
     'uploads',
     'uploads',
     true, -- true para público (desenvolvimento)
     52428800, -- 50MB
     ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
   )
   ON CONFLICT (id) DO NOTHING;

   -- Políticas públicas (para desenvolvimento local)
   CREATE POLICY "Acesso público para leitura (desenvolvimento)"
   ON storage.objects FOR SELECT
   TO public
   USING (bucket_id = 'uploads');

   CREATE POLICY "Acesso público para upload (desenvolvimento)"
   ON storage.objects FOR INSERT
   TO public
   WITH CHECK (bucket_id = 'uploads');
   ```

## 📊 Estrutura de Pastas

O storage geralmente tem esta estrutura:
```
uploads/
  └── produtos/
      ├── 1748975675797-731946779.jpg
      ├── 1748975675798-123456789.jpg
      └── ...
```

O script mantém a mesma estrutura ao copiar.

## ⚠️ Observações Importantes

1. **Tamanho dos Arquivos:**
   - O script baixa todos os arquivos temporariamente
   - Certifique-se de ter espaço em disco suficiente
   - Arquivos temporários são limpos automaticamente

2. **Velocidade:**
   - O script processa um arquivo por vez
   - Para muitos arquivos, pode levar alguns minutos
   - A opção manual pode ser mais rápida se houver poucos arquivos

3. **Políticas:**
   - As políticas de produção já foram restauradas
   - Para desenvolvimento local, políticas públicas são mais convenientes
   - Ajuste conforme necessário

## 🚀 Executar o Script

```powershell
# Executar o script
.\supabase\scripts\copiar_storage_producao.ps1

# Ou com parâmetros
.\supabase\scripts\copiar_storage_producao.ps1 `
    -ProdUrl "https://seu-projeto.supabase.co" `
    -ProdAnonKey "sua-chave-anon"
```

## ✅ Verificar se Funcionou

Após copiar, verifique:

1. **No Supabase Studio local:**
   - http://127.0.0.1:54323
   - Vá em: Storage → uploads
   - Verifique se os arquivos estão lá

2. **Via SQL:**
   ```sql
   SELECT COUNT(*) FROM storage.objects WHERE bucket_id = 'uploads';
   ```

3. **Na aplicação:**
   - Tente visualizar uma imagem de produto
   - Verifique se as URLs estão corretas

## 🔧 Troubleshooting

### Erro: "Bucket não encontrado"
Execute a migration de storage:
```bash
docker exec supabase_db_GestaoLoja psql -U postgres -d postgres -c "$(Get-Content supabase/migrations/02_storage_setup.sql -Raw)"
```

### Erro: "403 Forbidden"
Verifique se as chaves de API estão corretas e se o bucket é público.

### Arquivos não aparecem
Verifique as políticas de storage e se o bucket está configurado corretamente.

