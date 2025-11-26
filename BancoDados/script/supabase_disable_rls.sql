-- SOLUÇÃO RÁPIDA: Desabilitar RLS temporariamente
-- Execute este arquivo no painel SQL do Supabase para resolver o erro 401

-- Desabilitar RLS em todas as tabelas principais
ALTER TABLE public.pedidos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_pedido DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.estoque DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_estoque DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.entregas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transferencias_estoque DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.log_operacoes_automaticas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.perfis DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tentativas_login DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes_relatorios DISABLE ROW LEVEL SECURITY;

-- Verificar se RLS foi desabilitado
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename; 