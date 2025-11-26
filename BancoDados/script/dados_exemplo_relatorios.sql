-- Dados de exemplo para testar os relatórios
-- Execute estes comandos no painel SQL do Supabase

-- Inserir produtos de exemplo (se não existirem)
INSERT INTO produtos (nome, descricao, preco_venda, preco_custo, quantidade_minima, categoria, tipo_produto, unidade_medida, status) VALUES
('Pão Francês', 'Pão francês tradicional', 0.70, 0.35, 50, 'Padaria', 'producao_propria', 'unidade', 'ativo'),
('Refrigerante 2L', 'Refrigerante Coca-Cola 2 litros', 8.90, 5.50, 20, 'Bebidas', 'revenda', 'unidade', 'ativo'),
('Leite 1L', 'Leite integral 1 litro', 5.80, 4.20, 30, 'Laticínios', 'revenda', 'litro', 'ativo'),
('Açúcar 1kg', 'Açúcar cristal 1kg', 4.50, 3.20, 25, 'Mercearia', 'revenda', 'kg', 'ativo'),
('Café 500g', 'Café torrado e moído 500g', 12.90, 8.50, 15, 'Mercearia', 'revenda', 'kg', 'ativo')
ON CONFLICT (nome) DO NOTHING;

-- Inserir clientes de exemplo (se não existirem)
INSERT INTO clientes (nome, email, telefone, tipo_pessoa, endereco_bairro, status) VALUES
('João Silva', 'joao@email.com', '11999999999', 'fisica', 'Centro', 'ativo'),
('Maria Santos', 'maria@email.com', '11888888888', 'fisica', 'Jardim', 'ativo'),
('Pedro Oliveira', 'pedro@email.com', '11777777777', 'fisica', 'Vila Nova', 'ativo'),
('Ana Costa', 'ana@email.com', '11666666666', 'fisica', 'Centro', 'ativo'),
('Carlos Souza', 'carlos@email.com', '11555555555', 'fisica', 'Jardim', 'ativo')
ON CONFLICT (email) DO NOTHING;

-- Inserir pedidos de exemplo dos últimos 7 dias
INSERT INTO pedidos (cliente_id, numero_pedido, data_pedido, status, tipo, valor_total, forma_pagamento, status_pagamento) VALUES
-- Dia 1 (hoje)
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED001', NOW(), 'entregue', 'pronta_entrega', 25.30, 'PIX', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED002', NOW(), 'entregue', 'pronta_entrega', 18.50, 'Dinheiro', 'pago'),

-- Dia 2 (ontem)
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED003', NOW() - INTERVAL '1 day', 'entregue', 'pronta_entrega', 32.80, 'Cartão Crédito', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Ana Costa' LIMIT 1), 'PED004', NOW() - INTERVAL '1 day', 'entregue', 'pronta_entrega', 15.70, 'PIX', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Carlos Souza' LIMIT 1), 'PED005', NOW() - INTERVAL '1 day', 'entregue', 'pronta_entrega', 22.40, 'Cartão Débito', 'pago'),

-- Dia 3 (2 dias atrás)
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED006', NOW() - INTERVAL '2 days', 'entregue', 'pronta_entrega', 41.20, 'PIX', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED007', NOW() - INTERVAL '2 days', 'entregue', 'pronta_entrega', 28.90, 'Dinheiro', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED008', NOW() - INTERVAL '2 days', 'entregue', 'pronta_entrega', 19.60, 'Cartão Crédito', 'pago'),

-- Dia 4 (3 dias atrás)
((SELECT id FROM clientes WHERE nome = 'Ana Costa' LIMIT 1), 'PED009', NOW() - INTERVAL '3 days', 'entregue', 'pronta_entrega', 35.50, 'PIX', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Carlos Souza' LIMIT 1), 'PED010', NOW() - INTERVAL '3 days', 'entregue', 'pronta_entrega', 24.80, 'Cartão Crédito', 'pago'),
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED011', NOW() - INTERVAL '3 days', 'entregue', 'pronta_entrega', 17.30, 'Dinheiro', 'pago'),

-- Dia 5 (4 dias atrás)
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED012', NOW() - INTERVAL '4 days', 'entregue', 'pronta_entrega', 45.60, 'PIX', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED013', NOW() - INTERVAL '4 days', 'entregue', 'pronta_entrega', 33.20, 'Cartão Débito', 'pago'),

