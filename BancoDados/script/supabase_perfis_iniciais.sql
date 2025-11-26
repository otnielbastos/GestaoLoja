-- Inserir perfis iniciais se não existirem
INSERT INTO perfis (nome, descricao, permissoes, ativo) VALUES
('Administrador', 'Acesso total ao sistema', '{
  "usuarios": ["criar", "listar", "editar", "excluir"],
  "clientes": ["criar", "listar", "editar", "excluir"],
  "produtos": ["criar", "listar", "editar", "excluir"],
  "pedidos": ["criar", "listar", "editar", "excluir"],
  "estoque": ["criar", "listar", "editar", "excluir"],
  "relatorios": ["read"],
  "configuracoes": ["read", "write"]
}', true),
('Gerente', 'Acesso de gerenciamento', '{
  "usuarios": ["listar", "editar"],
  "clientes": ["criar", "listar", "editar"],
  "produtos": ["criar", "listar", "editar"],
  "pedidos": ["criar", "listar", "editar"],
  "estoque": ["criar", "listar", "editar"],
  "relatorios": ["read"]
}', true),
('Vendedor', 'Acesso de vendas', '{
  "clientes": ["criar", "listar", "editar"],
  "produtos": ["listar"],
  "pedidos": ["criar", "listar", "editar"],
  "estoque": ["listar"]
}', true),
('Operador', 'Acesso operacional', '{
  "produtos": ["listar"],
  "pedidos": ["listar", "editar"],
  "estoque": ["criar", "listar", "editar"]
}', true)
ON CONFLICT (nome) DO NOTHING;

-- Criar usuário administrador padrão se não existir
INSERT INTO usuarios (nome, email, senha, perfil_id, ativo, cargo) 
SELECT 
  'Administrador',
  'admin@silo.com',
  crypt('admin123', gen_salt('bf')),
  p.id,
  true,
  'Administrador do Sistema'
FROM perfis p 
WHERE p.nome = 'Administrador'
AND NOT EXISTS (SELECT 1 FROM usuarios WHERE email = 'admin@silo.com'); 