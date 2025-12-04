

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."cliente_status" AS ENUM (
    'ativo',
    'inativo'
);


ALTER TYPE "public"."cliente_status" OWNER TO "postgres";


CREATE TYPE "public"."desconto_tipo" AS ENUM (
    'valor',
    'percentual'
);


ALTER TYPE "public"."desconto_tipo" OWNER TO "postgres";


CREATE TYPE "public"."entrega_status" AS ENUM (
    'aguardando',
    'em_rota',
    'entregue',
    'cancelada'
);


ALTER TYPE "public"."entrega_status" OWNER TO "postgres";


CREATE TYPE "public"."estoque_tipo" AS ENUM (
    'pronta_entrega',
    'encomenda'
);


ALTER TYPE "public"."estoque_tipo" OWNER TO "postgres";


CREATE TYPE "public"."log_operacao" AS ENUM (
    'entrada_estoque',
    'saida_estoque'
);


ALTER TYPE "public"."log_operacao" OWNER TO "postgres";


CREATE TYPE "public"."movimento_tipo" AS ENUM (
    'entrada',
    'saida',
    'ajuste'
);


ALTER TYPE "public"."movimento_tipo" OWNER TO "postgres";


CREATE TYPE "public"."operacao_tipo" AS ENUM (
    'manual',
    'automatica'
);


ALTER TYPE "public"."operacao_tipo" OWNER TO "postgres";


CREATE TYPE "public"."pagamento_status" AS ENUM (
    'pendente',
    'pago',
    'parcial'
);


ALTER TYPE "public"."pagamento_status" OWNER TO "postgres";


CREATE TYPE "public"."pedido_status" AS ENUM (
    'pendente',
    'aprovado',
    'aguardando_producao',
    'em_preparo',
    'em_separacao',
    'produzido',
    'pronto',
    'em_entrega',
    'entregue',
    'concluido',
    'cancelado'
);


ALTER TYPE "public"."pedido_status" OWNER TO "postgres";


CREATE TYPE "public"."pedido_tipo" AS ENUM (
    'pronta_entrega',
    'encomenda'
);


ALTER TYPE "public"."pedido_tipo" OWNER TO "postgres";


CREATE TYPE "public"."periodo_entrega" AS ENUM (
    'manha',
    'tarde',
    'noite'
);


ALTER TYPE "public"."periodo_entrega" OWNER TO "postgres";


CREATE TYPE "public"."pessoa_tipo" AS ENUM (
    'fisica',
    'juridica'
);


ALTER TYPE "public"."pessoa_tipo" OWNER TO "postgres";


CREATE TYPE "public"."produto_status" AS ENUM (
    'ativo',
    'inativo'
);


ALTER TYPE "public"."produto_status" OWNER TO "postgres";


CREATE TYPE "public"."produto_tipo" AS ENUM (
    'producao_propria',
    'revenda',
    'materia_prima'
);


ALTER TYPE "public"."produto_tipo" OWNER TO "postgres";


CREATE TYPE "public"."transferencia_destino" AS ENUM (
    'pronta_entrega',
    'encomenda'
);


ALTER TYPE "public"."transferencia_destino" OWNER TO "postgres";


CREATE TYPE "public"."transferencia_origem" AS ENUM (
    'pronta_entrega',
    'encomenda'
);


ALTER TYPE "public"."transferencia_origem" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_estoque_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.ultima_atualizacao = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_estoque_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_timestamp"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."auditoria" (
    "id" integer NOT NULL,
    "usuario_id" integer,
    "acao" character varying(100) NOT NULL,
    "tabela" character varying(50),
    "registro_id" integer,
    "dados_antigos" "jsonb",
    "dados_novos" "jsonb",
    "ip_address" character varying(45),
    "user_agent" "text",
    "data_acao" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."auditoria" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."auditoria_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."auditoria_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."auditoria_id_seq" OWNED BY "public"."auditoria"."id";



