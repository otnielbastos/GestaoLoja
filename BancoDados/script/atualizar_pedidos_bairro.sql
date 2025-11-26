-- Script para adicionar campos de endereço aos pedidos e popular com dados de bairro

-- 1. Adicionar colunas de endereço à tabela pedidos (se não existirem)
ALTER TABLE pedidos 
ADD COLUMN IF NOT EXISTS endereco_entrega_bairro TEXT,
ADD COLUMN IF NOT EXISTS endereco_entrega_cidade TEXT,
ADD COLUMN IF NOT EXISTS endereco_entrega_rua TEXT;

-- 2. Atualizar pedidos existentes com bairros aleatórios
UPDATE pedidos SET 
  endereco_entrega_bairro = CASE 
    WHEN id % 4 = 0 THEN 'Centro'
    WHEN id % 4 = 1 THEN 'Jardim'
    WHEN id % 4 = 2 THEN 'Vila Nova'
    ELSE 'Outros'
  END,
  endereco_entrega_cidade = 'São Paulo'
WHERE endereco_entrega_bairro IS NULL;

-- 3. Inserir pedidos adicionais com bairros específicos para os últimos 30 dias
INSERT INTO pedidos (cliente_id, numero_pedido, data_pedido, status, tipo, valor_total, forma_pagamento, status_pagamento, endereco_entrega_bairro, endereco_entrega_cidade) VALUES
-- Pedidos do Centro (40% do total)
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED_CENTRO_01', NOW() - INTERVAL '1 day', 'entregue', 'pronta_entrega', 35.50, 'PIX', 'pago', 'Centro', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Ana Costa' LIMIT 1), 'PED_CENTRO_02', NOW() - INTERVAL '2 days', 'entregue', 'pronta_entrega', 42.30, 'Cartão Crédito', 'pago', 'Centro', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED_CENTRO_03', NOW() - INTERVAL '3 days', 'entregue', 'pronta_entrega', 28.90, 'PIX', 'pago', 'Centro', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Ana Costa' LIMIT 1), 'PED_CENTRO_04', NOW() - INTERVAL '5 days', 'entregue', 'pronta_entrega', 51.20, 'Dinheiro', 'pago', 'Centro', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED_CENTRO_05', NOW() - INTERVAL '7 days', 'entregue', 'pronta_entrega', 33.70, 'PIX', 'pago', 'Centro', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Ana Costa' LIMIT 1), 'PED_CENTRO_06', NOW() - INTERVAL '10 days', 'entregue', 'pronta_entrega', 47.80, 'Cartão Débito', 'pago', 'Centro', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED_CENTRO_07', NOW() - INTERVAL '12 days', 'entregue', 'pronta_entrega', 39.40, 'PIX', 'pago', 'Centro', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Ana Costa' LIMIT 1), 'PED_CENTRO_08', NOW() - INTERVAL '15 days', 'entregue', 'pronta_entrega', 44.60, 'Cartão Crédito', 'pago', 'Centro', 'São Paulo'),

-- Pedidos do Jardim (25% do total)
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED_JARDIM_01', NOW() - INTERVAL '1 day', 'entregue', 'pronta_entrega', 26.80, 'Cartão Crédito', 'pago', 'Jardim', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Carlos Souza' LIMIT 1), 'PED_JARDIM_02', NOW() - INTERVAL '3 days', 'entregue', 'pronta_entrega', 38.50, 'PIX', 'pago', 'Jardim', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED_JARDIM_03', NOW() - INTERVAL '6 days', 'entregue', 'pronta_entrega', 31.20, 'Dinheiro', 'pago', 'Jardim', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Carlos Souza' LIMIT 1), 'PED_JARDIM_04', NOW() - INTERVAL '9 days', 'entregue', 'pronta_entrega', 45.70, 'PIX', 'pago', 'Jardim', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED_JARDIM_05', NOW() - INTERVAL '14 days', 'entregue', 'pronta_entrega', 29.90, 'Cartão Débito', 'pago', 'Jardim', 'São Paulo'),

-- Pedidos da Vila Nova (18% do total)
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED_VILA_01', NOW() - INTERVAL '2 days', 'entregue', 'pronta_entrega', 34.20, 'PIX', 'pago', 'Vila Nova', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED_VILA_02', NOW() - INTERVAL '5 days', 'entregue', 'pronta_entrega', 41.80, 'Cartão Crédito', 'pago', 'Vila Nova', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED_VILA_03', NOW() - INTERVAL '11 days', 'entregue', 'pronta_entrega', 27.60, 'Dinheiro', 'pago', 'Vila Nova', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED_VILA_04', NOW() - INTERVAL '16 days', 'entregue', 'pronta_entrega', 36.40, 'PIX', 'pago', 'Vila Nova', 'São Paulo'),

-- Pedidos de Outros bairros (17% do total)
((SELECT id FROM clientes WHERE nome = 'João Silva' LIMIT 1), 'PED_OUTROS_01', NOW() - INTERVAL '4 days', 'entregue', 'pronta_entrega', 32.10, 'Cartão Débito', 'pago', 'Outros', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Maria Santos' LIMIT 1), 'PED_OUTROS_02', NOW() - INTERVAL '8 days', 'entregue', 'pronta_entrega', 48.30, 'PIX', 'pago', 'Outros', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Pedro Oliveira' LIMIT 1), 'PED_OUTROS_03', NOW() - INTERVAL '13 days', 'entregue', 'pronta_entrega', 25.70, 'Dinheiro', 'pago', 'Outros', 'São Paulo'),
((SELECT id FROM clientes WHERE nome = 'Carlos Souza' LIMIT 1), 'PED_OUTROS_04', NOW() - INTERVAL '18 days', 'entregue', 'pronta_entrega', 37.90, 'Cartão Crédito', 'pago', 'Outros', 'São Paulo')
ON CONFLICT (numero_pedido) DO NOTHING;

-- 4. Verificar os dados inseridos
SELECT 
  endereco_entrega_bairro,
  COUNT(*) as total_pedidos,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM pedidos WHERE endereco_entrega_bairro IS NOT NULL), 1) as percentual,
  MIN(data_pedido) as primeiro_pedido,
  MAX(data_pedido) as ultimo_pedido
FROM pedidos 
WHERE endereco_entrega_bairro IS NOT NULL
  AND data_pedido >= NOW() - INTERVAL '30 days'
GROUP BY endereco_entrega_bairro
ORDER BY total_pedidos DESC;

-- 5. Mostrar alguns exemplos dos pedidos criados
SELECT 
  numero_pedido,
  endereco_entrega_bairro,
  valor_total,
  forma_pagamento,
  data_pedido
FROM pedidos 
WHERE endereco_entrega_bairro IS NOT NULL
  AND data_pedido >= NOW() - INTERVAL '30 days'
ORDER BY data_pedido DESC
LIMIT 10; 