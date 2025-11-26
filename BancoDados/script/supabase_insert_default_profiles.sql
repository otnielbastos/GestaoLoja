-- Script para inserir perfis padrão no sistema
-- Execute este script no Supabase SQL Editor

-- Inserir perfil Administrador
INSERT INTO perfis (nome, descricao, permissoes, ativo) VALUES (
  'Administrador',
  'Acesso total ao sistema',
  '{
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
  }'::jsonb,
  true
) ON CONFLICT (nome) DO UPDATE SET
  descricao = EXCLUDED.descricao,
  permissoes = EXCLUDED.permissoes,
  ativo = EXCLUDED.ativo;

-- Inserir perfil Gerente
INSERT INTO perfis (nome, descricao, permissoes, ativo) VALUES (
  'Gerente',
  'Acesso a operações e relatórios',
  '{
    "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar", "criar", "editar", "exportar"],
      "pedidos": ["visualizar", "criar", "editar", "aprovar", "cancelar", "exportar", "imprimir"],
      "clientes": ["visualizar", "criar", "editar", "exportar"],
      "estoque": ["visualizar", "editar", "exportar"],
      "entregas": ["visualizar", "editar", "exportar"],
      "relatorios": ["visualizar", "exportar", "imprimir"]
    }
  }'::jsonb,
  true
) ON CONFLICT (nome) DO UPDATE SET
  descricao = EXCLUDED.descricao,
  permissoes = EXCLUDED.permissoes,
  ativo = EXCLUDED.ativo;

-- Inserir perfil Vendedor
INSERT INTO perfis (nome, descricao, permissoes, ativo) VALUES (
  'Vendedor',
  'Acesso a vendas e clientes',
  '{
    "pages": ["dashboard", "pedidos", "clientes"],
    "actions": {
      "dashboard": ["visualizar"],
      "pedidos": ["visualizar", "criar", "editar", "exportar"],
      "clientes": ["visualizar", "criar", "editar", "exportar"]
    }
  }'::jsonb,
  true
) ON CONFLICT (nome) DO UPDATE SET
  descricao = EXCLUDED.descricao,
  permissoes = EXCLUDED.permissoes,
  ativo = EXCLUDED.ativo;

-- Inserir perfil Operacional
INSERT INTO perfis (nome, descricao, permissoes, ativo) VALUES (
  'Operacional',
  'Acesso a estoque e entregas',
  '{
    "pages": ["dashboard", "produtos", "estoque", "entregas"],
    "actions": {
      "dashboard": ["visualizar"],
      "produtos": ["visualizar"],
      "estoque": ["visualizar", "editar"],
      "entregas": ["visualizar", "editar"]
    }
  }'::jsonb,
  true
) ON CONFLICT (nome) DO UPDATE SET
  descricao = EXCLUDED.descricao,
  permissoes = EXCLUDED.permissoes,
  ativo = EXCLUDED.ativo;

-- Verificar se os perfis foram criados
SELECT id, nome, descricao, ativo, created_at 
FROM perfis 
WHERE nome IN ('Administrador', 'Gerente', 'Vendedor', 'Operacional')
ORDER BY nome; 