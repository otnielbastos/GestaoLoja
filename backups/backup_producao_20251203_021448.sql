

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



CREATE POLICY "Permitir todas operaÃ§Ãµes em auditoria" ON "public"."auditoria" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em clientes" ON "public"."clientes" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em configuracoes_relatorios" ON "public"."configuracoes_relatorios" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em entregas" ON "public"."entregas" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em estoque" ON "public"."estoque" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em itens_pedido" ON "public"."itens_pedido" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em log_operacoes_automaticas" ON "public"."log_operacoes_automaticas" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em movimentacoes_estoque" ON "public"."movimentacoes_estoque" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em pedidos" ON "public"."pedidos" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em perfis" ON "public"."perfis" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em produtos" ON "public"."produtos" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em sessoes" ON "public"."sessoes" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em tentativas_login" ON "public"."tentativas_login" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em transferencias_estoque" ON "public"."transferencias_estoque" USING (true);



CREATE POLICY "Permitir todas operaÃ§Ãµes em usuarios" ON "public"."usuarios" USING (true);



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
































-- ============================================
-- DADOS
-- ============================================

SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: perfis; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."perfis" ("id", "nome", "descricao", "permissoes", "ativo", "data_criacao", "data_atualizacao") VALUES
	(1, 'Administrador', 'Acesso total ao sistema', '{"pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios", "usuarios", "configuracoes"], "actions": {"estoque": ["visualizar", "editar", "exportar"], "pedidos": ["visualizar", "criar", "editar", "excluir", "aprovar", "cancelar", "exportar", "imprimir"], "clientes": ["visualizar", "criar", "editar", "excluir", "exportar"], "entregas": ["visualizar", "editar", "exportar"], "produtos": ["visualizar", "criar", "editar", "excluir", "exportar"], "usuarios": ["visualizar", "criar", "editar", "excluir"], "dashboard": ["visualizar"], "relatorios": ["visualizar", "exportar", "imprimir"], "configuracoes": ["visualizar", "editar"]}}', true, '2025-06-11 04:39:30.346867+00', '2025-06-13 07:26:03.691972+00'),
	(2, 'Gerente', 'Acesso a operaÃ§Ãµes e relatÃ³rios', '{"pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios"], "actions": {"estoque": ["visualizar", "editar", "exportar"], "pedidos": ["visualizar", "criar", "editar", "aprovar", "cancelar", "exportar", "imprimir"], "clientes": ["visualizar", "criar", "editar", "exportar"], "entregas": ["visualizar", "editar", "exportar"], "produtos": ["visualizar", "criar", "editar", "exportar"], "dashboard": ["visualizar"], "relatorios": ["visualizar", "exportar", "imprimir"]}}', true, '2025-06-11 04:39:30.346867+00', '2025-06-13 07:26:03.691972+00'),
	(3, 'Vendedor', 'Acesso a vendas e clientes', '{"pages": ["dashboard", "pedidos", "clientes"], "actions": {"pedidos": ["visualizar", "criar", "editar", "exportar"], "clientes": ["visualizar", "criar", "editar", "exportar"], "dashboard": ["visualizar"]}}', true, '2025-06-11 04:39:30.346867+00', '2025-06-13 07:26:03.691972+00');


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."usuarios" ("id", "nome", "email", "senha", "cargo", "status", "ultimo_acesso", "data_criacao", "perfil_id", "senha_hash", "salt", "token_reset", "token_reset_expira", "tentativas_login", "bloqueado_ate", "ativo", "criado_por", "atualizado_por", "data_atualizacao") VALUES
	(2, 'Otniel Bastos Machado', 'otnielbastos@hotmail.com', '', NULL, 'ativo', '2025-11-26 05:12:27.067+00', '2025-06-13 07:51:21.555077+00', 1, '$2b$12$P1rq0kBmfoBUenUt21SFrOk.qOSQNrSy2qi0KzNwculIQhovZe.EG', NULL, NULL, NULL, 0, NULL, true, 1, NULL, '2025-11-26 05:12:27.182655+00'),
	(3, 'Silvana Lara Machado', 'silvanalm01@hotmail.com', '', NULL, 'ativo', '2025-12-02 00:53:54.988+00', '2025-06-17 01:02:43.684841+00', 1, '$2b$12$G5T4cboWYyZ/YC7lOL61HuW2.paUOX0D7VB6oFsWESQvBTe4Rnxdi', NULL, NULL, NULL, 0, NULL, true, 1, NULL, '2025-12-02 00:53:55.515004+00'),
	(1, 'Administrador', 'admin@silosystem.com', '', NULL, 'ativo', '2025-12-03 02:53:01.922+00', '2025-06-11 04:39:30.346867+00', 1, '$2b$12$MPOzIhlGx1kyyyFpUhE7nec4aDVQQbyBG86Hvlb73XbKw4Ei7kP22', NULL, NULL, NULL, 0, NULL, true, NULL, NULL, '2025-12-03 02:53:02.905642+00');


