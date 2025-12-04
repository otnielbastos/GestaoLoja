-- Criar bucket uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'uploads',
  'uploads',
  true,
  52428800,
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Criar políticas públicas para desenvolvimento
DROP POLICY IF EXISTS "Acesso público para leitura (desenvolvimento)" ON storage.objects;
DROP POLICY IF EXISTS "Acesso público para upload (desenvolvimento)" ON storage.objects;
DROP POLICY IF EXISTS "Acesso público para atualização (desenvolvimento)" ON storage.objects;
DROP POLICY IF EXISTS "Acesso público para exclusão (desenvolvimento)" ON storage.objects;

CREATE POLICY "Acesso público para leitura (desenvolvimento)"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'uploads');

CREATE POLICY "Acesso público para upload (desenvolvimento)"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'uploads');

CREATE POLICY "Acesso público para atualização (desenvolvimento)"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'uploads');

CREATE POLICY "Acesso público para exclusão (desenvolvimento)"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'uploads');

