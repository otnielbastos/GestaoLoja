import { supabase } from '../lib/supabase';
import { authService } from './supabaseAuth';

interface RelatorioDashboard {
  receita_total: number;
  total_pedidos: number;
  ticket_medio: number;
  taxa_conversao: number;
  receita_anterior: number;
  pedidos_anterior: number;
  ticket_medio_anterior: number;
  taxa_conversao_anterior: number;
  crescimento_receita: number;
  crescimento_pedidos: number;
  crescimento_ticket: number;
}

interface VendasPorDia {
  day: string;
  vendas: number;
  pedidos: number;
}

interface TopProduto {
  name: string;
  sold: number;
  revenue: string;
}

interface MetodoPagamento {
  name: string;
  value: number;
  color: string;
}

interface PedidoPorBairro {
  name: string;
  orders: number;
  percentage: number;
}

interface VendaPorPeriodo {
  periodo: string;
  total_vendas: number;
  quantidade_pedidos: number;
}

interface ProdutoMaisVendido {
  nome: string;
  quantidade_vendida: number;
  receita_total: number;
}

interface TopComprador {
  nome: string;
  total_gasto: number;
  quantidade_pedidos: number;
}

// Helper para calcular período anterior
const obterPeriodoAnterior = (dias: number) => {
  const hoje = new Date();
  const inicioAtual = new Date(hoje);
  inicioAtual.setDate(hoje.getDate() - dias);
  
  const fimAnterior = new Date(inicioAtual);
  fimAnterior.setDate(fimAnterior.getDate() - 1);
  
  const inicioAnterior = new Date(fimAnterior);
  inicioAnterior.setDate(fimAnterior.getDate() - dias);
  
  return {
    inicio_atual: inicioAtual.toISOString(),
    fim_atual: hoje.toISOString(),
    inicio_anterior: inicioAnterior.toISOString(),
    fim_anterior: fimAnterior.toISOString()
  };
};

// Helper para obter dias da semana
const obterDiasSemana = (): string[] => {
  const hoje = new Date();
  const dias: string[] = [];
  
  for (let i = 6; i >= 0; i--) {
    const data = new Date(hoje);
    data.setDate(hoje.getDate() - i);
    const diaSemana = data.toLocaleDateString('pt-BR', { weekday: 'short' });
    dias.push(diaSemana.charAt(0).toUpperCase() + diaSemana.slice(1, 3));
  }
  
  return dias;
};

// Função auxiliar para buscar bairros da tabela entregas
const buscarBairrosDeEntregas = async (
  dataInicio: Date,
  isVendedor: boolean,
  userId?: number
): Promise<PedidoPorBairro[]> => {
  try {
    let queryEntregas = supabase
      .from('entregas')
      .select(`
        endereco_entrega_bairro,
        pedido:pedidos!inner(data_pedido, status, criado_por)
      `)
      .gte('pedido.data_pedido', dataInicio.toISOString())
      .not('endereco_entrega_bairro', 'is', null)
      .neq('endereco_entrega_bairro', '');
    
    // REGRA DE NEGÓCIO: Vendedor só vê seus dados
    if (isVendedor && userId) {
      queryEntregas = queryEntregas.eq('pedido.criado_por', userId);
    }
    
    const { data: entregas, error: errorEntregas } = await queryEntregas;
    
    if (errorEntregas) {
      console.error('❌ Erro ao buscar entregas:', errorEntregas);
      return []; // Retornar array vazio em caso de erro
    }
    
    if (!entregas || entregas.length === 0) {
      return []; // Retornar array vazio se não houver dados
    }
    
    // Processar dados de entregas
    const contadores = new Map<string, number>();
    entregas.forEach((entrega: any) => {
      const bairro = entrega.endereco_entrega_bairro?.trim();
      if (bairro && bairro !== '') {
        contadores.set(bairro, (contadores.get(bairro) || 0) + 1);
      }
    });
    
    const total = entregas.length;
    const pedidosPorBairro: PedidoPorBairro[] = Array.from(contadores.entries())
      .map(([bairro, count]) => ({
        name: bairro,
        orders: count,
        percentage: total > 0 ? Math.round((count / total) * 100) : 0
      }))
      .sort((a, b) => b.orders - a.orders)
      .slice(0, 4);
    
    return pedidosPorBairro;
  } catch (error) {
    console.error('❌ Erro ao buscar bairros de entregas:', error);
    return [];
  }
};

