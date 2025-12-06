-- Migration para configurar timezone de Brasília (America/Sao_Paulo)
-- Todas as datas serão gravadas no horário de Brasília (UTC-3)
-- 
-- IMPORTANTE: O PostgreSQL armazena timestamps em UTC internamente.
-- As funções abaixo garantem que os timestamps sejam interpretados e
-- retornados no horário de Brasília.

-- Função para retornar o horário atual convertido para Brasília
-- Retorna um TIMESTAMP WITH TIME ZONE que representa o horário atual de Brasília
CREATE OR REPLACE FUNCTION now_brasilia()
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    -- NOW() retorna UTC, então convertemos para o timezone de Brasília
    -- e depois convertemos de volta para TIMESTAMP WITH TIME ZONE
    RETURN (NOW() AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo';
END;
$$ LANGUAGE plpgsql;

-- Função para converter timestamp para horário de Brasília
CREATE OR REPLACE FUNCTION to_brasilia(timestamp_value TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    RETURN (timestamp_value AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo';
END;
$$ LANGUAGE plpgsql;

-- Atualizar função de atualização de timestamp para usar horário de Brasília
-- Esta função garante que data_atualizacao seja sempre no horário de Brasília
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    -- Usar NOW() que já está em UTC, mas garantir que seja interpretado como Brasília
    -- O PostgreSQL armazenará em UTC, mas quando consultado, será exibido no timezone correto
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Atualizar função de atualização de timestamp de estoque
CREATE OR REPLACE FUNCTION update_estoque_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    -- Usar NOW() que já está em UTC
    NEW.ultima_atualizacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Comentário explicativo
COMMENT ON FUNCTION now_brasilia() IS 'Retorna o horário atual convertido para o fuso horário de Brasília (America/Sao_Paulo)';
COMMENT ON FUNCTION to_brasilia(TIMESTAMP WITH TIME ZONE) IS 'Converte um timestamp para o fuso horário de Brasília (America/Sao_Paulo)';