-- Dia 6 (5 dias atrás)
((SELECT id FROM clientes WHERE nome = 'Ana Costa' LIMIT 1), 'PED014', NOW() - INTERVAL '5 days', 'entregue', 'pronta_entrega', 52.40, 'PIX', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Carlos Souza' LIMIT 1), 'PED015', NOW() - INTERVAL '5 days', 'entregue', 'pronta_entrega', 29.70, 'Cartão Crédito', 'pago'),
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED016', NOW() - INTERVAL '5 days', 'entregue', 'pronta_entrega', 21.10, 'Dinheiro', 'pago'),

-- Dia 7 (6 dias atrás)
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED017', NOW() - INTERVAL '6 days', 'entregue', 'pronta_entrega', 38.50, 'PIX', 'pago'),
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED018', NOW() - INTERVAL '6 days', 'entregue', 'pronta_entrega', 26.80, 'Cartão Crédito', 'pago')
ON CONFLICT (numero_pedido) DO NOTHING;

-- Inserir itens dos pedidos
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario, preco_unitario_com_desconto, subtotal) VALUES
-- Pedido 1
((SELECT id FROM pedidos WHERE numero_pedido = 'PED001'), (SELECT id FROM produtos WHERE nome = 'Pão Francês'), 10, 0.70, 0.70, 7.00),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED001'), (SELECT id FROM produtos WHERE nome = 'Leite 1L'), 2, 5.80, 5.80, 11.60),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED001'), (SELECT id FROM produtos WHERE nome = 'Açúcar 1kg'), 1, 4.50, 4.50, 4.50),

-- Pedido 2
((SELECT id FROM pedidos WHERE numero_pedido = 'PED002'), (SELECT id FROM produtos WHERE nome = 'Pão Francês'), 15, 0.70, 0.70, 10.50),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED002'), (SELECT id FROM produtos WHERE nome = 'Refrigerante 2L'), 1, 8.90, 8.90, 8.90),

-- Pedido 3
((SELECT id FROM pedidos WHERE numero_pedido = 'PED003'), (SELECT id FROM produtos WHERE nome = 'Café 500g'), 2, 12.90, 12.90, 25.80),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED003'), (SELECT id FROM produtos WHERE nome = 'Pão Francês'), 10, 0.70, 0.70, 7.00),

-- Pedido 4
((SELECT id FROM pedidos WHERE numero_pedido = 'PED004'), (SELECT id FROM produtos WHERE nome = 'Leite 1L'), 2, 5.80, 5.80, 11.60),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED004'), (SELECT id FROM produtos WHERE nome = 'Açúcar 1kg'), 1, 4.50, 4.50, 4.50),

-- Pedido 5
((SELECT id FROM pedidos WHERE numero_pedido = 'PED005'), (SELECT id FROM produtos WHERE nome = 'Pão Francês'), 20, 0.70, 0.70, 14.00),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED005'), (SELECT id FROM produtos WHERE nome = 'Refrigerante 2L'), 1, 8.90, 8.90, 8.90),

-- E assim por diante para os outros pedidos...
((SELECT id FROM pedidos WHERE numero_pedido = 'PED006'), (SELECT id FROM produtos WHERE nome = 'Café 500g'), 3, 12.90, 12.90, 38.70),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED007'), (SELECT id FROM produtos WHERE nome = 'Pão Francês'), 25, 0.70, 0.70, 17.50),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED007'), (SELECT id FROM produtos WHERE nome = 'Leite 1L'), 2, 5.80, 5.80, 11.60),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED008'), (SELECT id FROM produtos WHERE nome = 'Refrigerante 2L'), 2, 8.90, 8.90, 17.80),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED009'), (SELECT id FROM produtos WHERE nome = 'Café 500g'), 2, 12.90, 12.90, 25.80),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED009'), (SELECT id FROM produtos WHERE nome = 'Pão Francês'), 15, 0.70, 0.70, 10.50)
ON CONFLICT DO NOTHING;

