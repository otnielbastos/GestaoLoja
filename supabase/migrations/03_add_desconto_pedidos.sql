-- Migration: Adicionar campos de desconto na tabela pedidos
-- Data: 2025-01-XX
-- Descrição: Adiciona suporte a descontos em valor ou percentual nos pedidos
-- IMPORTANTE: valor_total permanece inalterado (valor original). O desconto é registrado separadamente.

-- Adicionar campos de desconto na tabela pedidos
ALTER TABLE pedidos
ADD COLUMN IF NOT EXISTS valor_desconto DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS percentual_desconto DECIMAL(5,2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS tipo_desconto VARCHAR(20) DEFAULT NULL;

-- Comentários para documentação
COMMENT ON COLUMN pedidos.valor_desconto IS 'Valor do desconto em R$ (usado quando tipo_desconto = ''valor'')';
COMMENT ON COLUMN pedidos.percentual_desconto IS 'Percentual do desconto aplicado sobre valor_total (usado quando tipo_desconto = ''percentual'')';
COMMENT ON COLUMN pedidos.tipo_desconto IS 'Tipo de desconto: ''valor'' ou ''percentual''';
-- NOTA: valor_total permanece como valor original (não é alterado quando desconto é aplicado)

-- Criar índice para consultas por desconto
CREATE INDEX IF NOT EXISTS idx_pedidos_tipo_desconto ON pedidos(tipo_desconto);

