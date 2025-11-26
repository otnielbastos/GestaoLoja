-- Configurações de RLS (Row Level Security) para as tabelas do Supabase
-- Execute estes comandos no painel SQL do Supabase

-- Desabilitar RLS temporariamente para permitir acesso aos dados
ALTER TABLE public.perfis DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.estoque DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_pedido DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.entregas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_estoque DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transferencias_estoque DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tentativas_login DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes_relatorios DISABLE ROW LEVEL SECURITY;

-- Criar políticas básicas para permitir acesso aos dados (substitua por políticas mais restritivas quando necessário)

-- Políticas para produtos (leitura pública para relatórios)
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir leitura de produtos" ON public.produtos
    FOR SELECT USING (true);

-- Políticas para pedidos (leitura pública para relatórios)
ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir leitura de pedidos" ON public.pedidos
    FOR SELECT USING (true);

-- Políticas para itens_pedido (leitura pública para relatórios)
ALTER TABLE public.itens_pedido ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir leitura de itens_pedido" ON public.itens_pedido
    FOR SELECT USING (true);

-- Políticas para entregas (leitura pública para relatórios)
ALTER TABLE public.entregas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir leitura de entregas" ON public.entregas
    FOR SELECT USING (true);

-- Políticas para estoque (leitura pública para relatórios)
ALTER TABLE public.estoque ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir leitura de estoque" ON public.estoque
    FOR SELECT USING (true);

-- Políticas para clientes (leitura pública para relatórios)
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir leitura de clientes" ON public.clientes
    FOR SELECT USING (true);

-- IMPORTANTE: Para ambiente de produção, substitua essas políticas por políticas mais restritivas
-- que considerem autenticação e autorização adequadas.

-- Exemplo de política mais restritiva (comente as políticas acima e use estas):
/*
-- Política para usuários autenticados
CREATE POLICY "Usuários autenticados podem ler produtos" ON public.produtos
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem ler pedidos" ON public.pedidos
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem ler itens_pedido" ON public.itens_pedido
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem ler entregas" ON public.entregas
    FOR SELECT USING (auth.role() = 'authenticated');
*/ 