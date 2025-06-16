import { supabase } from '../lib/supabase';
import { authService } from './supabaseAuth';

export interface DashboardStats {
  vendas_hoje: number;
  variacao_vendas: number;
  pedidos_ativos: number;
  pedidos_preparo: number;
  total_produtos: number;
  produtos_estoque_baixo: number;
  total_clientes: number;
  novos_clientes_semana: number;
}

export interface PedidoRecente {
  id: number;
  numero_pedido: string;
  cliente_nome: string;
  valor_total: number;
  status: string;
  data_pedido: string;
}

export interface AtividadeRecente {
  id: number;
  tipo: string;
  descricao: string;
  usuario: string;
  data: string;
}

export interface Alerta {
  id: number;
  tipo: 'estoque_baixo' | 'entrega_pendente' | 'pedido_agendado' | 'pagamento_pendente' | 'pedido_atrasado' | 'produto_vencendo' | 'meta_vendas' | 'cliente_inativo' | 'producao_atrasada';
  titulo: string;
  descricao: string;
  prioridade: 'alta' | 'media' | 'baixa';
}

export async function getDashboardMainStats(): Promise<DashboardStats> {
  try {
    const hoje = new Date().toISOString().split('T')[0];
    const ontem = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const semanaAtras = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // Obter usuário atual
    const user = authService.getCurrentUser();
    const isVendedor = user?.perfil === 'Vendedor';

    // Base queries com filtro de vendedor se necessário
    let vendasHojeQuery = supabase
      .from('pedidos')
      .select('valor_total')
      .gte('data_pedido', hoje)
      .eq('status_pagamento', 'pago');

    let vendasOntemQuery = supabase
      .from('pedidos')
      .select('valor_total')
      .gte('data_pedido', ontem)
      .lt('data_pedido', hoje)
      .eq('status_pagamento', 'pago');

    let pedidosAtivosQuery = supabase
      .from('pedidos')
      .select('*', { count: 'exact', head: true })
      .not('status', 'in', '(cancelado,concluido)');

    let pedidosPreparoQuery = supabase
      .from('pedidos')
      .select('*', { count: 'exact', head: true })
      .in('status', ['em_preparo', 'aguardando_producao', 'em_separacao']);

    let clientesQuery = supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'ativo');

    let novosClientesQuery = supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .gte('data_cadastro', semanaAtras)
      .eq('status', 'ativo');

    // REGRA DE NEGÓCIO: Se for vendedor, filtrar por dados próprios
    if (isVendedor && user?.id) {
      vendasHojeQuery = vendasHojeQuery.eq('criado_por', user.id);
      vendasOntemQuery = vendasOntemQuery.eq('criado_por', user.id);
      pedidosAtivosQuery = pedidosAtivosQuery.eq('criado_por', user.id);
      pedidosPreparoQuery = pedidosPreparoQuery.eq('criado_por', user.id);
      clientesQuery = clientesQuery.eq('criado_por', user.id);
      novosClientesQuery = novosClientesQuery.eq('criado_por', user.id);
    }

    // Executar queries
    const [
      { data: vendasHoje },
      { data: vendasOntem },
      { count: pedidosAtivos },
      { count: pedidosPreparo },
      { count: totalClientes },
      { count: novosClientesSemana }
    ] = await Promise.all([
      vendasHojeQuery,
      vendasOntemQuery,
      pedidosAtivosQuery,
      pedidosPreparoQuery,
      clientesQuery,
      novosClientesQuery
    ]);

    // Total de produtos ativos (só administradores e gerentes veem todos)
    const { count: totalProdutos } = await supabase
      .from('produtos')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'ativo');

    // Produtos com estoque baixo (só administradores e gerentes veem)
    let produtosEstoqueBaixo = 0;
    if (!isVendedor) {
      const { data: produtosComEstoque } = await supabase
        .from('produtos')
        .select(`
          id,
          nome,
          quantidade_minima,
          estoque (
            quantidade_atual
          )
        `)
        .eq('status', 'ativo');

      produtosEstoqueBaixo = produtosComEstoque?.filter(produto => {
        const estoque = produto.estoque as any;
        const quantidadeAtual = estoque?.[0]?.quantidade_atual || 0;
        return quantidadeAtual <= produto.quantidade_minima;
      }).length || 0;
    }

    const vendasHojeTotal = vendasHoje?.reduce((sum, pedido) => sum + Number(pedido.valor_total), 0) || 0;
    const vendasOntemTotal = vendasOntem?.reduce((sum, pedido) => sum + Number(pedido.valor_total), 0) || 0;
    
    const variacaoVendas = vendasOntemTotal > 0 
      ? ((vendasHojeTotal - vendasOntemTotal) / vendasOntemTotal) * 100 
      : vendasHojeTotal > 0 ? 100 : 0;

    return {
      vendas_hoje: vendasHojeTotal,
      variacao_vendas: variacaoVendas,
      pedidos_ativos: pedidosAtivos || 0,
      pedidos_preparo: pedidosPreparo || 0,
      total_produtos: !isVendedor ? (totalProdutos || 0) : 0, // Vendedor não vê contagem de produtos
      produtos_estoque_baixo: produtosEstoqueBaixo,
      total_clientes: totalClientes || 0,
      novos_clientes_semana: novosClientesSemana || 0,
    };
  } catch (error) {
    console.error('Erro ao buscar estatísticas do dashboard:', error);
    return {
      vendas_hoje: 0,
      variacao_vendas: 0,
      pedidos_ativos: 0,
      pedidos_preparo: 0,
      total_produtos: 0,
      produtos_estoque_baixo: 0,
      total_clientes: 0,
      novos_clientes_semana: 0,
    };
  }
}

