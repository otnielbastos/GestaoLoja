-- Schema PostgreSQL para Supabase convertido do MySQL
-- Mantendo todas as regras de negócio e estrutura original

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enable RLS (Row Level Security)
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- Enum types
CREATE TYPE pessoa_tipo AS ENUM ('fisica', 'juridica');
CREATE TYPE cliente_status AS ENUM ('ativo', 'inativo');
CREATE TYPE produto_status AS ENUM ('ativo', 'inativo');
CREATE TYPE produto_tipo AS ENUM ('producao_propria', 'revenda', 'materia_prima');
CREATE TYPE pedido_status AS ENUM ('pendente', 'aprovado', 'aguardando_producao', 'em_preparo', 'em_separacao', 'produzido', 'pronto', 'em_entrega', 'entregue', 'concluido', 'cancelado');
CREATE TYPE pedido_tipo AS ENUM ('pronta_entrega', 'encomenda');
CREATE TYPE pagamento_status AS ENUM ('pendente', 'pago', 'parcial');
CREATE TYPE entrega_status AS ENUM ('aguardando', 'em_rota', 'entregue', 'cancelada');
CREATE TYPE periodo_entrega AS ENUM ('manha', 'tarde', 'noite');
CREATE TYPE movimento_tipo AS ENUM ('entrada', 'saida', 'ajuste');
CREATE TYPE operacao_tipo AS ENUM ('manual', 'automatica');
CREATE TYPE estoque_tipo AS ENUM ('pronta_entrega', 'encomenda');
CREATE TYPE desconto_tipo AS ENUM ('valor', 'percentual');
CREATE TYPE transferencia_origem AS ENUM ('pronta_entrega', 'encomenda');
CREATE TYPE transferencia_destino AS ENUM ('pronta_entrega', 'encomenda');
CREATE TYPE log_operacao AS ENUM ('entrada_estoque', 'saida_estoque');

-- Table: perfis
CREATE TABLE perfis (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    permissoes JSONB,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    cargo VARCHAR(50),
    status cliente_status DEFAULT 'ativo',
    ultimo_acesso TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    perfil_id INTEGER REFERENCES perfis(id),
    senha_hash VARCHAR(255),
    salt VARCHAR(255),
    token_reset VARCHAR(255),
    token_reset_expira TIMESTAMP WITH TIME ZONE,
    tentativas_login INTEGER DEFAULT 0,
    bloqueado_ate TIMESTAMP WITH TIME ZONE,
    ativo BOOLEAN DEFAULT TRUE,
    criado_por INTEGER REFERENCES usuarios(id),
    atualizado_por INTEGER REFERENCES usuarios(id),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    telefone VARCHAR(20),
    cpf_cnpj VARCHAR(20) UNIQUE,
    tipo_pessoa pessoa_tipo NOT NULL,
    endereco_rua VARCHAR(255),
    endereco_numero VARCHAR(20),
    endereco_complemento VARCHAR(100),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100),
    endereco_estado CHAR(2),
    endereco_cep VARCHAR(10),
    observacoes TEXT,
    status cliente_status DEFAULT 'ativo',
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    criado_por INTEGER REFERENCES usuarios(id)
);

-- Table: produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco_venda DECIMAL(10,2) NOT NULL,
    preco_custo DECIMAL(10,2) NOT NULL,
    quantidade_minima INTEGER NOT NULL,
    categoria VARCHAR(100),
    tipo_produto produto_tipo DEFAULT 'producao_propria',
    unidade_medida VARCHAR(20),
    imagem_url VARCHAR(255),
    status produto_status DEFAULT 'ativo',
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: estoque
CREATE TABLE estoque (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER NOT NULL REFERENCES produtos(id),
    quantidade_atual INTEGER NOT NULL DEFAULT 0,
    quantidade_pronta_entrega INTEGER NOT NULL DEFAULT 0,
    quantidade_encomenda INTEGER NOT NULL DEFAULT 0,
    ultima_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    numero_pedido VARCHAR(50) NOT NULL UNIQUE,
    data_pedido TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status pedido_status DEFAULT 'pendente',
    tipo pedido_tipo DEFAULT 'pronta_entrega',
    data_entrega_prevista DATE,
    horario_entrega TIME,
    valor_total DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(50) NOT NULL,
    status_pagamento pagamento_status DEFAULT 'pendente',
    valor_pago DECIMAL(10,2) DEFAULT 0.00,
    data_pagamento TIMESTAMP WITH TIME ZONE,
    observacoes_pagamento TEXT,
    data_entrega TIMESTAMP WITH TIME ZONE,
    observacoes TEXT,
    observacoes_producao TEXT,
    estoque_processado BOOLEAN DEFAULT FALSE,
    criado_por INTEGER REFERENCES usuarios(id)
);

