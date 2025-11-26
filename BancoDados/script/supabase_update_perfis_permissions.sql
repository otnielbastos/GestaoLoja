-- Atualizar tabela perfis para suporte a permissões estruturadas
ALTER TABLE perfis 
ADD COLUMN IF NOT EXISTS permissoes JSONB DEFAULT '{"pages": [], "actions": {}}'::jsonb;

-- Atualizar perfis existentes com permissões padrão
UPDATE perfis SET permissoes = CASE 
  WHEN nome = 'Administrador' THEN '{
    "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios", "usuarios", "configuracoes"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar", "criar", "editar", "excluir", "exportar"],
      "pedidos": ["visualizar", "criar", "editar", "excluir", "aprovar", "cancelar", "exportar", "imprimir"],
      "clientes": ["visualizar", "criar", "editar", "excluir", "exportar"],
      "estoque": ["visualizar", "editar", "exportar"],
      "entregas": ["visualizar", "editar", "exportar"],
      "relatorios": ["visualizar", "exportar", "imprimir"],
      "usuarios": ["visualizar", "criar", "editar", "excluir"],
      "configuracoes": ["visualizar", "editar"]
    }
  }'::jsonb
  WHEN nome = 'Gerente' THEN '{
    "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar", "criar", "editar", "exportar"],
      "pedidos": ["visualizar", "criar", "editar", "aprovar", "exportar", "imprimir"],
      "clientes": ["visualizar", "criar", "editar", "exportar"],
      "estoque": ["visualizar", "editar", "exportar"],
      "entregas": ["visualizar", "editar", "exportar"],
      "relatorios": ["visualizar", "exportar", "imprimir"]
    }
  }'::jsonb
  WHEN nome = 'Vendedor' THEN '{
    "pages": ["dashboard", "produtos", "pedidos", "clientes"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar"],
      "pedidos": ["visualizar", "criar", "editar"],
      "clientes": ["visualizar", "criar", "editar"]
    }
  }'::jsonb
  WHEN nome = 'Operacional' THEN '{
    "pages": ["dashboard", "produtos", "pedidos", "estoque", "entregas"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar"],
      "pedidos": ["visualizar", "editar"],
      "estoque": ["visualizar", "editar"],
      "entregas": ["visualizar", "editar"]
    }
  }'::jsonb
  ELSE '{"pages": ["dashboard"], "actions": {"dashboard": ["visualizar"]}}'::jsonb
END
WHERE permissoes IS NULL OR permissoes = '{"pages": [], "actions": {}}'::jsonb;

-- Inserir perfis padrão se não existirem
INSERT INTO perfis (nome, descricao, permissoes, ativo) 
SELECT * FROM (VALUES
  ('Administrador', 'Acesso total ao sistema', '{
    "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios", "usuarios", "configuracoes"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar", "criar", "editar", "excluir", "exportar"],
      "pedidos": ["visualizar", "criar", "editar", "excluir", "aprovar", "cancelar", "exportar", "imprimir"],
      "clientes": ["visualizar", "criar", "editar", "excluir", "exportar"],
      "estoque": ["visualizar", "editar", "exportar"],
      "entregas": ["visualizar", "editar", "exportar"],
      "relatorios": ["visualizar", "exportar", "imprimir"],
      "usuarios": ["visualizar", "criar", "editar", "excluir"],
      "configuracoes": ["visualizar", "editar"]
    }
  }'::jsonb, true),
  ('Gerente', 'Acesso de gerenciamento operacional', '{
    "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar", "criar", "editar", "exportar"],
      "pedidos": ["visualizar", "criar", "editar", "aprovar", "exportar", "imprimir"],
      "clientes": ["visualizar", "criar", "editar", "exportar"],
      "estoque": ["visualizar", "editar", "exportar"],
      "entregas": ["visualizar", "editar", "exportar"],
      "relatorios": ["visualizar", "exportar", "imprimir"]
    }
  }'::jsonb, true),
  ('Vendedor', 'Acesso para vendas e atendimento', '{
    "pages": ["dashboard", "produtos", "pedidos", "clientes"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar"],
      "pedidos": ["visualizar", "criar", "editar"],
      "clientes": ["visualizar", "criar", "editar"]
    }
  }'::jsonb, true),
  ('Operacional', 'Acesso para produção e estoque', '{
    "pages": ["dashboard", "produtos", "pedidos", "estoque", "entregas"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar"],
      "pedidos": ["visualizar", "editar"],
      "estoque": ["visualizar", "editar"],
      "entregas": ["visualizar", "editar"]
    }
  }'::jsonb, true)
) AS v(nome, descricao, permissoes, ativo)
WHERE NOT EXISTS (SELECT 1 FROM perfis WHERE perfis.nome = v.nome);

-- Criar índice para consultas de permissões
CREATE INDEX IF NOT EXISTS idx_perfis_permissoes ON perfis USING GIN (permissoes);

-- Comentários para documentação
COMMENT ON COLUMN perfis.permissoes IS 'Permissões estruturadas em JSON com páginas e ações permitidas';
COMMENT ON INDEX idx_perfis_permissoes IS 'Índice GIN para consultas eficientes em permissões JSON'; 