--
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."auditoria" ("id", "usuario_id", "acao", "tabela", "registro_id", "dados_antigos", "dados_novos", "ip_address", "user_agent", "data_acao") VALUES
	(93, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', '2025-11-01 23:21:55.244926+00'),
	(94, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36', '2025-11-02 15:27:23.796379+00'),
	(95, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', '2025-11-02 17:50:21.911512+00'),
	(96, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-07 14:55:10.910186+00'),
	(97, 3, 'LOGOUT', 'usuarios', 3, NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-07 14:55:19.491175+00'),
	(98, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-07 14:55:43.447475+00'),
	(99, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-08 15:04:36.180709+00'),
	(100, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-12 23:20:16.768568+00'),
	(101, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-13 01:25:21.165211+00'),
	(102, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-13 07:10:35.8591+00'),
	(103, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-13 17:11:49.352294+00'),
	(104, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-13 17:31:09.8663+00'),
	(105, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-14 00:02:07.901831+00'),
	(106, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-15 12:15:51.728534+00'),
	(107, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-15 23:25:03.307267+00'),
	(108, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-16 20:14:17.221192+00'),
	(109, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-16 20:31:17.235698+00'),
	(110, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-16 20:54:12.716702+00'),
	(111, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-16 23:25:07.479816+00'),
	(112, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-16 23:34:58.253656+00'),
	(113, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-16 23:46:40.802631+00'),
	(114, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-17 02:01:09.561638+00'),
	(115, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-17 03:53:06.894923+00'),
	(116, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-17 05:45:21.468786+00'),
	(117, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-17 23:50:39.690669+00'),
	(118, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-18 14:25:47.797768+00'),
	(119, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-18 20:36:26.30694+00'),
	(120, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-19 12:16:37.685534+00'),
	(121, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-19 21:29:11.818049+00'),
	(122, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-20 13:55:16.629402+00'),
	(123, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-22 02:40:38.883597+00'),
	(124, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-25 04:23:15.050623+00'),
	(125, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 02:46:43.743264+00'),
	(126, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-26 04:28:59.029388+00'),
	(127, 1, 'LOGOUT', 'usuarios', 1, NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:09:50.090177+00'),
	(128, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:18.141695+00'),
	(129, 2, 'LOGOUT', 'usuarios', 2, NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:31.85022+00'),
	(130, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:47.075418+00'),
	(131, 2, 'LOGOUT', 'usuarios', 2, NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:11:00.719909+00'),
	(132, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:13.35073+00'),
	(133, 2, 'LOGOUT', 'usuarios', 2, NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:16.710771+00'),
	(134, 2, 'LOGIN', 'usuarios', 2, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:27.321817+00'),
	(135, 2, 'LOGOUT', 'usuarios', 2, NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:30.62381+00'),
	(136, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:34.610783+00'),
	(137, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-29 02:35:29.724731+00'),
	(138, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-01 23:09:36.843963+00'),
	(139, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-12-02 00:31:25.732784+00'),
	(140, 3, 'LOGIN', 'usuarios', 3, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-12-02 00:53:56.013761+00'),
	(141, 1, 'LOGIN', 'usuarios', 1, NULL, '{"ip": "127.0.0.1", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-03 02:53:03.329693+00');


--
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."clientes" ("id", "nome", "email", "telefone", "cpf_cnpj", "tipo_pessoa", "endereco_rua", "endereco_numero", "endereco_complemento", "endereco_bairro", "endereco_cidade", "endereco_estado", "endereco_cep", "observacoes", "status", "data_cadastro", "criado_por") VALUES
	(15, 'Cliente teste', NULL, '11993219184', NULL, 'fisica', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'inativo', '2025-11-12 23:42:52.637451+00', 3),
	(22, 'Celeste Jardim Lara', NULL, '(11) 97513-2156', NULL, 'fisica', 'Rua Cravo', '82', NULL, 'Jardim Das Flores', 'Osasco', 'SP', '06112-120', NULL, 'ativo', '2025-11-16 20:55:06.760771+00', 3),
	(16, 'Natalia Lara', NULL, '(11) 99674-4333', NULL, 'fisica', NULL, NULL, NULL, 'Km 18', 'Osasco', 'SP', NULL, NULL, 'ativo', '2025-11-12 23:55:37.982732+00', 3),
	(21, 'Restaurante Alta Dose', NULL, '(11) 94779-1001', '32685868000169', 'juridica', 'Avenida Crisantemo', '65', NULL, 'Jardim das Flores', 'Osasco', 'SP', '06112-100', NULL, 'ativo', '2025-11-16 20:50:39.023048+00', 2),
	(23, 'RosÃ¢ngela Lara', NULL, '(11) 98832-2729', NULL, 'fisica', 'Avenida dos Autonomistas', '3625', 'Apto 71', 'Centro', 'Osasco', 'SP', '06090-027', NULL, 'ativo', '2025-11-16 20:56:05.424835+00', 3),
	(14, 'Sandra Lara', NULL, '(11) 997112412', NULL, 'fisica', 'R. Frei Paulo de Sorocaba', '190', '23', 'Vila Lageado', 'SÃ£o Paulo', 'SP', '05340-020', NULL, 'ativo', '2025-11-02 15:29:26.658384+00', 2),
	(17, 'Tania Provazi', NULL, '(11) 95606-8008', NULL, 'fisica', NULL, NULL, NULL, 'Alphavile', 'Barueri', 'SP', NULL, NULL, 'ativo', '2025-11-13 00:01:04.3782+00', 3),
	(19, 'Victor Henrique Rodrigues', NULL, '(11) 99496-9750', NULL, 'fisica', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ativo', '2025-11-14 00:10:10.999191+00', 3),
	(18, 'Raquel Provazi', NULL, '(11) 94207-0551', NULL, 'fisica', NULL, NULL, NULL, 'Alphavile', 'Barueri', 'SP', NULL, NULL, 'ativo', '2025-11-14 00:08:10.372712+00', 3),
	(20, 'Flavio Praxedes', NULL, '(11) 98108-8819', NULL, 'fisica', NULL, NULL, NULL, 'Jardim das Flores', 'Osasco', 'SP', NULL, NULL, 'ativo', '2025-11-16 20:26:33.732186+00', 2),
	(24, 'Katia', NULL, '(11) 97236-3991', NULL, 'fisica', 'Rua Lazaro Suave', '283', 'Apto 62', 'City Bussocaba', 'Osasco', 'SP', '06040-470', NULL, 'ativo', '2025-11-17 00:38:33.664315+00', 2),
	(25, 'CarmÃ©lia Gomes', NULL, NULL, NULL, 'fisica', 'Meu nome Ã© Carmelia Gomes - Rua Padre Luis Yeber', '42', NULL, 'Vila SÃ£o Luis', 'SP', NULL, '05362-020', NULL, 'ativo', '2025-11-19 21:31:54.431623+00', 3),
	(26, 'Jessica', NULL, NULL, NULL, 'fisica', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ativo', '2025-12-01 23:29:25.452011+00', 1);


--
-- Data for Name: configuracoes_relatorios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."pedidos" ("id", "cliente_id", "numero_pedido", "data_pedido", "status", "tipo", "data_entrega_prevista", "horario_entrega", "valor_total", "forma_pagamento", "status_pagamento", "valor_pago", "data_pagamento", "observacoes_pagamento", "data_entrega", "observacoes", "observacoes_producao", "estoque_processado", "criado_por") VALUES
	(24, 14, '#002', '2025-11-12 23:59:30.077971+00', 'concluido', 'pronta_entrega', NULL, NULL, 195.00, 'PIX', 'pago', 195.00, '2025-11-16 20:19:27.279+00', '', NULL, '', '', false, 3),
	(29, 21, '#007', '2025-11-16 20:53:43.546636+00', 'concluido', 'pronta_entrega', NULL, NULL, 360.00, 'PIX', 'pago', 360.00, '2025-11-16 20:54:14.638+00', '', NULL, '', '', false, 2),
	(23, 16, '#001', '2025-11-12 23:56:27.037552+00', 'concluido', 'pronta_entrega', NULL, NULL, 80.00, 'PIX', 'pago', 80.00, '2025-11-16 21:03:07.179+00', 'Desconto de R$ 10,00', NULL, '', '', false, 3),
	(32, 24, '#010', '2025-11-17 00:45:56.273531+00', 'concluido', 'pronta_entrega', NULL, NULL, 130.00, 'PIX', 'pago', 130.00, '2025-11-17 00:46:26.224+00', '', NULL, '', '', false, 2),
	(28, 20, '#006', '2025-11-16 20:32:19.200224+00', 'concluido', 'pronta_entrega', NULL, NULL, 80.00, 'PIX', 'pago', 80.00, '2025-11-17 01:39:33.693+00', '', NULL, '', '', false, 2),
	(25, 17, '#003', '2025-11-13 00:02:35.26446+00', 'concluido', 'encomenda', '2025-11-22', NULL, 240.00, 'PIX', 'pago', 240.00, '2025-11-17 01:40:56.416+00', '', NULL, '', '', false, 3),
	(26, 18, '#004', '2025-11-14 00:09:19.081975+00', 'concluido', 'encomenda', '2025-11-15', NULL, 80.00, 'PIX', 'pago', 80.00, '2025-11-17 23:51:30.826+00', '', NULL, '', '', false, 3),
	(30, 22, '#008', '2025-11-16 20:55:49.60258+00', 'concluido', 'pronta_entrega', NULL, NULL, 80.00, 'PIX', 'pago', 80.00, '2025-11-18 14:26:20.225+00', '', NULL, '', '', false, 3),
	(33, 25, '#011', '2025-11-19 21:33:41.265377+00', 'entregue', 'pronta_entrega', NULL, NULL, 130.00, 'PIX', 'pago', 130.00, '2025-11-20 13:55:59.99+00', 'Entrega 10,00', NULL, '', '', false, 3),
	(27, 19, '#005', '2025-11-14 00:10:50.082997+00', 'pendente', 'encomenda', '2025-11-15', NULL, 80.00, 'PIX', 'pago', 80.00, '2025-12-01 23:28:55.461+00', '', NULL, '', '', false, 3),
	(31, 23, '#009', '2025-11-16 20:56:34.533718+00', 'concluido', 'pronta_entrega', NULL, NULL, 80.00, 'PIX', 'pago', 80.00, '2025-12-01 23:29:06.018+00', '', NULL, '', '', false, 3),
	(34, 26, '#012', '2025-11-28 00:09:21+00', 'concluido', 'pronta_entrega', NULL, NULL, 185.00, 'PIX', 'pago', 185.00, '2025-12-02 00:16:51.949+00', '', NULL, '', '', false, 1),
	(35, 24, '#013', '2025-11-28 00:10:12+00', 'entregue', 'pronta_entrega', NULL, NULL, 75.00, 'PIX', 'pendente', 0.00, NULL, NULL, NULL, '', '', false, 1);


--
-- Data for Name: entregas; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: produtos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."produtos" ("id", "nome", "descricao", "preco_venda", "preco_custo", "quantidade_minima", "categoria", "tipo_produto", "unidade_medida", "imagem_url", "status", "data_criacao", "data_atualizacao") VALUES
	(12, 'Molho ao Sugo Natural - 500ml', 'Molho ao Sugo Natural - 500ml', 15.00, 7.02, 2, 'Molho', 'producao_propria', 'Pote', 'produtos/1749062876280-551634345.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:53:04.757538+00'),
	(2, 'Nhoque Recheado Mussarela - 500g', 'Contem pacote de 500g de nhoque recheado de Mussarela', 40.00, 12.72, 3, 'Congelados', 'producao_propria', 'Pacote', 'produtos/1748975772896-582541457.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:51:54.242526+00'),
	(3, 'Nhoque Recheado Mussarela com Catupiry - 500g', 'Pacote de 500g com Nhoque Recheado Mussarela com Catupiry', 40.00, 11.18, 3, 'Congelados', 'producao_propria', 'Pacote', 'produtos/1748975798766-619419538.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:05.848897+00'),
	(4, 'Nhoque Recheado Presunto com Mussarela - 500g', 'Pacote de 500g de Nhoque Recheado Presunto com Mussarela', 40.00, 10.42, 3, 'Congelados', 'producao_propria', 'Pacote', 'produtos/1748975822395-385952879.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:13.00947+00'),
	(5, 'Nhoque Recheado Calabresa com Mussarela - 500g', 'Pacote de 500g de Nhoque Recheado Calabresa com Mussarela', 40.00, 10.37, 3, 'Congelados', 'producao_propria', 'Pacote', 'produtos/1748975843109-869330303.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:20.724214+00'),
	(6, 'Molho ao Sugo Extrato - 500ml', 'Pote de 500ml de molho de extrato de tomate', 20.00, 7.74, 3, 'Molho', 'producao_propria', 'Pote', 'produtos/1748975880417-190043038.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:27.377578+00'),
	(7, 'Molho Bolonhesa Extrato - 500ml', 'Pote de 500ml de molho de extrato de tomate', 20.00, 12.64, 3, 'Molho', 'producao_propria', 'Pote', 'produtos/1748975904643-820407538.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:32.915933+00'),
	(8, 'Refrigerante Coca-Cola - Lata 350ml', 'Refrigerante Coca-Cola - Lata 350ml', 3.00, 7.90, 5, 'Bebidas', 'revenda', 'Latas', 'produtos/1748988215446-707073668.png', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:38.315601+00'),
	(9, 'Refrigerante Coca-Cola Zero - Lata 350ml', 'Refrigerante Coca-Cola Zero - Lata 350ml', 3.00, 7.90, 5, 'Bebidas', 'revenda', 'Latas', 'produtos/1748988382869-601995256.png', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:45.856841+00'),
	(10, 'Refrigerante Guarana Antartica - Lata 269ml', 'Refrigerante Guarana Antartica - Lata 269ml', 3.00, 4.99, 5, 'Bebidas', 'revenda', 'Latas', 'produtos/1748988278894-87367356.png', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:52.962772+00'),
	(11, 'Caldo Verde', 'Caldo Verde tradicional', 25.00, 9.23, 2, 'Caldo', 'producao_propria', 'Pote', 'produtos/1749062849455-744863486.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-11 23:52:59.524697+00'),
	(1, 'Nhoque Tradicional - 500g', 'Nhoque Tradicional de 500g feito de batata', 25.00, 6.61, 3, 'Congelados', 'producao_propria', 'Pacote', 'produtos/1748975675797-731946779.jpg', 'ativo', '2025-06-11 04:39:30.346867+00', '2025-06-14 14:11:32.93274+00'),
	(13, 'Nhoque Recheado Mussarela - 240g', 'Nhoque Recheado Mussarela - 240g', 18.00, 1.00, 5, 'Congelados', 'producao_propria', 'Pacote', '/uploads/produtos/1763335948203-930398092.jpg', 'ativo', '2025-11-16 20:42:16.219071+00', '2025-11-29 02:46:50.450149+00');


--
-- Data for Name: estoque; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."estoque" ("id", "produto_id", "quantidade_atual", "quantidade_pronta_entrega", "quantidade_encomenda", "ultima_atualizacao") VALUES
	(27, 12, 0, 0, 0, '2025-11-29 02:42:24.401039+00'),
	(31, 13, 0, 0, 0, '2025-12-02 00:04:12.315297+00'),
	(26, 1, 3, 3, 0, '2025-12-02 00:33:51.156111+00'),
	(25, 2, 10, 10, 0, '2025-12-02 00:34:21.641088+00'),
	(32, 3, 5, 5, 0, '2025-12-02 00:34:44.618082+00'),
	(29, 5, 10, 10, 0, '2025-12-02 00:35:14.597418+00'),
	(30, 4, 10, 10, 0, '2025-12-02 00:35:38.393+00'),
	(33, 6, 5, 5, 0, '2025-12-02 00:36:45.750464+00'),
	(28, 7, 5, 5, 0, '2025-12-02 00:37:35.672061+00');


--
-- Data for Name: itens_pedido; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."itens_pedido" ("id", "pedido_id", "produto_id", "quantidade", "preco_unitario", "desconto_valor", "desconto_percentual", "tipo_desconto", "preco_unitario_com_desconto", "subtotal") VALUES
	(65, 27, 5, 1, 40.00, 0.00, 0.00, 'valor', 40.00, 40.00),
	(66, 27, 3, 1, 40.00, 0.00, 0.00, 'valor', 40.00, 40.00),
	(67, 24, 12, 1, 15.00, 0.00, 0.00, 'percentual', 15.00, 15.00),
	(68, 24, 7, 1, 20.00, 0.00, 0.00, 'percentual', 20.00, 20.00),
	(69, 24, 5, 2, 40.00, 0.00, 0.00, 'percentual', 40.00, 80.00),
	(70, 24, 2, 2, 40.00, 0.00, 0.00, 'percentual', 40.00, 80.00),
	(71, 23, 5, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(72, 23, 2, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(76, 29, 13, 20, 18.00, 0.00, 0.00, 'percentual', 18.00, 360.00),
	(83, 32, 1, 2, 25.00, 0.00, 0.00, 'percentual', 25.00, 50.00),
	(84, 32, 3, 2, 40.00, 0.00, 0.00, 'percentual', 40.00, 80.00),
	(87, 30, 2, 2, 40.00, 0.00, 0.00, 'percentual', 40.00, 80.00),
	(88, 28, 5, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(89, 28, 4, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(92, 26, 3, 2, 40.00, 0.00, 0.00, 'percentual', 40.00, 80.00),
	(94, 31, 5, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(95, 31, 2, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(96, 25, 3, 6, 40.00, 0.00, 0.00, 'percentual', 40.00, 240.00),
	(99, 33, 2, 2, 40.00, 0.00, 0.00, 'percentual', 40.00, 80.00),
	(100, 33, 1, 2, 25.00, 0.00, 0.00, 'percentual', 25.00, 50.00),
	(106, 34, 2, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(107, 34, 3, 2, 40.00, 0.00, 0.00, 'percentual', 40.00, 80.00),
	(108, 34, 4, 1, 40.00, 0.00, 0.00, 'percentual', 40.00, 40.00),
	(109, 34, 1, 1, 25.00, 0.00, 0.00, 'percentual', 25.00, 25.00),
	(112, 35, 1, 3, 25.00, 0.00, 0.00, 'percentual', 25.00, 75.00);


--
-- Data for Name: log_operacoes_automaticas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."log_operacoes_automaticas" ("id", "pedido_id", "tipo_operacao", "status_anterior", "status_novo", "produtos_afetados", "data_operacao", "observacoes") VALUES
	(18, 31, 'saida_estoque', 'pronto', 'entregue', '[{"operacao": "saida", "produto_id": 5, "quantidade": 1, "tipo_estoque": "pronta_entrega"}, {"operacao": "saida", "produto_id": 2, "quantidade": 1, "tipo_estoque": "pronta_entrega"}]', '2025-11-17 01:38:26.159179+00', 'SaÃ­da automÃ¡tica por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),
	(19, 30, 'saida_estoque', 'pronto', 'entregue', '[{"operacao": "saida", "produto_id": 2, "quantidade": 2, "tipo_estoque": "pronta_entrega"}]', '2025-11-17 01:38:43.707603+00', 'SaÃ­da automÃ¡tica por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),
	(20, 28, 'saida_estoque', 'pronto', 'entregue', '[{"operacao": "saida", "produto_id": 5, "quantidade": 1, "tipo_estoque": "pronta_entrega"}, {"operacao": "saida", "produto_id": 4, "quantidade": 1, "tipo_estoque": "pronta_entrega"}]', '2025-11-17 01:39:08.719186+00', 'SaÃ­da automÃ¡tica por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),
	(21, 31, 'saida_estoque', 'pronto', 'entregue', '[{"operacao": "saida", "produto_id": 5, "quantidade": 1, "tipo_estoque": "pronta_entrega"}, {"operacao": "saida", "produto_id": 2, "quantidade": 1, "tipo_estoque": "pronta_entrega"}]', '2025-11-17 02:57:40.921584+00', 'SaÃ­da automÃ¡tica por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),
	(22, 33, 'saida_estoque', 'pronto', 'entregue', '[{"operacao": "saida", "produto_id": 2, "quantidade": 2, "tipo_estoque": "pronta_entrega"}, {"operacao": "saida", "produto_id": 1, "quantidade": 2, "tipo_estoque": "pronta_entrega"}]', '2025-11-20 13:56:20.377864+00', 'SaÃ­da automÃ¡tica por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),
	(23, 34, 'saida_estoque', 'pronto', 'entregue', '[{"operacao": "saida", "produto_id": 2, "quantidade": 1, "tipo_estoque": "pronta_entrega"}, {"operacao": "saida", "produto_id": 3, "quantidade": 2, "tipo_estoque": "pronta_entrega"}, {"operacao": "saida", "produto_id": 4, "quantidade": 1, "tipo_estoque": "pronta_entrega"}, {"operacao": "saida", "produto_id": 1, "quantidade": 1, "tipo_estoque": "pronta_entrega"}]', '2025-12-02 00:14:59.722637+00', 'SaÃ­da automÃ¡tica por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),
	(24, 35, 'saida_estoque', 'pronto', 'entregue', '[{"operacao": "saida", "produto_id": 1, "quantidade": 3, "tipo_estoque": "pronta_entrega"}]', '2025-12-02 00:15:31.137615+00', 'SaÃ­da automÃ¡tica por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega');


--
-- Data for Name: movimentacoes_estoque; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."movimentacoes_estoque" ("id", "produto_id", "tipo_movimento", "quantidade", "motivo", "valor", "documento_referencia", "pedido_id", "tipo_operacao", "tipo_estoque", "data_movimentacao", "data_fabricacao", "data_validade", "usuario_id", "observacao") VALUES
	(31, 2, 'entrada', 6, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:31:31.232366+00', '2025-11-06', '2026-02-06', 3, NULL),
	(32, 1, 'entrada', 2, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:34:53.177591+00', '2025-11-06', '2026-02-06', 3, NULL),
	(33, 12, 'entrada', 2, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:48:43.254567+00', '2025-09-25', NULL, 3, NULL),
	(34, 7, 'entrada', 3, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:49:31.16606+00', '2025-10-16', NULL, 3, NULL),
	(35, 2, 'entrada', 2, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:50:12.23449+00', '2025-11-06', '2026-02-06', 3, NULL),
	(36, 5, 'entrada', 2, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:51:16.396683+00', '2025-11-06', '2026-02-06', 3, NULL),
	(37, 5, 'entrada', 1, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:51:54.354653+00', '2025-10-16', '2026-01-16', 3, NULL),
	(38, 2, 'entrada', 1, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-12 23:52:32.780614+00', '2025-10-31', '2026-01-31', 3, NULL),
	(39, 4, 'entrada', 1, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-16 20:28:42.542758+00', '2025-11-14', '2026-02-14', 2, NULL),
	(40, 4, 'entrada', 1, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-16 20:29:55.403765+00', '2025-11-14', '2026-02-14', 2, NULL),
	(41, 13, 'entrada', 20, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-16 20:51:56.131735+00', '2025-11-14', '2026-02-14', 2, 'Produzindo para o restaurante TaÃ§a Cheia '),
	(42, 3, 'entrada', 2, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-17 00:45:03.76586+00', '2025-11-14', '2026-02-14', 2, 'Venda direta para Katia'),
	(43, 5, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#31', 31, 'automatica', 'pronta_entrega', '2025-11-17 01:38:25.728013+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(44, 2, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#31', 31, 'automatica', 'pronta_entrega', '2025-11-17 01:38:25.955234+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(45, 2, 'saida', 2, 'Venda - Pronta Entrega', NULL, '#30', 30, 'automatica', 'pronta_entrega', '2025-11-17 01:38:43.592367+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(46, 5, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#28', 28, 'automatica', 'pronta_entrega', '2025-11-17 01:39:08.423222+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(47, 4, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#28', 28, 'automatica', 'pronta_entrega', '2025-11-17 01:39:08.592593+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(48, 5, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#31', 31, 'automatica', 'pronta_entrega', '2025-11-17 02:57:40.561141+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(49, 2, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#31', 31, 'automatica', 'pronta_entrega', '2025-11-17 02:57:40.782842+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(50, 2, 'saida', 2, 'Venda - Pronta Entrega', NULL, '#33', 33, 'automatica', 'pronta_entrega', '2025-11-20 13:56:19.840862+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(51, 1, 'saida', 2, 'Venda - Pronta Entrega', NULL, '#33', 33, 'automatica', 'pronta_entrega', '2025-11-20 13:56:20.135567+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(52, 7, 'saida', 3, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-29 02:41:08.978686+00', NULL, NULL, 1, 'Ajustes do estoque'),
	(53, 3, 'saida', 2, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-29 02:41:55.737172+00', NULL, NULL, 1, 'Ajustes do estoque'),
	(54, 12, 'saida', 2, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-29 02:42:24.320353+00', NULL, NULL, 1, 'Ajustes do estoque'),
	(55, 2, 'saida', 3, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-29 02:42:58.360282+00', NULL, NULL, 1, 'Ajustes do estoque'),
	(56, 4, 'saida', 1, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-11-29 02:44:13.534823+00', NULL, NULL, 1, 'Ajustes do estoque'),
	(57, 1, 'entrada', 4, 'Venda', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-01 23:44:58.123001+00', NULL, NULL, 1, NULL),
	(58, 4, 'entrada', 1, 'Venda', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-01 23:45:56.210808+00', NULL, NULL, 1, NULL),
	(59, 3, 'entrada', 2, 'Venda', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-01 23:46:10.028833+00', NULL, NULL, 1, NULL),
	(60, 2, 'entrada', 20, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:03:03.638118+00', NULL, NULL, 1, NULL),
	(61, 13, 'saida', 20, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:04:12.230819+00', NULL, NULL, 1, NULL),
	(62, 2, 'saida', 20, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:04:27.858135+00', NULL, NULL, 1, NULL),
	(63, 2, 'entrada', 1, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:05:23.088854+00', NULL, NULL, 1, NULL),
	(65, 4, 'entrada', 1, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:06:05.753047+00', NULL, NULL, 1, NULL),
	(66, 1, 'entrada', 1, 'Ajuste de inventÃ¡rio', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:06:20.689703+00', NULL, NULL, 1, NULL),
	(67, 2, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#34', 34, 'automatica', 'pronta_entrega', '2025-12-02 00:14:58.933649+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(68, 3, 'saida', 2, 'Venda - Pronta Entrega', NULL, '#34', 34, 'automatica', 'pronta_entrega', '2025-12-02 00:14:59.167001+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(70, 1, 'saida', 1, 'Venda - Pronta Entrega', NULL, '#34', 34, 'automatica', 'pronta_entrega', '2025-12-02 00:14:59.573009+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(71, 1, 'saida', 4, '', NULL, '#35', 35, 'automatica', 'pronta_entrega', '2025-12-02 00:15:31.038663+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(69, 4, 'saida', 2, '', NULL, '#34', 34, 'automatica', 'pronta_entrega', '2025-12-02 00:14:59.373539+00', NULL, NULL, NULL, 'SaÃ­da automÃ¡tica por entrega realizada'),
	(72, 1, 'entrada', 3, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:33:51.01044+00', '2025-11-25', '2026-02-25', 1, NULL),
	(73, 2, 'entrada', 10, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:34:21.506908+00', '2025-11-24', '2026-02-24', 1, NULL),
	(74, 3, 'entrada', 5, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:34:44.490036+00', '2025-11-25', '2026-02-25', 1, NULL),
	(75, 5, 'entrada', 10, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:35:14.502624+00', '2025-11-28', '2026-02-28', 1, NULL),
	(76, 4, 'entrada', 10, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:35:38.288129+00', '2025-11-29', '2026-03-01', 1, NULL),
	(77, 6, 'entrada', 5, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:36:45.633669+00', '2025-11-30', '2026-02-28', 1, NULL),
	(78, 7, 'entrada', 5, 'ProduÃ§Ã£o', NULL, NULL, NULL, 'manual', 'pronta_entrega', '2025-12-02 00:37:35.536735+00', '2025-11-30', '2026-02-28', 1, NULL);


--
-- Data for Name: sessoes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."sessoes" ("id", "usuario_id", "token", "ip_address", "user_agent", "data_criacao", "data_expiracao", "ativo") VALUES
	(63, 2, 'MjoxNzYyMDM5MzEzOTM1OjAuNTY5MTcwNjcxNzMzOTY2Ng==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', '2025-11-01 23:21:55.099576+00', '2025-11-02 07:21:53.935+00', false),
	(66, 3, 'MzoxNzYyNTI3MzA5NjY5OjAuMzAxMjg1ODUzNTE2MDc4Mg==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-07 14:55:10.592582+00', '2025-11-07 22:55:09.669+00', false),
	(64, 2, 'MjoxNzYyMDk3MjQyNTI0OjAuODgyNzIxNTkwODYzNzIyNA==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36', '2025-11-02 15:27:23.531245+00', '2025-11-02 23:27:22.524+00', false),
	(65, 2, 'MjoxNzYyMTA1ODIxNTk5OjAuNDMyMTM5OTc0MDQzNDc5MDQ=', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', '2025-11-02 17:50:21.678305+00', '2025-11-03 01:50:21.599+00', false),
	(67, 3, 'MzoxNzYyNTI3MzQyNDIzOjAuMTEyOTE2OTAwODA0MjEyMjQ=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-07 14:55:43.322843+00', '2025-11-07 22:55:42.423+00', false),
	(68, 2, 'MjoxNzYyNjE0Mjc0OTkwOjAuMDQzNzU4MTM1ODY5MTY2OTk=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-08 15:04:35.930389+00', '2025-11-08 23:04:34.99+00', false),
	(71, 2, 'MjoxNzYzMDE3ODM1Mjg0OjAuNjMyMzEzMjUxODkxNjgwOQ==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-13 07:10:35.605532+00', '2025-11-13 15:10:35.284+00', true),
	(73, 1, 'MToxNzYzMDU1MDY5NTA2OjAuNjMwMzg1NTI0NTAwMTI0OQ==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-13 17:31:09.623463+00', '2025-11-14 01:31:09.506+00', true),
	(69, 3, 'MzoxNzYyOTg5NjE1NTk4OjAuOTg1MjQxMTU4MzU5NTU=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-12 23:20:16.436886+00', '2025-11-13 07:20:15.598+00', false),
	(72, 3, 'MzoxNzYzMDUzOTA4MzY1OjAuODAyNDMyMjU3Mzg5Mzc2Nw==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-13 17:11:48.928617+00', '2025-11-14 01:11:48.365+00', false),
	(70, 2, 'MjoxNzYyOTk3MTIwNTQxOjAuMjA3ODAzODA0MTA3ODkxNTc=', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-13 01:25:20.877748+00', '2025-11-13 09:25:20.541+00', false),
	(75, 3, 'MzoxNzYzMjA4OTUwODE3OjAuOTM2NzAzMTc0NTgwMjQxOA==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-15 12:15:51.367756+00', '2025-11-15 20:15:50.817+00', false),
	(76, 3, 'MzoxNzYzMjQ5MTAyNDg2OjAuOTgwOTc0Njc1OTc4MTUxOA==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-15 23:25:03.035636+00', '2025-11-16 07:25:02.487+00', false),
	(80, 1, 'MToxNzYzMzM1NTA3MDIzOjAuMTUzNzczMzg0NzAyMjcxMw==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-16 23:25:07.172336+00', '2025-11-17 07:25:07.023+00', true),
	(81, 1, 'MToxNzYzMzM2MDk3ODIyOjAuMzMyNDAxOTQyNDgxOTc1NQ==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-16 23:34:57.988892+00', '2025-11-17 07:34:57.822+00', true),
	(74, 3, 'MzoxNzYzMDc4NTI2Njg1OjAuNDQ2MjAzMjk3MDM0Njk3NzQ=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-14 00:02:07.638106+00', '2025-11-14 08:02:06.685+00', false),
	(78, 2, 'MjoxNzYzMzA0NzQ5NDIxOjAuNTIyMjIzMTk2OTk0Njk4Mw==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-16 20:31:17.065967+00', '2025-11-16 22:52:29.421+00', false),
	(83, 1, 'MToxNzYzMzQ0ODY5MDA1OjAuNzgzOTg0MDQ4NzYwNTgy', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-17 02:01:09.281983+00', '2025-11-17 10:01:09.005+00', true),
	(84, 3, 'MzoxNzYzMzUxNTg2Njc3OjAuNjU4Njk4NzY1NTc3MzIyMg==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-17 03:53:06.684748+00', '2025-11-17 11:53:06.677+00', true),
	(77, 2, 'MjoxNzYzMzI0MDU2NDE4OjAuNDgxMDA2NDEyNjU4MTc5MzQ=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-16 20:14:16.89277+00', '2025-11-17 04:14:16.418+00', false),
	(82, 2, 'MjoxNzYzMzM2ODAwNDI3OjAuMzk2MDQ0Mjg2NTMwODk1Mw==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-16 23:46:40.59419+00', '2025-11-17 07:46:40.427+00', false),
	(79, 3, 'MzoxNzYzMzI2NDUxNzg3OjAuMjAxNDU4NzI1NjU1MTc3OTc=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-16 20:54:12.317401+00', '2025-11-17 04:54:11.787+00', false),
	(86, 3, 'MzoxNzYzNDIzNDM4ODI1OjAuNTk0MTUwODI3MDMxNzIz', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-17 23:50:39.366443+00', '2025-11-18 07:50:38.825+00', false),
	(85, 1, 'MToxNzYzMzU4MzIwNTk5OjAuMjU5Mjg4ODA2MjI5NDQzNQ==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-17 05:45:21.19327+00', '2025-11-17 13:45:20.599+00', false),
	(88, 1, 'MToxNzYzNDk4MTg1NjU5OjAuNDk4MDI1NzAyODY4MTQ1NA==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-18 20:36:25.849701+00', '2025-11-19 04:36:25.659+00', false),
	(87, 3, 'MzoxNzYzNDc1OTQ3MDAwOjAuMTQ0ODg0NDM4MDI3NTUwNw==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-18 14:25:47.538433+00', '2025-11-18 22:25:47+00', false),
	(90, 3, 'MzoxNzYzNTg3NzUwOTc0OjAuNzQzMjQxMDU4MjQwMjk2MQ==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-19 21:29:11.525433+00', '2025-11-20 05:29:10.975+00', false),
	(91, 3, 'MzoxNzYzNjQ2OTE1MTEzOjAuNDM3NTg5NTMwMTA5OTYzMDQ=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-20 13:55:15.672478+00', '2025-11-20 21:55:15.113+00', false),
	(92, 1, 'MToxNzYzNzc5MjM4MzgwOjAuNjg1Mzc4MTk3NTUwMjk3Mw==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-22 02:40:38.624579+00', '2025-11-22 10:40:38.38+00', false),
	(89, 1, 'MToxNzYzNTU0NTk3MDYzOjAuOTY1Nzk2MjU2NTcyMzc1Mw==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-19 12:16:37.389841+00', '2025-11-19 20:16:37.063+00', false),
	(93, 1, 'MToxNzY0MDQ0NTk0NTQ4OjAuMDg1ODEyMTQ0NDgxMjg3MTY=', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-25 04:23:14.80087+00', '2025-11-25 12:23:14.548+00', true),
	(95, 1, 'MToxNzY0MTMxMzM4NjA5OjAuMzE0MDUyMTc4MDk3Nzk3Mw==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-26 04:28:58.818864+00', '2025-11-26 12:28:58.609+00', true),
	(94, 1, 'MToxNzY0MTI1MjAzMzg5OjAuMTM5NDc0MzI3MTg3MzcwOTY=', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 02:46:43.546771+00', '2025-11-26 10:46:43.389+00', false),
	(96, 2, 'MjoxNzY0MTMzODE3ODUwOjAuNDkzMTc4NTU2NTY3NzU4OQ==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:17.986457+00', '2025-11-26 13:10:17.85+00', false),
	(97, 2, 'MjoxNzY0MTMzODQ2ODcwOjAuMDU3NDk2NDA1NDgzNjYxMTk1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:46.981024+00', '2025-11-26 13:10:46.87+00', false),
	(98, 2, 'MjoxNzY0MTMzOTMzMTE4OjAuODU1MjU3MzczMDU5NDA5NQ==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:13.249255+00', '2025-11-26 13:12:13.118+00', false),
	(99, 2, 'MjoxNzY0MTMzOTQ3MTE5OjAuODA0NjM4MTc3NzA4OTI3OA==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:27.222182+00', '2025-11-26 13:12:27.119+00', false),
	(100, 1, 'MToxNzY0MTMzOTU0NDE4OjAuNTUzMDg3OTUwOTY4NzI3', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:34.52279+00', '2025-11-26 13:12:34.418+00', false),
	(101, 1, 'MToxNzY0MzgzNzI5MTY2OjAuNjI1NjA5MDY5NTE0MDg5Nw==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-29 02:35:29.458436+00', '2025-11-29 10:35:29.166+00', false),
	(103, 1, 'MToxNzY0NjM1NDg1MzI4OjAuOTkzOTEyNjY1MTg4Njg5OQ==', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-12-02 00:31:25.43744+00', '2025-12-02 08:31:25.328+00', true),
	(104, 3, 'MzoxNzY0NjM2ODM1MTU0OjAuMDUxMjcyNDg2NDI2NTQ4MjU=', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-12-02 00:53:55.674574+00', '2025-12-02 08:53:55.154+00', true),
	(102, 1, 'MToxNzY0NjMwNTc2NDQyOjAuMDM0ODM3MzMxMjI4MTU4NDY0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-01 23:09:36.616384+00', '2025-12-02 07:09:36.442+00', false),
	(105, 1, 'MToxNzY0NzMwMzgyMTM1OjAuNjY3Njg2MjQ3MDMyMjg5Mw==', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-03 02:53:03.08991+00', '2025-12-03 10:53:02.135+00', true);


--
-- Data for Name: tentativas_login; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tentativas_login" ("id", "email", "ip_address", "sucesso", "motivo", "user_agent", "data_tentativa") VALUES
	(65, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', '2025-11-01 23:21:55.170931+00'),
	(66, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36', '2025-11-02 15:27:23.669559+00'),
	(67, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', '2025-11-02 17:50:21.802163+00'),
	(68, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-07 14:55:10.75373+00'),
	(69, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-07 14:55:43.386532+00'),
	(70, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-08 15:04:36.059703+00'),
	(71, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-12 23:20:16.612741+00'),
	(72, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-13 01:25:21.022303+00'),
	(73, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-13 07:10:35.728608+00'),
	(74, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-13 17:11:49.168726+00'),
	(75, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-13 17:31:09.740474+00'),
	(76, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-14 00:02:07.767282+00'),
	(77, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-15 12:15:51.548741+00'),
	(78, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-15 23:25:03.186801+00'),
	(79, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-16 20:14:17.079538+00'),
	(80, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-16 20:31:17.15054+00'),
	(81, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-16 20:54:12.411741+00'),
	(82, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-16 23:25:07.322345+00'),
	(83, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-16 23:34:58.099474+00'),
	(84, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-16 23:46:40.693046+00'),
	(85, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-17 02:01:09.401502+00'),
	(86, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-17 03:53:06.800702+00'),
	(87, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-17 05:45:21.338064+00'),
	(88, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-17 23:50:39.552035+00'),
	(89, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-18 14:25:47.662502+00'),
	(90, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-18 20:36:26.103971+00'),
	(91, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-19 12:16:37.552735+00'),
	(92, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-19 21:29:11.668151+00'),
	(93, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-11-20 13:55:15.957606+00'),
	(94, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-22 02:40:38.763262+00'),
	(95, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-25 04:23:14.926815+00'),
	(96, 'admin@silosystem.com', '127.0.0.1', false, 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 02:46:15.771512+00'),
	(97, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 02:46:43.638369+00'),
	(98, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-26 04:28:58.927271+00'),
	(99, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:18.075611+00'),
	(100, 'otnielbastos@hotmail.com', '127.0.0.1', false, 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:40.74018+00'),
	(101, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:10:47.030072+00'),
	(102, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:13.309504+00'),
	(103, 'otnielbastos@hotmail.com', '127.0.0.1', false, 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:22.562894+00'),
	(104, 'otnielbastos@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:27.276726+00'),
	(105, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-26 05:12:34.563781+00'),
	(106, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-29 02:35:29.595428+00'),
	(107, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-01 23:09:36.729443+00'),
	(108, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-12-02 00:31:25.585583+00'),
	(109, 'silvanalm01@hotmail.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', '2025-12-02 00:53:55.88918+00'),
	(110, 'admin@silosystem.com', '127.0.0.1', true, 'Login bem-sucedido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-03 02:53:03.213102+00');


--
-- Data for Name: transferencias_estoque; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('uploads', 'uploads', NULL, '2025-06-13 00:55:11.73322+00', '2025-06-13 00:55:11.73322+00', true, false, NULL, NULL, NULL, 'STANDARD');


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata", "level") VALUES
	('fc8102ac-f3de-4412-9369-7e237ee68fe9', 'uploads', 'produtos/.emptyFolderPlaceholder', NULL, '2025-06-13 00:55:19.61953+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:19.61953+00', '{"eTag": "\"d41d8cd98f00b204e9800998ecf8427e\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:53.000Z", "contentLength": 0, "httpStatusCode": 200}', 'd9a2c495-b7f4-41ac-b3e5-5425d19e076e', NULL, '{}', 2),
	('b5a0fc79-51f3-42bc-83c8-eda9c2fe56b3', 'uploads', 'produtos/1748924043180-978285663.jpg', NULL, '2025-06-13 00:55:37.336396+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.336396+00', '{"eTag": "\"c2e75609af96dab8c29106dd3cdf5ebc\"", "size": 94960, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:54.000Z", "contentLength": 94960, "httpStatusCode": 200}', '86796c34-43eb-49a7-a0ee-14c5125931f8', NULL, NULL, 2),
	('ece061e8-02e4-4cde-ba3d-759aba1aaf0b', 'uploads', 'produtos/1748975675797-731946779.jpg', NULL, '2025-06-13 00:55:37.406599+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.406599+00', '{"eTag": "\"ce100b676ffa8b0505157056768263e5\"", "size": 93839, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:54.000Z", "contentLength": 93839, "httpStatusCode": 200}', 'aacf2821-8be5-4ad3-875d-61d40a96bd6b', NULL, NULL, 2),
	('b830887b-2822-4219-b800-bc4d93dc95e6', 'uploads', 'produtos/1748975798766-619419538.jpg', NULL, '2025-06-13 00:55:37.132429+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.132429+00', '{"eTag": "\"2c5a7a6dd2faeaca86652024d4261695\"", "size": 85857, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:54.000Z", "contentLength": 85857, "httpStatusCode": 200}', '53155ee7-c71f-4b20-aa4a-a1f307de8fd7', NULL, NULL, 2),
	('27747d4e-e3f1-495c-97ea-69a1a4b6e819', 'uploads', 'produtos/1748975772896-582541457.jpg', NULL, '2025-06-13 00:55:37.403672+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.403672+00', '{"eTag": "\"2fb03a2fe9a51ca2ab361d0f2c7f650f\"", "size": 87020, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:54.000Z", "contentLength": 87020, "httpStatusCode": 200}', '9212c4b8-e853-4b7f-8ba2-06a9b69ce4d0', NULL, NULL, 2),
	('07b6c6cf-d385-4ead-84a7-9c6dc6c2e7b3', 'uploads', 'produtos/1748975843109-869330303.jpg', NULL, '2025-06-13 00:55:37.364296+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.364296+00', '{"eTag": "\"226f9d1423dc4c0c0f0ca370353e7029\"", "size": 85479, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:55.000Z", "contentLength": 85479, "httpStatusCode": 200}', '10aefac7-cd06-4e33-8131-fb007bfe626b', NULL, NULL, 2),
	('044d534b-d4b9-4cd9-9ca2-bdc431b76004', 'uploads', 'produtos/1748975822395-385952879.jpg', NULL, '2025-06-13 00:55:37.338032+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.338032+00', '{"eTag": "\"442b8678800bfd0dc7f6e3a54c67eeb6\"", "size": 81328, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:55.000Z", "contentLength": 81328, "httpStatusCode": 200}', 'b03c4252-4681-4bf4-90a6-825ac99e9c76', NULL, NULL, 2),
	('36ba6a44-a20f-4082-9a5b-8776234afa13', 'uploads', 'produtos/1748975904643-820407538.jpg', NULL, '2025-06-13 00:55:37.522238+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.522238+00', '{"eTag": "\"003e2f1d684943e7e8f682ebd3b432ef\"", "size": 95382, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:56.000Z", "contentLength": 95382, "httpStatusCode": 200}', 'fa65e0e7-6cec-41a9-99a3-218ffeac0a5d', NULL, NULL, 2),
	('43f88e4c-dc9e-438e-90e8-d9e4eb2a5596', 'uploads', 'produtos/1748975880417-190043038.jpg', NULL, '2025-06-13 00:55:37.174895+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.174895+00', '{"eTag": "\"d4b934da65885fa41a79342d5714537a\"", "size": 82036, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:56.000Z", "contentLength": 82036, "httpStatusCode": 200}', '213cebed-9282-4d73-b8b5-e07b96d100dd', NULL, NULL, 2),
	('a928fd45-b9e0-4685-b4ee-34e765d157a9', 'uploads', 'produtos/1748988215446-707073668.png', NULL, '2025-06-13 00:55:37.139765+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.139765+00', '{"eTag": "\"a5760571533f771ba71668a90cb3a3b9\"", "size": 47333, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:57.000Z", "contentLength": 47333, "httpStatusCode": 200}', '5a182d19-9218-4a49-b0f3-9cc982bd8875', NULL, NULL, 2),
	('33c52f67-649d-410b-a1de-3b345edfa253', 'uploads', 'produtos/1748988382869-601995256.png', NULL, '2025-06-13 00:55:38.37265+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:38.37265+00', '{"eTag": "\"e6520dce23bc59437d78fcbe756caaae\"", "size": 51914, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:58.000Z", "contentLength": 51914, "httpStatusCode": 200}', '24812ed6-bcb5-4b27-9e5c-b443042e6b14', NULL, NULL, 2),
	('4fa57bc8-2a93-4cf3-8aec-2824f34414b0', 'uploads', 'produtos/1748913728802-316161621.jpg', NULL, '2025-06-13 00:55:37.174082+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:37.174082+00', '{"eTag": "\"121c5269adc21aad7288c7bb2587b9f9\"", "size": 96933, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:53.000Z", "contentLength": 96933, "httpStatusCode": 200}', '80178ded-43e3-4a1d-9072-9eaf806a489b', NULL, NULL, 2),
	('c29c6ee8-ff43-4c24-ba6e-ba78d761c759', 'uploads', 'produtos/1749062876280-551634345.jpg', NULL, '2025-06-13 00:55:38.53407+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:38.53407+00', '{"eTag": "\"f63011af5c9f5f950d8be892ecfbacb5\"", "size": 97585, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:58.000Z", "contentLength": 97585, "httpStatusCode": 200}', '9db2793a-a9f4-4701-80f7-490f0d4d4002', NULL, NULL, 2),
	('c8e6662e-740a-47cd-b613-27dfe201687c', 'uploads', 'produtos/1748988278894-87367356.png', NULL, '2025-06-13 00:55:38.305682+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:38.305682+00', '{"eTag": "\"67f328e7f2cc552250e284f94863e62c\"", "size": 98366, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:57.000Z", "contentLength": 98366, "httpStatusCode": 200}', '84ffb7a8-3800-434b-b6e0-07ec3f9193a2', NULL, NULL, 2),
	('51426e28-95de-4a8f-89d1-c0aa4a45c472', 'uploads', 'produtos/1749062849455-744863486.jpg', NULL, '2025-06-13 00:55:38.486143+00', '2025-08-26 14:55:30.797145+00', '2025-06-13 00:55:38.486143+00', '{"eTag": "\"257a6149b32cda1897e8c1c4ef6c140f\"", "size": 96563, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-06-13T03:15:58.000Z", "contentLength": 96563, "httpStatusCode": 200}', '1e93e6a5-094c-450c-b3bc-16690d62ef95', NULL, NULL, 2),
	('cf2f1b1f-4ddc-4238-a660-2994f14fd382', 'uploads', 'produtos/1763335719107-224177416.jpg', NULL, '2025-11-16 23:28:39.482238+00', '2025-11-16 23:28:39.482238+00', '2025-11-16 23:28:39.482238+00', '{"eTag": "\"c4395957795b8743d4fbc20246c4c892\"", "size": 111426, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-11-16T23:28:40.000Z", "contentLength": 111426, "httpStatusCode": 200}', 'b3457b55-1b81-41a4-a54f-19fb35b3ffff', NULL, '{}', 2),
	('4f132203-36dd-402a-adc5-7d6cda39c6b6', 'uploads', 'produtos/1763335790805-939324116.jpg', NULL, '2025-11-16 23:29:51.189682+00', '2025-11-16 23:29:51.189682+00', '2025-11-16 23:29:51.189682+00', '{"eTag": "\"c4395957795b8743d4fbc20246c4c892\"", "size": 111426, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-11-16T23:29:52.000Z", "contentLength": 111426, "httpStatusCode": 200}', '6271da30-bf4c-4105-89a6-5d7be77da75b', NULL, '{}', 2),
	('fb524e7d-f610-4916-8397-bd105496fe0b', 'uploads', 'produtos/1763335948203-930398092.jpg', NULL, '2025-11-16 23:32:28.558388+00', '2025-11-16 23:32:28.558388+00', '2025-11-16 23:32:28.558388+00', '{"eTag": "\"c4395957795b8743d4fbc20246c4c892\"", "size": 111426, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-11-16T23:32:29.000Z", "contentLength": 111426, "httpStatusCode": 200}', '73a0676a-3191-400b-b03f-75a8d20bdbc5', NULL, '{}', 2);


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."prefixes" ("bucket_id", "name", "created_at", "updated_at") VALUES
	('uploads', 'produtos', '2025-08-26 14:55:30.501907+00', '2025-08-26 14:55:30.501907+00');


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, false);


--
-- Name: auditoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."auditoria_id_seq"', 141, true);


--
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."clientes_id_seq"', 26, true);


--
-- Name: configuracoes_relatorios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."configuracoes_relatorios_id_seq"', 1, false);


--
-- Name: entregas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."entregas_id_seq"', 1, false);


--
-- Name: estoque_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."estoque_id_seq"', 33, true);


--
-- Name: itens_pedido_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."itens_pedido_id_seq"', 112, true);


--
-- Name: log_operacoes_automaticas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."log_operacoes_automaticas_id_seq"', 24, true);


--
-- Name: movimentacoes_estoque_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."movimentacoes_estoque_id_seq"', 78, true);


--
-- Name: pedidos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."pedidos_id_seq"', 35, true);


--
-- Name: perfis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."perfis_id_seq"', 3, true);


--
-- Name: produtos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."produtos_id_seq"', 13, true);


--
-- Name: sessoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."sessoes_id_seq"', 105, true);


--
-- Name: tentativas_login_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."tentativas_login_id_seq"', 110, true);


--
-- Name: transferencias_estoque_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."transferencias_estoque_id_seq"', 1, false);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."usuarios_id_seq"', 3, true);


--
-- PostgreSQL database dump complete
--

RESET ALL;