export const relatoriosService = {
  // Buscar dados do dashboard principal
  async obterDashboard(periodo: string = '7d'): Promise<RelatorioDashboard> {
    try {
      let dias = 7;
      
      switch (periodo) {
        case '30d':
          dias = 30;
          break;
        case 'month':
          dias = 30;
          break;
        default:
          dias = 7;
      }
      
      const { inicio_atual, fim_atual, inicio_anterior, fim_anterior } = obterPeriodoAnterior(dias);
      
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      // Base queries
      let pedidosAtuaisQuery = supabase
        .from('pedidos')
        .select('valor_total, status, data_pedido')
        .gte('data_pedido', inicio_atual)
        .lte('data_pedido', fim_atual)
        .in('status', ['entregue', 'concluido']);
      
      let pedidosAnterioresQuery = supabase
        .from('pedidos')
        .select('valor_total, status, data_pedido')
        .gte('data_pedido', inicio_anterior)
        .lte('data_pedido', fim_anterior)
        .in('status', ['entregue', 'concluido']);
      
      // REGRA DE NEGÓCIO: Vendedor só vê seus dados
      if (isVendedor && user?.id) {
        pedidosAtuaisQuery = pedidosAtuaisQuery.eq('criado_por', user.id);
        pedidosAnterioresQuery = pedidosAnterioresQuery.eq('criado_por', user.id);
      }
      
      // Buscar pedidos do período atual
      const { data: pedidosAtuais, error: errorAtuais } = await pedidosAtuaisQuery;
      
      if (errorAtuais) throw errorAtuais;
      
      // Buscar pedidos do período anterior
      const { data: pedidosAnteriores, error: errorAnteriores } = await pedidosAnterioresQuery;
      
      if (errorAnteriores) throw errorAnteriores;
      
      // Calcular métricas atuais
      const receita_total = pedidosAtuais?.reduce((sum, p) => sum + (p.valor_total || 0), 0) || 0;
      const total_pedidos = pedidosAtuais?.length || 0;
      const ticket_medio = total_pedidos > 0 ? receita_total / total_pedidos : 0;
      
      // Calcular métricas anteriores
      const receita_anterior = pedidosAnteriores?.reduce((sum, p) => sum + (p.valor_total || 0), 0) || 0;
      const pedidos_anterior = pedidosAnteriores?.length || 0;
      const ticket_medio_anterior = pedidos_anterior > 0 ? receita_anterior / pedidos_anterior : 0;
      
      // Calcular crescimento
      const crescimento_receita = receita_anterior > 0 
        ? ((receita_total - receita_anterior) / receita_anterior) * 100 
        : receita_total > 0 ? 100 : 0;
      
      const crescimento_pedidos = pedidos_anterior > 0 
        ? ((total_pedidos - pedidos_anterior) / pedidos_anterior) * 100 
        : total_pedidos > 0 ? 100 : 0;
      
      const crescimento_ticket = ticket_medio_anterior > 0 
        ? ((ticket_medio - ticket_medio_anterior) / ticket_medio_anterior) * 100 
        : ticket_medio > 0 ? 100 : 0;

      return {
        receita_total,
        total_pedidos,
        ticket_medio,
        taxa_conversao: 0, // Placeholder - pode ser calculado se necessário
        receita_anterior,
        pedidos_anterior,
        ticket_medio_anterior,
        taxa_conversao_anterior: 0, // Placeholder - pode ser calculado se necessário
        crescimento_receita,
        crescimento_pedidos,
        crescimento_ticket
      };
      
    } catch (error: any) {
      console.error('Erro ao obter dados do dashboard:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar vendas por dia
  async obterVendasPorDia(): Promise<VendasPorDia[]> {
    try {
      const hoje = new Date();
      const seteDiasAtras = new Date(hoje);
      seteDiasAtras.setDate(hoje.getDate() - 7);
      
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      let query = supabase
        .from('pedidos')
        .select('valor_total, data_pedido')
        .gte('data_pedido', seteDiasAtras.toISOString())
        .lte('data_pedido', hoje.toISOString())
        .in('status', ['entregue', 'concluido']);
      
      // REGRA DE NEGÓCIO: Vendedor só vê seus dados
      if (isVendedor && user?.id) {
        query = query.eq('criado_por', user.id);
      }
      
      const { data: pedidos, error } = await query;
      
      if (error) throw error;
      
      const diasSemana = obterDiasSemana();
      const vendasPorDia: VendasPorDia[] = [];
      
      diasSemana.forEach((dia, index) => {
        const dataAtual = new Date(hoje);
        dataAtual.setDate(hoje.getDate() - (6 - index));
        
        const pedidosDoDia = pedidos?.filter(p => {
          const dataPedido = new Date(p.data_pedido);
          return dataPedido.toDateString() === dataAtual.toDateString();
        }) || [];
        
        const vendas = pedidosDoDia.reduce((sum, p) => sum + (p.valor_total || 0), 0);
        const numeroPedidos = pedidosDoDia.length;
        
        vendasPorDia.push({
          day: dia,
          vendas: Math.round(vendas),
          pedidos: numeroPedidos
        });
      });
      
      // Se não houver dados, retornar dados de exemplo
      if (vendasPorDia.every(dia => dia.vendas === 0)) {
        return [
          { day: "Seg", vendas: 180, pedidos: 12 },
          { day: "Ter", vendas: 240, pedidos: 18 },
          { day: "Qua", vendas: 320, pedidos: 22 },
          { day: "Qui", vendas: 280, pedidos: 15 },
          { day: "Sex", vendas: 450, pedidos: 28 },
          { day: "Sáb", vendas: 520, pedidos: 35 },
          { day: "Dom", vendas: 380, pedidos: 25 },
        ];
      }
      
      return vendasPorDia;
      
    } catch (error) {
      console.error('Erro ao obter vendas por dia:', error);
      throw new Error('Erro ao carregar vendas por dia');
    }
  },

  // Buscar produtos mais vendidos
  async obterTopProdutos(): Promise<TopProduto[]> {
    try {
      // Primeiro, tentar uma consulta simples sem relacionamentos
      const { data: itensPedidos, error } = await supabase
        .from('itens_pedido')
        .select('*');
      
      if (error) {
        console.error('Erro ao buscar itens de pedidos:', error);
        throw error;
      }
      
      if (!itensPedidos || itensPedidos.length === 0) {
        return [
          { name: "Pão Francês", sold: 156, revenue: "R$ 109,20" },
          { name: "Refrigerante 2L", sold: 45, revenue: "R$ 400,50" },
          { name: "Leite 1L", sold: 38, revenue: "R$ 220,40" },
          { name: "Açúcar 1kg", sold: 28, revenue: "R$ 126,00" },
        ];
      }
      
      // Se conseguiu buscar os dados, precisa fazer joins manuais
      const { data: produtos, error: produtosError } = await supabase
        .from('produtos')
        .select('id, nome');
      
      if (produtosError) {
        console.error('Erro ao buscar produtos:', produtosError);
        throw produtosError;
      }
      
      // Agrupar por produto_id
      const produtosMap = new Map();
      
      itensPedidos.forEach(item => {
        const produto = produtos?.find(p => p.id === item.produto_id);
        const nomeProduto = produto?.nome || `Produto ID ${item.produto_id}`;
        
        if (produtosMap.has(nomeProduto)) {
          const existing = produtosMap.get(nomeProduto);
          existing.sold += item.quantidade || 0;
          existing.revenue += item.subtotal || 0;
        } else {
          produtosMap.set(nomeProduto, {
            name: nomeProduto,
            sold: item.quantidade || 0,
            revenue: item.subtotal || 0
          });
        }
      });
      
      // Converter para array e ordenar
      const topProdutos = Array.from(produtosMap.values())
        .sort((a, b) => b.sold - a.sold)
        .slice(0, 4)
        .map(produto => ({
          ...produto,
          revenue: `R$ ${produto.revenue.toFixed(2).replace('.', ',')}`
        }));
      
      // Se não houver produtos, retornar dados de exemplo
      if (topProdutos.length === 0) {
        return [
          { name: "Pão Francês", sold: 156, revenue: "R$ 109,20" },
          { name: "Refrigerante 2L", sold: 45, revenue: "R$ 400,50" },
          { name: "Leite 1L", sold: 38, revenue: "R$ 220,40" },
          { name: "Açúcar 1kg", sold: 28, revenue: "R$ 126,00" },
        ];
      }
      
      return topProdutos;
      
    } catch (error) {
      console.error('Erro ao obter top produtos:', error);
      throw new Error('Erro ao carregar produtos mais vendidos');
    }
  },

  // Buscar métodos de pagamento
  async obterMetodosPagamento(): Promise<MetodoPagamento[]> {
    try {
      const { data: pedidos, error } = await supabase
        .from('pedidos')
        .select('forma_pagamento')
        .gte('data_pedido', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
        .in('status', ['entregue', 'concluido']);
      
      if (error) throw error;
      
      // Contar métodos de pagamento
      const contadores = new Map();
      const total = pedidos?.length || 0;
      
      pedidos?.forEach(pedido => {
        const metodo = pedido.forma_pagamento || 'Não informado';
        contadores.set(metodo, (contadores.get(metodo) || 0) + 1);
      });
      
      // Converter para array com percentuais e cores
      const cores = {
        'PIX': '#10B981',
        'Cartão de Crédito': '#3B82F6',
        'Cartão Crédito': '#3B82F6',
        'Dinheiro': '#F59E0B',
        'Cartão de Débito': '#EF4444',
        'Cartão Débito': '#EF4444',
      };
      
      const metodosPagamento: MetodoPagamento[] = Array.from(contadores.entries())
        .map(([metodo, count]) => ({
          name: metodo,
          value: Math.round((count / total) * 100),
          color: cores[metodo as keyof typeof cores] || '#6B7280'
        }))
        .sort((a, b) => b.value - a.value);
      
      // Se não houver dados, retornar dados de exemplo
      if (metodosPagamento.length === 0) {
        return [
          { name: "PIX", value: 45, color: "#10B981" },
          { name: "Cartão Crédito", value: 30, color: "#3B82F6" },
          { name: "Dinheiro", value: 20, color: "#F59E0B" },
          { name: "Cartão Débito", value: 5, color: "#EF4444" },
        ];
      }
      
      return metodosPagamento;
      
    } catch (error) {
      console.error('Erro ao obter métodos de pagamento:', error);
      throw new Error('Erro ao carregar métodos de pagamento');
    }
  },

  // Buscar pedidos por bairro
  async obterPedidosPorBairro(): Promise<PedidoPorBairro[]> {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      // Buscar pedidos dos últimos 30 dias com endereço de entrega
      const ultimosMesDias = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      
      // Primeiro, tentar buscar da tabela pedidos (se o campo existir)
      let query = supabase
        .from('pedidos')
        .select('endereco_entrega_bairro, data_pedido, status, numero_pedido, criado_por')
        .gte('data_pedido', ultimosMesDias.toISOString());
      
      // REGRA DE NEGÓCIO: Vendedor só vê seus dados
      if (isVendedor && user?.id) {
        query = query.eq('criado_por', user.id);
      }
      
      const { data: pedidos, error } = await query;
      
      if (error) {
        console.error('❌ Erro ao buscar pedidos:', error);
        // Se o campo não existir na tabela pedidos, tentar buscar da tabela entregas
        console.log('Tentando buscar da tabela entregas...');
        return await buscarBairrosDeEntregas(ultimosMesDias, isVendedor, user?.id);
      }
      
      if (!pedidos || pedidos.length === 0) {
        // Se não houver pedidos, tentar buscar da tabela entregas
        return await buscarBairrosDeEntregas(ultimosMesDias, isVendedor, user?.id);
      }
      
      // Filtrar pedidos com bairro válido
      const pedidosComBairro = pedidos.filter(p => 
        p.endereco_entrega_bairro && 
        p.endereco_entrega_bairro.trim() !== ''
      );
      
      if (pedidosComBairro.length === 0) {
        // Se não houver pedidos com bairro, tentar buscar da tabela entregas
        return await buscarBairrosDeEntregas(ultimosMesDias, isVendedor, user?.id);
      }
      
      // Contar pedidos por bairro
      const contadores = new Map<string, number>();
      pedidosComBairro.forEach(pedido => {
        const bairro = pedido.endereco_entrega_bairro?.trim() || 'Não informado';
        if (bairro !== 'Não informado') {
          contadores.set(bairro, (contadores.get(bairro) || 0) + 1);
        }
      });
      
      const total = pedidosComBairro.length;
      
      // Converter para array com percentuais
      const pedidosPorBairro: PedidoPorBairro[] = Array.from(contadores.entries())
        .map(([bairro, count]) => ({
          name: bairro,
          orders: count,
          percentage: total > 0 ? Math.round((count / total) * 100) : 0
        }))
        .sort((a, b) => b.orders - a.orders)
        .slice(0, 4); // Top 4 bairros
      
      return pedidosPorBairro;
      
    } catch (error) {
      console.error('❌ Erro ao obter pedidos por bairro:', error);
      return []; // Retornar array vazio em caso de erro
    }
  },

  // Obter vendas por período
  async obterVendasPorPeriodo(
    dataInicio: string, 
    dataFim: string, 
    agruparPor: 'dia' | 'semana' | 'mes' = 'dia'
  ): Promise<VendaPorPeriodo[]> {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      let query = supabase
        .from('pedidos')
        .select('data_pedido, valor_total')
        .gte('data_pedido', dataInicio)
        .lte('data_pedido', dataFim)
        .in('status', ['entregue', 'concluido']);
      
      // REGRA DE NEGÓCIO: Vendedor só vê seus dados
      if (isVendedor && user?.id) {
        query = query.eq('criado_por', user.id);
      }
      
      const { data: pedidos, error } = await query;
      
      if (error) throw error;
      
      // Agrupar dados por período
      const vendas: { [key: string]: VendaPorPeriodo } = {};
      
      pedidos?.forEach(pedido => {
        const data = new Date(pedido.data_pedido);
        let chave: string;
        
        switch (agruparPor) {
          case 'semana':
            const inicioSemana = new Date(data);
            inicioSemana.setDate(data.getDate() - data.getDay());
            chave = inicioSemana.toISOString().split('T')[0];
            break;
          case 'mes':
            chave = `${data.getFullYear()}-${String(data.getMonth() + 1).padStart(2, '0')}`;
            break;
          default:
            chave = pedido.data_pedido.split('T')[0];
        }
        
        if (!vendas[chave]) {
          vendas[chave] = {
            periodo: chave,
            total_vendas: 0,
            quantidade_pedidos: 0
          };
        }
        
        vendas[chave].total_vendas += pedido.valor_total || 0;
        vendas[chave].quantidade_pedidos += 1;
      });
      
      return Object.values(vendas).sort((a, b) => a.periodo.localeCompare(b.periodo));
      
    } catch (error: any) {
      console.error('Erro ao obter vendas por período:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Obter produtos mais vendidos
  async obterProdutosMaisVendidos(dataInicio: string, dataFim: string, limite: number = 10): Promise<ProdutoMaisVendido[]> {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      let query = supabase
        .from('itens_pedido')
        .select(`
          quantidade,
          subtotal,
          produto:produtos(nome),
          pedido:pedidos!inner(data_pedido, status)
        `)
        .gte('pedido.data_pedido', dataInicio)
        .lte('pedido.data_pedido', dataFim)
        .in('pedido.status', ['entregue', 'concluido']);
      
      // REGRA DE NEGÓCIO: Vendedor só vê dados dos seus pedidos
      if (isVendedor && user?.id) {
        query = query.eq('pedido.criado_por', user.id);
      }
      
      const { data: itens, error } = await query;
      
      if (error) throw error;
      
      // Agrupar por produto
      const produtos: { [key: string]: ProdutoMaisVendido } = {};
      
      itens?.forEach(item => {
        const nomeProduto = (item.produto as any)?.nome || 'Produto não encontrado';
        
        if (!produtos[nomeProduto]) {
          produtos[nomeProduto] = {
            nome: nomeProduto,
            quantidade_vendida: 0,
            receita_total: 0
          };
        }
        
        produtos[nomeProduto].quantidade_vendida += item.quantidade || 0;
        produtos[nomeProduto].receita_total += item.subtotal || 0;
      });
      
      return Object.values(produtos)
        .sort((a, b) => b.quantidade_vendida - a.quantidade_vendida)
        .slice(0, limite);
      
    } catch (error: any) {
      console.error('Erro ao obter produtos mais vendidos:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Obter clientes que mais compraram
  async obterClientesTopCompradores(dataInicio: string, dataFim: string, limite: number = 10): Promise<TopComprador[]> {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      let query = supabase
        .from('pedidos')
        .select(`
          valor_total,
          cliente:clientes(nome)
        `)
        .gte('data_pedido', dataInicio)
        .lte('data_pedido', dataFim)
        .in('status', ['entregue', 'concluido']);
      
      // REGRA DE NEGÓCIO: Vendedor só vê dados dos seus pedidos/clientes
      if (isVendedor && user?.id) {
        query = query.eq('criado_por', user.id);
      }
      
      const { data: pedidos, error } = await query;
      
      if (error) throw error;
      
      // Agrupar por cliente
      const clientes: { [key: string]: TopComprador } = {};
      
      pedidos?.forEach(pedido => {
        const nomeCliente = (pedido.cliente as any)?.nome || 'Cliente não encontrado';
        
        if (!clientes[nomeCliente]) {
          clientes[nomeCliente] = {
            nome: nomeCliente,
            total_gasto: 0,
            quantidade_pedidos: 0
          };
        }
        
        clientes[nomeCliente].total_gasto += pedido.valor_total || 0;
        clientes[nomeCliente].quantidade_pedidos += 1;
      });
      
      return Object.values(clientes)
        .sort((a, b) => b.total_gasto - a.total_gasto)
        .slice(0, limite);
      
    } catch (error: any) {
      console.error('Erro ao obter clientes top compradores:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  }
}; 