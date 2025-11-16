-- Configuração do Storage para upload de imagens
-- Cria o bucket 'uploads' e configura as políticas de acesso

-- 1. Criar o bucket 'uploads' se não existir
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'uploads',
  'uploads',
  false, -- Bucket privado (requer autenticação)
  52428800, -- 50MB em bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 2. Remover políticas antigas se existirem (para evitar conflitos)
DROP POLICY IF EXISTS "Usuários autenticados podem fazer upload" ON storage.objects;
DROP POLICY IF EXISTS "Usuários autenticados podem ler arquivos" ON storage.objects;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar arquivos" ON storage.objects;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar arquivos" ON storage.objects;
DROP POLICY IF EXISTS "Acesso público para leitura (desenvolvimento)" ON storage.objects;

-- 3. Criar políticas de acesso para o bucket 'uploads'
-- Para desenvolvimento local: permitir acesso público (sem autenticação)
-- ATENÇÃO: Em produção, substitua por políticas que exigem autenticação

-- Permitir que qualquer um faça upload (desenvolvimento local)
CREATE POLICY "Acesso público para upload (desenvolvimento)"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'uploads');

-- Permitir que qualquer um leia arquivos (desenvolvimento local)
CREATE POLICY "Acesso público para leitura (desenvolvimento)"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'uploads');

-- Permitir que qualquer um atualize arquivos (desenvolvimento local)
CREATE POLICY "Acesso público para atualização (desenvolvimento)"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'uploads');

-- Permitir que qualquer um delete arquivos (desenvolvimento local)
CREATE POLICY "Acesso público para exclusão (desenvolvimento)"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'uploads');

-- Políticas para produção (comentadas - descomente em produção)
/*
-- Permitir que usuários autenticados façam upload de arquivos
CREATE POLICY "Usuários autenticados podem fazer upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'uploads');

-- Permitir que usuários autenticados leiam arquivos
CREATE POLICY "Usuários autenticados podem ler arquivos"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'uploads');

-- Permitir que usuários autenticados atualizem arquivos
CREATE POLICY "Usuários autenticados podem atualizar arquivos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'uploads');

-- Permitir que usuários autenticados deletem arquivos
CREATE POLICY "Usuários autenticados podem deletar arquivos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'uploads');
*/