-- Inserir entregas de exemplo
INSERT INTO entregas (pedido_id, status, endereco_entrega_rua, endereco_entrega_bairro, endereco_entrega_cidade, data_criacao) VALUES
-- Entregas recentes (últimos 30 dias)
((SELECT id FROM pedidos WHERE numero_pedido = 'PED001'), 'entregue', 'Rua A, 123', 'Centro', 'São Paulo', NOW()),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED002'), 'entregue', 'Rua B, 456', 'Jardim', 'São Paulo', NOW() - INTERVAL '1 day'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED003'), 'entregue', 'Rua C, 789', 'Vila Nova', 'São Paulo', NOW() - INTERVAL '1 day'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED004'), 'entregue', 'Rua D, 101', 'Centro', 'São Paulo', NOW() - INTERVAL '1 day'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED005'), 'entregue', 'Rua E, 202', 'Jardim', 'São Paulo', NOW() - INTERVAL '1 day'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED006'), 'entregue', 'Rua F, 303', 'Centro', 'São Paulo', NOW() - INTERVAL '2 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED007'), 'entregue', 'Rua G, 404', 'Jardim', 'São Paulo', NOW() - INTERVAL '2 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED008'), 'entregue', 'Rua H, 505', 'Vila Nova', 'São Paulo', NOW() - INTERVAL '2 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED009'), 'entregue', 'Rua I, 606', 'Centro', 'São Paulo', NOW() - INTERVAL '3 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED010'), 'entregue', 'Rua J, 707', 'Jardim', 'São Paulo', NOW() - INTERVAL '3 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED011'), 'entregue', 'Rua K, 808', 'Vila Nova', 'São Paulo', NOW() - INTERVAL '3 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED012'), 'entregue', 'Rua L, 909', 'Centro', 'São Paulo', NOW() - INTERVAL '4 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED013'), 'entregue', 'Rua M, 1010', 'Jardim', 'São Paulo', NOW() - INTERVAL '4 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED014'), 'entregue', 'Rua N, 1111', 'Vila Nova', 'São Paulo', NOW() - INTERVAL '5 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED015'), 'entregue', 'Rua O, 1212', 'Centro', 'São Paulo', NOW() - INTERVAL '5 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED016'), 'entregue', 'Rua P, 1313', 'Jardim', 'São Paulo', NOW() - INTERVAL '5 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED017'), 'entregue', 'Rua Q, 1414', 'Vila Nova', 'São Paulo', NOW() - INTERVAL '6 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED018'), 'entregue', 'Rua R, 1515', 'Centro', 'São Paulo', NOW() - INTERVAL '6 days'),

-- Entregas adicionais para criar mais volume de dados por bairro
((SELECT id FROM pedidos WHERE numero_pedido = 'PED001'), 'entregue', 'Rua S, 1616', 'Centro', 'São Paulo', NOW() - INTERVAL '7 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED002'), 'entregue', 'Rua T, 1717', 'Centro', 'São Paulo', NOW() - INTERVAL '8 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED003'), 'entregue', 'Rua U, 1818', 'Jardim', 'São Paulo', NOW() - INTERVAL '9 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED004'), 'entregue', 'Rua V, 1919', 'Jardim', 'São Paulo', NOW() - INTERVAL '10 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED005'), 'entregue', 'Rua W, 2020', 'Vila Nova', 'São Paulo', NOW() - INTERVAL '11 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED006'), 'entregue', 'Rua X, 2121', 'Outros', 'São Paulo', NOW() - INTERVAL '12 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED007'), 'entregue', 'Rua Y, 2222', 'Outros', 'São Paulo', NOW() - INTERVAL '13 days'),
((SELECT id FROM pedidos WHERE numero_pedido = 'PED008'), 'entregue', 'Rua Z, 2323', 'Outros', 'São Paulo', NOW() - INTERVAL '14 days')
ON CONFLICT DO NOTHING; 