export async function getPedidosRecentes(): Promise<PedidoRecente[]> {
  try {
    const hoje = new Date().toISOString().split('T')[0];
    
    // Obter usuário atual
    const user = authService.getCurrentUser();
    const isVendedor = user?.perfil === 'Vendedor';
    
    let query = supabase
      .from('pedidos')
      .select(`
        id,
        numero_pedido,
        valor_total,
        status,
        data_pedido,
        clientes (
          nome
        )
      `)
      .gte('data_pedido', hoje)
      .order('data_pedido', { ascending: false })
      .limit(5);

    // REGRA DE NEGÓCIO: Vendedor só vê seus pedidos
    if (isVendedor && user?.id) {
      query = query.eq('criado_por', user.id);
    }

    const { data: pedidos, error } = await query;

    if (error) throw error;

    return pedidos?.map(pedido => ({
      id: pedido.id,
      numero_pedido: pedido.numero_pedido,
      cliente_nome: (pedido.clientes as any)?.nome || 'Cliente não encontrado',
      valor_total: Number(pedido.valor_total),
      status: pedido.status,
      data_pedido: pedido.data_pedido,
    })) || [];
  } catch (error) {
    console.error('Erro ao buscar pedidos recentes:', error);
    return [];
  }
}

export async function getAtividadesRecentes(): Promise<AtividadeRecente[]> {
  try {
    const { data: atividades, error } = await supabase
      .from('auditoria')
      .select(`
        id,
        acao,
        tabela,
        data_acao,
        usuarios (
          nome
        )
      `)
      .order('data_acao', { ascending: false })
      .limit(5);

    if (error) throw error;

    return atividades?.map(atividade => ({
      id: atividade.id,
      tipo: atividade.acao,
      descricao: `${atividade.acao} em ${atividade.tabela}`,
      usuario: (atividade.usuarios as any)?.nome || 'Sistema',
      data: atividade.data_acao,
    })) || [];
  } catch (error) {
    console.error('Erro ao buscar atividades recentes:', error);
    return [];
  }
}