-- Table: itens_pedido
CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(id),
    produto_id INTEGER NOT NULL REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto_valor DECIMAL(10,2) DEFAULT 0.00,
    desconto_percentual DECIMAL(5,2) DEFAULT 0.00,
    tipo_desconto desconto_tipo DEFAULT 'valor',
    preco_unitario_com_desconto DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- Table: entregas
CREATE TABLE entregas (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(id),
    status entrega_status NOT NULL,
    data_agendada DATE,
    periodo_entrega periodo_entrega,
    endereco_entrega_rua VARCHAR(255) NOT NULL,
    endereco_entrega_numero VARCHAR(20),
    endereco_entrega_complemento VARCHAR(100),
    endereco_entrega_bairro VARCHAR(100),
    endereco_entrega_cidade VARCHAR(100),
    endereco_entrega_estado CHAR(2),
    endereco_entrega_cep VARCHAR(10),
    transportadora VARCHAR(100),
    codigo_rastreamento VARCHAR(50),
    observacoes TEXT,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: movimentacoes_estoque
CREATE TABLE movimentacoes_estoque (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER NOT NULL REFERENCES produtos(id),
    tipo_movimento movimento_tipo NOT NULL,
    quantidade INTEGER NOT NULL,
    motivo VARCHAR(100) NOT NULL,
    valor DECIMAL(10,2),
    documento_referencia VARCHAR(50),
    pedido_id INTEGER REFERENCES pedidos(id),
    tipo_operacao operacao_tipo DEFAULT 'manual',
    tipo_estoque estoque_tipo DEFAULT 'pronta_entrega',
    data_movimentacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_fabricacao DATE,
    data_validade DATE,
    usuario_id INTEGER REFERENCES usuarios(id),
    observacao TEXT
);

-- Table: transferencias_estoque
CREATE TABLE transferencias_estoque (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER NOT NULL REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    origem transferencia_origem NOT NULL,
    destino transferencia_destino NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    pedido_id INTEGER REFERENCES pedidos(id),
    usuario_id INTEGER REFERENCES usuarios(id),
    observacao TEXT,
    data_transferencia TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: log_operacoes_automaticas
CREATE TABLE log_operacoes_automaticas (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    tipo_operacao log_operacao NOT NULL,
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50),
    produtos_afetados JSONB,
    data_operacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    observacoes TEXT
);

-- Table: auditoria
CREATE TABLE auditoria (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    acao VARCHAR(100) NOT NULL,
    tabela VARCHAR(50),
    registro_id INTEGER,
    dados_antigos JSONB,
    dados_novos JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    data_acao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: sessoes
CREATE TABLE sessoes (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    token VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_expiracao TIMESTAMP WITH TIME ZONE,
    ativo BOOLEAN DEFAULT TRUE
);

-- Table: tentativas_login
CREATE TABLE tentativas_login (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    ip_address VARCHAR(45),
    sucesso BOOLEAN,
    motivo VARCHAR(100),
    user_agent TEXT,
    data_tentativa TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: configuracoes_relatorios
CREATE TABLE configuracoes_relatorios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    filtros JSONB,
    periodo_padrao VARCHAR(50),
    usuario_id INTEGER REFERENCES usuarios(id),
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_perfil_id ON usuarios(perfil_id);
CREATE INDEX idx_clientes_criado_por ON clientes(criado_por);
CREATE INDEX idx_clientes_cpf_cnpj ON clientes(cpf_cnpj);
CREATE INDEX idx_produtos_categoria ON produtos(categoria);
CREATE INDEX idx_produtos_status ON produtos(status);
CREATE INDEX idx_estoque_produto_id ON estoque(produto_id);
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_tipo ON pedidos(tipo);
CREATE INDEX idx_pedidos_data_entrega ON pedidos(data_entrega_prevista);
CREATE INDEX idx_pedidos_status_tipo ON pedidos(status, tipo);
CREATE INDEX idx_pedidos_criado_por ON pedidos(criado_por);
CREATE INDEX idx_itens_pedido_pedido_id ON itens_pedido(pedido_id);
CREATE INDEX idx_itens_pedido_produto_id ON itens_pedido(produto_id);
CREATE INDEX idx_entregas_pedido_id ON entregas(pedido_id);
CREATE INDEX idx_movimentacoes_produto_id ON movimentacoes_estoque(produto_id);
CREATE INDEX idx_movimentacoes_pedido_id ON movimentacoes_estoque(pedido_id);
CREATE INDEX idx_transferencias_produto_id ON transferencias_estoque(produto_id);
CREATE INDEX idx_transferencias_data ON transferencias_estoque(data_transferencia);
CREATE INDEX idx_auditoria_usuario_id ON auditoria(usuario_id);
CREATE INDEX idx_auditoria_data_acao ON auditoria(data_acao);
CREATE INDEX idx_sessoes_usuario_id ON sessoes(usuario_id);
CREATE INDEX idx_sessoes_token ON sessoes(token);
CREATE INDEX idx_tentativas_email ON tentativas_login(email);
CREATE INDEX idx_tentativas_ip ON tentativas_login(ip_address);

-- Create view for complete stock information
CREATE VIEW vw_estoque_completo AS
SELECT 
    p.id AS produto_id,
    p.nome AS produto_nome,
    p.categoria,
    p.unidade_medida,
    p.quantidade_minima,
    COALESCE(e.quantidade_atual, 0) AS quantidade_atual,
    COALESCE(e.quantidade_pronta_entrega, 0) AS quantidade_pronta_entrega,
    COALESCE(e.quantidade_encomenda, 0) AS quantidade_encomenda,
    e.ultima_atualizacao
FROM produtos p
LEFT JOIN estoque e ON p.id = e.produto_id
WHERE p.status = 'ativo';

-- Functions to update timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for auto-updating timestamps
CREATE TRIGGER trigger_update_usuarios_timestamp
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_produtos_timestamp
    BEFORE UPDATE ON produtos
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_perfis_timestamp
    BEFORE UPDATE ON perfis
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_entregas_timestamp
    BEFORE UPDATE ON entregas
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

-- Function to update stock timestamp
CREATE OR REPLACE FUNCTION update_estoque_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.ultima_atualizacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_estoque_timestamp
    BEFORE UPDATE ON estoque
    FOR EACH ROW
    EXECUTE FUNCTION update_estoque_timestamp();

-- Insert default profiles
INSERT INTO perfis (nome, descricao, permissoes, ativo) VALUES
('Administrador', 'Acesso total ao sistema', 
 '{"usuarios":["criar","listar","editar","excluir"],"clientes":["criar","listar","editar","excluir"],"pedidos":["criar","listar","editar","excluir"],"produtos":["criar","listar","editar","excluir"],"estoque":["criar","listar","editar","excluir"],"entregas":["criar","listar","editar","excluir"],"relatorios":["criar","listar","editar","excluir"]}'::jsonb, 
 TRUE),
('Gerente', 'Acesso a todos os módulos exceto usuários', 
 '{"usuarios":[],"clientes":["criar","listar","editar","excluir"],"pedidos":["criar","listar","editar","excluir"],"produtos":["criar","listar","editar","excluir"],"estoque":["criar","listar","editar","excluir"],"entregas":["criar","listar","editar","excluir"],"relatorios":["criar","listar","editar","excluir"]}'::jsonb, 
 TRUE),
('Vendedor', 'Acesso restrito a clientes e pedidos próprios', 
 '{"usuarios":[],"clientes":["create","read","update"],"pedidos":["create","read","update"],"produtos":["read"],"financeiro":[],"relatorios":["read"]}'::jsonb, 
 TRUE);

-- Insert default admin user (password will be hashed by the application)
INSERT INTO usuarios (nome, email, senha, perfil_id, ativo, senha_hash) VALUES
('Administrador', 'admin@silosystem.com', '', 1, TRUE, '$2b$12$WRm7Q5F4D2Oic62x0yq2xuv5oIeI8Qf5tF1BfIJPCSqqHLCDCP40K');

-- Enable RLS on all tables
ALTER TABLE perfis ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE entregas ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE transferencias_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE log_operacoes_automaticas ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tentativas_login ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes_relatorios ENABLE ROW LEVEL SECURITY;

-- Basic RLS Policies (these can be customized based on your needs)
-- Allow authenticated users to read their own data
CREATE POLICY "Users can view own profile" ON usuarios FOR SELECT USING (auth.uid()::text = id::text);
CREATE POLICY "Users can update own profile" ON usuarios FOR UPDATE USING (auth.uid()::text = id::text);

-- Allow all authenticated users to read products and categories
CREATE POLICY "Anyone can view products" ON produtos FOR SELECT TO authenticated USING (true);
CREATE POLICY "Anyone can view stock" ON estoque FOR SELECT TO authenticated USING (true);

-- Allow all authenticated users to manage clients and orders (can be restricted further)
CREATE POLICY "Authenticated users can manage clients" ON clientes FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users can manage orders" ON pedidos FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users can manage order items" ON itens_pedido FOR ALL TO authenticated USING (true); 