CREATE TABLE IF NOT EXISTS "public"."clientes" (
    "id" integer NOT NULL,
    "nome" character varying(255) NOT NULL,
    "email" character varying(255),
    "telefone" character varying(20),
    "cpf_cnpj" character varying(20),
    "tipo_pessoa" "public"."pessoa_tipo" NOT NULL,
    "endereco_rua" character varying(255),
    "endereco_numero" character varying(20),
    "endereco_complemento" character varying(100),
    "endereco_bairro" character varying(100),
    "endereco_cidade" character varying(100),
    "endereco_estado" character(2),
    "endereco_cep" character varying(10),
    "observacoes" "text",
    "status" "public"."cliente_status" DEFAULT 'ativo'::"public"."cliente_status",
    "data_cadastro" timestamp with time zone DEFAULT "now"(),
    "criado_por" integer
);


ALTER TABLE "public"."clientes" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."clientes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."clientes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."clientes_id_seq" OWNED BY "public"."clientes"."id";



CREATE TABLE IF NOT EXISTS "public"."configuracoes_relatorios" (
    "id" integer NOT NULL,
    "nome" character varying(100) NOT NULL,
    "tipo" character varying(50) NOT NULL,
    "filtros" "jsonb",
    "periodo_padrao" character varying(50),
    "usuario_id" integer,
    "data_criacao" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."configuracoes_relatorios" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."configuracoes_relatorios_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."configuracoes_relatorios_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."configuracoes_relatorios_id_seq" OWNED BY "public"."configuracoes_relatorios"."id";



CREATE TABLE IF NOT EXISTS "public"."entregas" (
    "id" integer NOT NULL,
    "pedido_id" integer NOT NULL,
    "status" "public"."entrega_status" NOT NULL,
    "data_agendada" "date",
    "periodo_entrega" "public"."periodo_entrega",
    "endereco_entrega_rua" character varying(255) NOT NULL,
    "endereco_entrega_numero" character varying(20),
    "endereco_entrega_complemento" character varying(100),
    "endereco_entrega_bairro" character varying(100),
    "endereco_entrega_cidade" character varying(100),
    "endereco_entrega_estado" character(2),
    "endereco_entrega_cep" character varying(10),
    "transportadora" character varying(100),
    "codigo_rastreamento" character varying(50),
    "observacoes" "text",
    "data_criacao" timestamp with time zone DEFAULT "now"(),
    "data_atualizacao" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."entregas" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."entregas_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."entregas_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."entregas_id_seq" OWNED BY "public"."entregas"."id";



CREATE TABLE IF NOT EXISTS "public"."estoque" (
    "id" integer NOT NULL,
    "produto_id" integer NOT NULL,
    "quantidade_atual" integer DEFAULT 0 NOT NULL,
    "quantidade_pronta_entrega" integer DEFAULT 0 NOT NULL,
    "quantidade_encomenda" integer DEFAULT 0 NOT NULL,
    "ultima_atualizacao" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."estoque" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."estoque_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."estoque_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."estoque_id_seq" OWNED BY "public"."estoque"."id";



CREATE TABLE IF NOT EXISTS "public"."itens_pedido" (
    "id" integer NOT NULL,
    "pedido_id" integer NOT NULL,
    "produto_id" integer NOT NULL,
    "quantidade" integer NOT NULL,
    "preco_unitario" numeric(10,2) NOT NULL,
    "desconto_valor" numeric(10,2) DEFAULT 0.00,
    "desconto_percentual" numeric(5,2) DEFAULT 0.00,
    "tipo_desconto" "public"."desconto_tipo" DEFAULT 'valor'::"public"."desconto_tipo",
    "preco_unitario_com_desconto" numeric(10,2) NOT NULL,
    "subtotal" numeric(10,2) NOT NULL
);


ALTER TABLE "public"."itens_pedido" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."itens_pedido_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."itens_pedido_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."itens_pedido_id_seq" OWNED BY "public"."itens_pedido"."id";



CREATE TABLE IF NOT EXISTS "public"."log_operacoes_automaticas" (
    "id" integer NOT NULL,
    "pedido_id" integer NOT NULL,
    "tipo_operacao" "public"."log_operacao" NOT NULL,
    "status_anterior" character varying(50),
    "status_novo" character varying(50),
    "produtos_afetados" "jsonb",
    "data_operacao" timestamp with time zone DEFAULT "now"(),
    "observacoes" "text"
);


ALTER TABLE "public"."log_operacoes_automaticas" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."log_operacoes_automaticas_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."log_operacoes_automaticas_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."log_operacoes_automaticas_id_seq" OWNED BY "public"."log_operacoes_automaticas"."id";



CREATE TABLE IF NOT EXISTS "public"."movimentacoes_estoque" (
    "id" integer NOT NULL,
    "produto_id" integer NOT NULL,
    "tipo_movimento" "public"."movimento_tipo" NOT NULL,
    "quantidade" integer NOT NULL,
    "motivo" character varying(100) NOT NULL,
    "valor" numeric(10,2),
    "documento_referencia" character varying(50),
    "pedido_id" integer,
    "tipo_operacao" "public"."operacao_tipo" DEFAULT 'manual'::"public"."operacao_tipo",
    "tipo_estoque" "public"."estoque_tipo" DEFAULT 'pronta_entrega'::"public"."estoque_tipo",
    "data_movimentacao" timestamp with time zone DEFAULT "now"(),
    "data_fabricacao" "date",
    "data_validade" "date",
    "usuario_id" integer,
    "observacao" "text"
);


ALTER TABLE "public"."movimentacoes_estoque" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."movimentacoes_estoque_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."movimentacoes_estoque_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."movimentacoes_estoque_id_seq" OWNED BY "public"."movimentacoes_estoque"."id";



CREATE TABLE IF NOT EXISTS "public"."pedidos" (
    "id" integer NOT NULL,
    "cliente_id" integer NOT NULL,
    "numero_pedido" character varying(50) NOT NULL,
    "data_pedido" timestamp with time zone DEFAULT "now"(),
    "status" "public"."pedido_status" DEFAULT 'pendente'::"public"."pedido_status",
    "tipo" "public"."pedido_tipo" DEFAULT 'pronta_entrega'::"public"."pedido_tipo",
    "data_entrega_prevista" "date",
    "horario_entrega" time without time zone,
    "valor_total" numeric(10,2) NOT NULL,
    "forma_pagamento" character varying(50) NOT NULL,
    "status_pagamento" "public"."pagamento_status" DEFAULT 'pendente'::"public"."pagamento_status",
    "valor_pago" numeric(10,2) DEFAULT 0.00,
    "data_pagamento" timestamp with time zone,
    "observacoes_pagamento" "text",
    "data_entrega" timestamp with time zone,
    "observacoes" "text",
    "observacoes_producao" "text",
    "estoque_processado" boolean DEFAULT false,
    "criado_por" integer
);


ALTER TABLE "public"."pedidos" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pedidos_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pedidos_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pedidos_id_seq" OWNED BY "public"."pedidos"."id";



CREATE TABLE IF NOT EXISTS "public"."perfis" (
    "id" integer NOT NULL,
    "nome" character varying(50) NOT NULL,
    "descricao" "text",
    "permissoes" "jsonb",
    "ativo" boolean DEFAULT true,
    "data_criacao" timestamp with time zone DEFAULT "now"(),
    "data_atualizacao" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."perfis" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."perfis_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."perfis_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."perfis_id_seq" OWNED BY "public"."perfis"."id";



CREATE TABLE IF NOT EXISTS "public"."produtos" (
    "id" integer NOT NULL,
    "nome" character varying(255) NOT NULL,
    "descricao" "text",
    "preco_venda" numeric(10,2) NOT NULL,
    "preco_custo" numeric(10,2) NOT NULL,
    "quantidade_minima" integer NOT NULL,
    "categoria" character varying(100),
    "tipo_produto" "public"."produto_tipo" DEFAULT 'producao_propria'::"public"."produto_tipo",
    "unidade_medida" character varying(20),
    "imagem_url" character varying(255),
    "status" "public"."produto_status" DEFAULT 'ativo'::"public"."produto_status",
    "data_criacao" timestamp with time zone DEFAULT "now"(),
    "data_atualizacao" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."produtos" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."produtos_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."produtos_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."produtos_id_seq" OWNED BY "public"."produtos"."id";



CREATE TABLE IF NOT EXISTS "public"."sessoes" (
    "id" integer NOT NULL,
    "usuario_id" integer NOT NULL,
    "token" character varying(255) NOT NULL,
    "ip_address" character varying(45),
    "user_agent" "text",
    "data_criacao" timestamp with time zone DEFAULT "now"(),
    "data_expiracao" timestamp with time zone,
    "ativo" boolean DEFAULT true
);


ALTER TABLE "public"."sessoes" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."sessoes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."sessoes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."sessoes_id_seq" OWNED BY "public"."sessoes"."id";



CREATE TABLE IF NOT EXISTS "public"."tentativas_login" (
    "id" integer NOT NULL,
    "email" character varying(255),
    "ip_address" character varying(45),
    "sucesso" boolean,
    "motivo" character varying(100),
    "user_agent" "text",
    "data_tentativa" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."tentativas_login" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."tentativas_login_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."tentativas_login_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."tentativas_login_id_seq" OWNED BY "public"."tentativas_login"."id";



CREATE TABLE IF NOT EXISTS "public"."transferencias_estoque" (
    "id" integer NOT NULL,
    "produto_id" integer NOT NULL,
    "quantidade" integer NOT NULL,
    "origem" "public"."transferencia_origem" NOT NULL,
    "destino" "public"."transferencia_destino" NOT NULL,
    "motivo" character varying(255) NOT NULL,
    "pedido_id" integer,
    "usuario_id" integer,
    "observacao" "text",
    "data_transferencia" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."transferencias_estoque" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."transferencias_estoque_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."transferencias_estoque_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."transferencias_estoque_id_seq" OWNED BY "public"."transferencias_estoque"."id";



CREATE TABLE IF NOT EXISTS "public"."usuarios" (
    "id" integer NOT NULL,
    "nome" character varying(255) NOT NULL,
    "email" character varying(255) NOT NULL,
    "senha" character varying(255) NOT NULL,
    "cargo" character varying(50),
    "status" "public"."cliente_status" DEFAULT 'ativo'::"public"."cliente_status",
    "ultimo_acesso" timestamp with time zone DEFAULT "now"(),
    "data_criacao" timestamp with time zone DEFAULT "now"(),
    "perfil_id" integer,
    "senha_hash" character varying(255),
    "salt" character varying(255),
    "token_reset" character varying(255),
    "token_reset_expira" timestamp with time zone,
    "tentativas_login" integer DEFAULT 0,
    "bloqueado_ate" timestamp with time zone,
    "ativo" boolean DEFAULT true,
    "criado_por" integer,
    "atualizado_por" integer,
    "data_atualizacao" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."usuarios" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."usuarios_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."usuarios_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."usuarios_id_seq" OWNED BY "public"."usuarios"."id";



CREATE OR REPLACE VIEW "public"."vw_estoque_completo" WITH ("security_invoker"='on') AS
 SELECT "p"."id" AS "produto_id",
    "p"."nome" AS "produto_nome",
    "p"."categoria",
    "p"."unidade_medida",
    "p"."quantidade_minima",
    COALESCE("e"."quantidade_atual", 0) AS "quantidade_atual",
    COALESCE("e"."quantidade_pronta_entrega", 0) AS "quantidade_pronta_entrega",
    COALESCE("e"."quantidade_encomenda", 0) AS "quantidade_encomenda",
    "e"."ultima_atualizacao"
   FROM ("public"."produtos" "p"
     LEFT JOIN "public"."estoque" "e" ON (("p"."id" = "e"."produto_id")))
  WHERE ("p"."status" = 'ativo'::"public"."produto_status");


ALTER VIEW "public"."vw_estoque_completo" OWNER TO "postgres";


ALTER TABLE ONLY "public"."auditoria" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."auditoria_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."clientes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."clientes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."configuracoes_relatorios" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."configuracoes_relatorios_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."entregas" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."entregas_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."estoque" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."estoque_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."itens_pedido" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."itens_pedido_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."log_operacoes_automaticas" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."log_operacoes_automaticas_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."movimentacoes_estoque" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."movimentacoes_estoque_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pedidos" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pedidos_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."perfis" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."perfis_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."produtos" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."produtos_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."sessoes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."sessoes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."tentativas_login" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."tentativas_login_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."transferencias_estoque" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."transferencias_estoque_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."usuarios" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."usuarios_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."auditoria"
    ADD CONSTRAINT "auditoria_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clientes"
    ADD CONSTRAINT "clientes_cpf_cnpj_key" UNIQUE ("cpf_cnpj");



ALTER TABLE ONLY "public"."clientes"
    ADD CONSTRAINT "clientes_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."clientes"
    ADD CONSTRAINT "clientes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."configuracoes_relatorios"
    ADD CONSTRAINT "configuracoes_relatorios_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."entregas"
    ADD CONSTRAINT "entregas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."estoque"
    ADD CONSTRAINT "estoque_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."itens_pedido"
    ADD CONSTRAINT "itens_pedido_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."log_operacoes_automaticas"
    ADD CONSTRAINT "log_operacoes_automaticas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."movimentacoes_estoque"
    ADD CONSTRAINT "movimentacoes_estoque_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pedidos"
    ADD CONSTRAINT "pedidos_numero_pedido_key" UNIQUE ("numero_pedido");



ALTER TABLE ONLY "public"."pedidos"
    ADD CONSTRAINT "pedidos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."perfis"
    ADD CONSTRAINT "perfis_nome_key" UNIQUE ("nome");



ALTER TABLE ONLY "public"."perfis"
    ADD CONSTRAINT "perfis_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sessoes"
    ADD CONSTRAINT "sessoes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sessoes"
    ADD CONSTRAINT "sessoes_token_key" UNIQUE ("token");



ALTER TABLE ONLY "public"."tentativas_login"
    ADD CONSTRAINT "tentativas_login_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transferencias_estoque"
    ADD CONSTRAINT "transferencias_estoque_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."usuarios"
    ADD CONSTRAINT "usuarios_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."usuarios"
    ADD CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_auditoria_data_acao" ON "public"."auditoria" USING "btree" ("data_acao");



CREATE INDEX "idx_auditoria_usuario_id" ON "public"."auditoria" USING "btree" ("usuario_id");



CREATE INDEX "idx_clientes_cpf_cnpj" ON "public"."clientes" USING "btree" ("cpf_cnpj");



CREATE INDEX "idx_clientes_criado_por" ON "public"."clientes" USING "btree" ("criado_por");



CREATE INDEX "idx_entregas_pedido_id" ON "public"."entregas" USING "btree" ("pedido_id");



CREATE INDEX "idx_estoque_produto_id" ON "public"."estoque" USING "btree" ("produto_id");



CREATE INDEX "idx_itens_pedido_pedido_id" ON "public"."itens_pedido" USING "btree" ("pedido_id");



CREATE INDEX "idx_itens_pedido_produto_id" ON "public"."itens_pedido" USING "btree" ("produto_id");



CREATE INDEX "idx_movimentacoes_pedido_id" ON "public"."movimentacoes_estoque" USING "btree" ("pedido_id");



CREATE INDEX "idx_movimentacoes_produto_id" ON "public"."movimentacoes_estoque" USING "btree" ("produto_id");



CREATE INDEX "idx_pedidos_cliente_id" ON "public"."pedidos" USING "btree" ("cliente_id");



CREATE INDEX "idx_pedidos_criado_por" ON "public"."pedidos" USING "btree" ("criado_por");



CREATE INDEX "idx_pedidos_data_entrega" ON "public"."pedidos" USING "btree" ("data_entrega_prevista");



CREATE INDEX "idx_pedidos_status_tipo" ON "public"."pedidos" USING "btree" ("status", "tipo");



CREATE INDEX "idx_pedidos_tipo" ON "public"."pedidos" USING "btree" ("tipo");



CREATE INDEX "idx_produtos_categoria" ON "public"."produtos" USING "btree" ("categoria");



CREATE INDEX "idx_produtos_status" ON "public"."produtos" USING "btree" ("status");



CREATE INDEX "idx_sessoes_token" ON "public"."sessoes" USING "btree" ("token");



CREATE INDEX "idx_sessoes_usuario_id" ON "public"."sessoes" USING "btree" ("usuario_id");



CREATE INDEX "idx_tentativas_email" ON "public"."tentativas_login" USING "btree" ("email");



CREATE INDEX "idx_tentativas_ip" ON "public"."tentativas_login" USING "btree" ("ip_address");



CREATE INDEX "idx_transferencias_data" ON "public"."transferencias_estoque" USING "btree" ("data_transferencia");



CREATE INDEX "idx_transferencias_produto_id" ON "public"."transferencias_estoque" USING "btree" ("produto_id");



CREATE INDEX "idx_usuarios_email" ON "public"."usuarios" USING "btree" ("email");



CREATE INDEX "idx_usuarios_perfil_id" ON "public"."usuarios" USING "btree" ("perfil_id");



CREATE OR REPLACE TRIGGER "trigger_update_entregas_timestamp" BEFORE UPDATE ON "public"."entregas" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp"();



CREATE OR REPLACE TRIGGER "trigger_update_estoque_timestamp" BEFORE UPDATE ON "public"."estoque" FOR EACH ROW EXECUTE FUNCTION "public"."update_estoque_timestamp"();



CREATE OR REPLACE TRIGGER "trigger_update_perfis_timestamp" BEFORE UPDATE ON "public"."perfis" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp"();



CREATE OR REPLACE TRIGGER "trigger_update_produtos_timestamp" BEFORE UPDATE ON "public"."produtos" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp"();



CREATE OR REPLACE TRIGGER "trigger_update_usuarios_timestamp" BEFORE UPDATE ON "public"."usuarios" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp"();



ALTER TABLE ONLY "public"."auditoria"
    ADD CONSTRAINT "auditoria_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."clientes"
    ADD CONSTRAINT "clientes_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."configuracoes_relatorios"
    ADD CONSTRAINT "configuracoes_relatorios_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."entregas"
    ADD CONSTRAINT "entregas_pedido_id_fkey" FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos"("id");



ALTER TABLE ONLY "public"."estoque"
    ADD CONSTRAINT "estoque_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id");



ALTER TABLE ONLY "public"."itens_pedido"
    ADD CONSTRAINT "itens_pedido_pedido_id_fkey" FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos"("id");



ALTER TABLE ONLY "public"."itens_pedido"
    ADD CONSTRAINT "itens_pedido_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id");



ALTER TABLE ONLY "public"."log_operacoes_automaticas"
    ADD CONSTRAINT "log_operacoes_automaticas_pedido_id_fkey" FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."movimentacoes_estoque"
    ADD CONSTRAINT "movimentacoes_estoque_pedido_id_fkey" FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos"("id");



ALTER TABLE ONLY "public"."movimentacoes_estoque"
    ADD CONSTRAINT "movimentacoes_estoque_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id");



ALTER TABLE ONLY "public"."movimentacoes_estoque"
    ADD CONSTRAINT "movimentacoes_estoque_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."pedidos"
    ADD CONSTRAINT "pedidos_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id");



ALTER TABLE ONLY "public"."pedidos"
    ADD CONSTRAINT "pedidos_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."sessoes"
    ADD CONSTRAINT "sessoes_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."transferencias_estoque"
    ADD CONSTRAINT "transferencias_estoque_pedido_id_fkey" FOREIGN KEY ("pedido_id") REFERENCES "public"."pedidos"("id");



ALTER TABLE ONLY "public"."transferencias_estoque"
    ADD CONSTRAINT "transferencias_estoque_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id");



ALTER TABLE ONLY "public"."transferencias_estoque"
    ADD CONSTRAINT "transferencias_estoque_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."usuarios"
    ADD CONSTRAINT "usuarios_atualizado_por_fkey" FOREIGN KEY ("atualizado_por") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."usuarios"
    ADD CONSTRAINT "usuarios_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."usuarios"("id");



ALTER TABLE ONLY "public"."usuarios"
    ADD CONSTRAINT "usuarios_perfil_id_fkey" FOREIGN KEY ("perfil_id") REFERENCES "public"."perfis"("id");



CREATE POLICY "Permitir todas operações em auditoria" ON "public"."auditoria" USING (true);



CREATE POLICY "Permitir todas operações em clientes" ON "public"."clientes" USING (true);



CREATE POLICY "Permitir todas operações em configuracoes_relatorios" ON "public"."configuracoes_relatorios" USING (true);



CREATE POLICY "Permitir todas operações em entregas" ON "public"."entregas" USING (true);



CREATE POLICY "Permitir todas operações em estoque" ON "public"."estoque" USING (true);



CREATE POLICY "Permitir todas operações em itens_pedido" ON "public"."itens_pedido" USING (true);



CREATE POLICY "Permitir todas operações em log_operacoes_automaticas" ON "public"."log_operacoes_automaticas" USING (true);



CREATE POLICY "Permitir todas operações em movimentacoes_estoque" ON "public"."movimentacoes_estoque" USING (true);



CREATE POLICY "Permitir todas operações em pedidos" ON "public"."pedidos" USING (true);



CREATE POLICY "Permitir todas operações em perfis" ON "public"."perfis" USING (true);



CREATE POLICY "Permitir todas operações em produtos" ON "public"."produtos" USING (true);



CREATE POLICY "Permitir todas operações em sessoes" ON "public"."sessoes" USING (true);



CREATE POLICY "Permitir todas operações em tentativas_login" ON "public"."tentativas_login" USING (true);



CREATE POLICY "Permitir todas operações em transferencias_estoque" ON "public"."transferencias_estoque" USING (true);



CREATE POLICY "Permitir todas operações em usuarios" ON "public"."usuarios" USING (true);



ALTER TABLE "public"."auditoria" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."clientes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."configuracoes_relatorios" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."entregas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."estoque" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."itens_pedido" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."log_operacoes_automaticas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."movimentacoes_estoque" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pedidos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."perfis" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."produtos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sessoes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tentativas_login" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transferencias_estoque" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."usuarios" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."update_estoque_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_estoque_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_estoque_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_timestamp"() TO "service_role";


















GRANT ALL ON TABLE "public"."auditoria" TO "anon";
GRANT ALL ON TABLE "public"."auditoria" TO "authenticated";
GRANT ALL ON TABLE "public"."auditoria" TO "service_role";



GRANT ALL ON SEQUENCE "public"."auditoria_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."auditoria_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."auditoria_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."clientes" TO "anon";
GRANT ALL ON TABLE "public"."clientes" TO "authenticated";
GRANT ALL ON TABLE "public"."clientes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."clientes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."clientes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."clientes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."configuracoes_relatorios" TO "anon";
GRANT ALL ON TABLE "public"."configuracoes_relatorios" TO "authenticated";
GRANT ALL ON TABLE "public"."configuracoes_relatorios" TO "service_role";



GRANT ALL ON SEQUENCE "public"."configuracoes_relatorios_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."configuracoes_relatorios_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."configuracoes_relatorios_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."entregas" TO "anon";
GRANT ALL ON TABLE "public"."entregas" TO "authenticated";
GRANT ALL ON TABLE "public"."entregas" TO "service_role";



GRANT ALL ON SEQUENCE "public"."entregas_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."entregas_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."entregas_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."estoque" TO "anon";
GRANT ALL ON TABLE "public"."estoque" TO "authenticated";
GRANT ALL ON TABLE "public"."estoque" TO "service_role";



GRANT ALL ON SEQUENCE "public"."estoque_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."estoque_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."estoque_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."itens_pedido" TO "anon";
GRANT ALL ON TABLE "public"."itens_pedido" TO "authenticated";
GRANT ALL ON TABLE "public"."itens_pedido" TO "service_role";



GRANT ALL ON SEQUENCE "public"."itens_pedido_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."itens_pedido_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."itens_pedido_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."log_operacoes_automaticas" TO "anon";
GRANT ALL ON TABLE "public"."log_operacoes_automaticas" TO "authenticated";
GRANT ALL ON TABLE "public"."log_operacoes_automaticas" TO "service_role";



GRANT ALL ON SEQUENCE "public"."log_operacoes_automaticas_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."log_operacoes_automaticas_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."log_operacoes_automaticas_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."movimentacoes_estoque" TO "anon";
GRANT ALL ON TABLE "public"."movimentacoes_estoque" TO "authenticated";
GRANT ALL ON TABLE "public"."movimentacoes_estoque" TO "service_role";



GRANT ALL ON SEQUENCE "public"."movimentacoes_estoque_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."movimentacoes_estoque_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."movimentacoes_estoque_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."pedidos" TO "anon";
GRANT ALL ON TABLE "public"."pedidos" TO "authenticated";
GRANT ALL ON TABLE "public"."pedidos" TO "service_role";



GRANT ALL ON SEQUENCE "public"."pedidos_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."pedidos_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."pedidos_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."perfis" TO "anon";
GRANT ALL ON TABLE "public"."perfis" TO "authenticated";
GRANT ALL ON TABLE "public"."perfis" TO "service_role";



GRANT ALL ON SEQUENCE "public"."perfis_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."perfis_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."perfis_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."produtos" TO "anon";
GRANT ALL ON TABLE "public"."produtos" TO "authenticated";
GRANT ALL ON TABLE "public"."produtos" TO "service_role";



GRANT ALL ON SEQUENCE "public"."produtos_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."produtos_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."produtos_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."sessoes" TO "anon";
GRANT ALL ON TABLE "public"."sessoes" TO "authenticated";
GRANT ALL ON TABLE "public"."sessoes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."sessoes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."sessoes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."sessoes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."tentativas_login" TO "anon";
GRANT ALL ON TABLE "public"."tentativas_login" TO "authenticated";
GRANT ALL ON TABLE "public"."tentativas_login" TO "service_role";



GRANT ALL ON SEQUENCE "public"."tentativas_login_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."tentativas_login_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."tentativas_login_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."transferencias_estoque" TO "anon";
GRANT ALL ON TABLE "public"."transferencias_estoque" TO "authenticated";
GRANT ALL ON TABLE "public"."transferencias_estoque" TO "service_role";



GRANT ALL ON SEQUENCE "public"."transferencias_estoque_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."transferencias_estoque_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."transferencias_estoque_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."usuarios" TO "anon";
GRANT ALL ON TABLE "public"."usuarios" TO "authenticated";
GRANT ALL ON TABLE "public"."usuarios" TO "service_role";



GRANT ALL ON SEQUENCE "public"."usuarios_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."usuarios_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."usuarios_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."vw_estoque_completo" TO "anon";
GRANT ALL ON TABLE "public"."vw_estoque_completo" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_estoque_completo" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