export async function getAlertas(): Promise<Alerta[]> {
  try {
    const alertas: Alerta[] = [];
    const hoje = new Date().toISOString().split('T')[0];
    const ontem = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const semanaAtras = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const mesAtras = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // 1. ALERTAS DE ESTOQUE BAIXO (Prioridade Alta)
    const { data: produtosParaAlerta } = await supabase
      .from('produtos')
      .select(`
        id,
        nome,
        quantidade_minima,
        estoque (
          quantidade_atual
        )
      `)
      .eq('status', 'ativo')
      .limit(10);

    const produtosComEstoqueBaixo = produtosParaAlerta?.filter(produto => {
      const estoque = produto.estoque as any;
      const quantidadeAtual = estoque?.[0]?.quantidade_atual || 0;
      return quantidadeAtual <= produto.quantidade_minima;
    }).slice(0, 2);

    produtosComEstoqueBaixo?.forEach((produto, index) => {
      const estoque = produto.estoque as any;
      const quantidadeAtual = estoque?.[0]?.quantidade_atual || 0;
      alertas.push({
        id: alertas.length + 1,
        tipo: 'estoque_baixo',
        titulo: 'Estoque Baixo',
        descricao: `${produto.nome} - Restam apenas ${quantidadeAtual} unidades`,
        prioridade: quantidadeAtual === 0 ? 'alta' : 'media'
      });
    });

    // 2. PAGAMENTOS PENDENTES (Prioridade Alta)
    const { data: pagamentosPendentes } = await supabase
      .from('pedidos')
      .select(`
        id,
        numero_pedido,
        valor_total,
        data_pedido,
        clientes (nome)
      `)
      .eq('status_pagamento', 'pendente')
      .lte('data_pedido', ontem)
      .limit(3);

    pagamentosPendentes?.forEach((pedido) => {
      const diasAtraso = Math.floor((Date.now() - new Date(pedido.data_pedido).getTime()) / (1000 * 60 * 60 * 24));
      alertas.push({
        id: alertas.length + 1,
        tipo: 'pagamento_pendente',
        titulo: 'Pagamento Pendente',
        descricao: `${(pedido.clientes as any)?.nome} - R$ ${Number(pedido.valor_total).toFixed(2)} (${diasAtraso} dias)`,
        prioridade: diasAtraso > 3 ? 'alta' : 'media'
      });
    });

    // 3. PEDIDOS ATRASADOS (Prioridade Alta)
    const { data: pedidosAtrasados } = await supabase
      .from('pedidos')
      .select(`
        id,
        numero_pedido,
        data_entrega_prevista,
        clientes (nome)
      `)
      .lt('data_entrega_prevista', hoje)
      .not('status', 'in', '(entregue,concluido,cancelado)')
      .limit(3);

    pedidosAtrasados?.forEach((pedido) => {
      const diasAtraso = Math.floor((Date.now() - new Date(pedido.data_entrega_prevista).getTime()) / (1000 * 60 * 60 * 24));
      alertas.push({
        id: alertas.length + 1,
        tipo: 'pedido_atrasado',
        titulo: 'Pedido Atrasado',
        descricao: `${(pedido.clientes as any)?.nome} - ${diasAtraso} dia(s) de atraso`,
        prioridade: 'alta'
      });
    });

    // 4. PRODUÇÃO ATRASADA (Prioridade Alta)
    const { data: producaoAtrasada } = await supabase
      .from('pedidos')
      .select(`
        id,
        numero_pedido,
        data_entrega_prevista,
        clientes (nome)
      `)
      .eq('tipo', 'encomenda')
      .eq('status', 'aguardando_producao')
      .lte('data_entrega_prevista', new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
      .limit(2);

    producaoAtrasada?.forEach((pedido) => {
      alertas.push({
        id: alertas.length + 1,
        tipo: 'producao_atrasada',
        titulo: 'Produção Urgente',
        descricao: `${(pedido.clientes as any)?.nome} - Entrega em ${Math.ceil((new Date(pedido.data_entrega_prevista).getTime() - Date.now()) / (1000 * 60 * 60 * 24))} dia(s)`,
        prioridade: 'alta'
      });
    });

    // 5. PRODUTOS PRÓXIMOS DO VENCIMENTO (Prioridade Média)
    const { data: movimentacoesVencimento } = await supabase
      .from('movimentacoes_estoque')
      .select(`
        id,
        data_validade,
        quantidade,
        produtos (nome)
      `)
      .not('data_validade', 'is', null)
      .lte('data_validade', new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
      .eq('tipo_movimento', 'entrada')
      .limit(2);

    movimentacoesVencimento?.forEach((mov) => {
      const diasVencimento = Math.ceil((new Date(mov.data_validade).getTime() - Date.now()) / (1000 * 60 * 60 * 24));
      alertas.push({
        id: alertas.length + 1,
        tipo: 'produto_vencendo',
        titulo: 'Produto Vencendo',
        descricao: `${(mov.produtos as any)?.nome} - Vence em ${diasVencimento} dia(s)`,
        prioridade: diasVencimento <= 1 ? 'alta' : 'media'
      });
    });

    // 6. ENTREGAS PENDENTES (Prioridade Média)
    const { data: entregasPendentes } = await supabase
      .from('entregas')
      .select(`
        id,
        data_agendada,
        pedidos (
          numero_pedido,
          clientes (nome)
        )
      `)
      .eq('status', 'aguardando')
      .lte('data_agendada', hoje)
      .limit(2);

    entregasPendentes?.forEach((entrega) => {
      alertas.push({
        id: alertas.length + 1,
        tipo: 'entrega_pendente',
        titulo: 'Entrega Pendente',
        descricao: `${(entrega.pedidos as any)?.clientes?.nome} - Agendada para hoje`,
        prioridade: 'media'
      });
    });

    // 7. META DE VENDAS (Prioridade Baixa)
    const { data: vendasHoje } = await supabase
      .from('pedidos')
      .select('valor_total')
      .gte('data_pedido', hoje)
      .eq('status_pagamento', 'pago');

    const totalVendasHoje = vendasHoje?.reduce((sum, pedido) => sum + Number(pedido.valor_total), 0) || 0;
    const metaDiaria = 1000; // Meta diária de R$ 1.000 (pode ser configurável)
    
    if (totalVendasHoje < metaDiaria * 0.5 && new Date().getHours() > 14) {
      alertas.push({
        id: alertas.length + 1,
        tipo: 'meta_vendas',
        titulo: 'Meta de Vendas',
        descricao: `Vendas hoje: R$ ${totalVendasHoje.toFixed(2)} de R$ ${metaDiaria.toFixed(2)} (${((totalVendasHoje/metaDiaria)*100).toFixed(0)}%)`,
        prioridade: 'baixa'
      });
    }

    // 8. CLIENTES INATIVOS (Prioridade Baixa)
    // Primeiro buscar clientes que fizeram pedidos recentemente
    const { data: clientesComPedidos } = await supabase
      .from('pedidos')
      .select('cliente_id')
      .gte('data_pedido', mesAtras);

    const clientesComPedidosIds = clientesComPedidos?.map(p => p.cliente_id) || [];

    // Depois buscar clientes ativos que NÃO estão na lista
    const { count: clientesInativos } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'ativo')
      .not('id', 'in', `(${clientesComPedidosIds.join(',') || '0'})`);

    if (clientesInativos && clientesInativos > 10) {
      alertas.push({
        id: alertas.length + 1,
        tipo: 'cliente_inativo',
        titulo: 'Clientes Inativos',
        descricao: `${clientesInativos} clientes sem pedidos há mais de 30 dias`,
        prioridade: 'baixa'
      });
    }

    // 9. PEDIDOS AGENDADOS PARA HOJE (Prioridade Baixa)
    const { count: pedidosAgendados } = await supabase
      .from('pedidos')
      .select('*', { count: 'exact', head: true })
      .eq('data_entrega_prevista', hoje)
      .eq('tipo', 'encomenda')
      .not('status', 'in', '(entregue,concluido,cancelado)');

    if (pedidosAgendados && pedidosAgendados > 0) {
      alertas.push({
        id: alertas.length + 1,
        tipo: 'pedido_agendado',
        titulo: 'Pedidos Agendados',
        descricao: `${pedidosAgendados} pedido(s) para entregar hoje`,
        prioridade: 'baixa'
      });
    }

    // Ordenar por prioridade (alta -> média -> baixa) e limitar a 8 alertas
    const prioridadeOrdem = { 'alta': 1, 'media': 2, 'baixa': 3 };
    return alertas
      .sort((a, b) => prioridadeOrdem[a.prioridade] - prioridadeOrdem[b.prioridade])
      .slice(0, 8);

  } catch (error) {
    console.error('Erro ao buscar alertas:', error);
    return [];
  }
}