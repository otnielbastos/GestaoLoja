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

interface RelatorioFinanceiro {
  valor_total_pedidos: number; // Valor original (antes do desconto)
  valor_desconto_total: number; // Total de descontos aplicados
  valor_final_pedidos: number; // Valor final a pagar (original - desconto)
  valor_pago: number;
  valor_pendente: number;
  quantidade_pedidos: number;
  quantidade_entregue: number;
  quantidade_pendente: number;
  quantidade_cancelado?: number;
  ticket_medio?: number;
  percentual_pago?: number;
  percentual_pendente?: number;
  percentual_desconto_total?: number;
}

// Helper para calcular período anterior (baseado em dias)
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

// Helper para calcular período do mês atual
const obterPeriodoMesAtual = () => {
  const hoje = new Date();
  const primeiroDiaMes = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
  
  // Período anterior: mês passado completo
  const primeiroDiaMesAnterior = new Date(hoje.getFullYear(), hoje.getMonth() - 1, 1);
  const ultimoDiaMesAnterior = new Date(hoje.getFullYear(), hoje.getMonth(), 0);
  
  return {
    inicio_atual: primeiroDiaMes.toISOString(),
    fim_atual: hoje.toISOString(),
    inicio_anterior: primeiroDiaMesAnterior.toISOString(),
    fim_anterior: ultimoDiaMesAnterior.toISOString()
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
    // Primeiro, buscar todas as entregas com bairro válido
    let queryEntregas = supabase
      .from('entregas')
      .select(`
        id,
        pedido_id,
        endereco_entrega_bairro,
        pedido:pedidos!inner(id, data_pedido, status, criado_por)
      `)
      .not('endereco_entrega_bairro', 'is', null)
      .neq('endereco_entrega_bairro', '');
    
    const { data: entregas, error: errorEntregas } = await queryEntregas;
    
    if (errorEntregas) {
      console.error('❌ Erro ao buscar entregas:', errorEntregas);
      return []; // Retornar array vazio em caso de erro
    }
    
    if (!entregas || entregas.length === 0) {
      console.log('Nenhuma entrega encontrada na tabela entregas');
      return []; // Retornar array vazio se não houver dados
    }
    
    // Filtrar entregas por data e vendedor
    const entregasFiltradas = entregas.filter((entrega: any) => {
      const pedido = entrega.pedido;
      if (!pedido) return false;
      
      // Filtrar por data
      const dataPedido = new Date(pedido.data_pedido);
      if (dataPedido < dataInicio) return false;
      
      // Filtrar por vendedor se necessário
      if (isVendedor && userId && pedido.criado_por !== userId) {
        return false;
      }
      
      return true;
    });
    
    if (entregasFiltradas.length === 0) {
      console.log('Nenhuma entrega encontrada após filtros (data/vendedor)');
      return [];
    }
    
    // Processar dados de entregas
    const contadores = new Map<string, number>();
    entregasFiltradas.forEach((entrega: any) => {
      const bairro = entrega.endereco_entrega_bairro?.trim();
      if (bairro && bairro !== '') {
        contadores.set(bairro, (contadores.get(bairro) || 0) + 1);
      }
    });
    
    const total = entregasFiltradas.length;
    const pedidosPorBairro: PedidoPorBairro[] = Array.from(contadores.entries())
      .map(([bairro, count]) => ({
        name: bairro,
        orders: count,
        percentage: total > 0 ? Math.round((count / total) * 100) : 0
      }))
      .sort((a, b) => b.orders - a.orders)
      .slice(0, 4);
    
    console.log(`✅ Encontrados ${pedidosPorBairro.length} bairros na tabela entregas`);
    return pedidosPorBairro;
  } catch (error) {
    console.error('❌ Erro ao buscar bairros de entregas:', error);
    return [];
  }
};

export const relatoriosService = {
  // Buscar dados do dashboard principal
  async obterDashboard(periodo: string = '7d', dataInicio?: string, dataFim?: string): Promise<RelatorioDashboard> {
    try {
      let periodoCalculado;
      
      // Se for período personalizado, usar as datas fornecidas
      if (periodo === 'custom' && dataInicio && dataFim) {
        const inicio = new Date(dataInicio);
        const fim = new Date(dataFim);
        fim.setHours(23, 59, 59, 999);
        
        // Calcular período anterior com a mesma duração
        const duracao = fim.getTime() - inicio.getTime();
        const inicioAnterior = new Date(inicio.getTime() - duracao);
        const fimAnterior = new Date(inicio.getTime() - 1);
        
        periodoCalculado = {
          inicio_atual: inicio.toISOString(),
          fim_atual: fim.toISOString(),
          inicio_anterior: inicioAnterior.toISOString(),
          fim_anterior: fimAnterior.toISOString()
        };
      } else {
        switch (periodo) {
          case '30d':
            periodoCalculado = obterPeriodoAnterior(30);
            break;
          case 'month':
            periodoCalculado = obterPeriodoMesAtual();
            break;
          default:
            periodoCalculado = obterPeriodoAnterior(7);
        }
      }
      
      const { inicio_atual, fim_atual, inicio_anterior, fim_anterior } = periodoCalculado;
      
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
  async obterVendasPorDia(periodo: string = '7d', dataInicio?: string, dataFim?: string): Promise<VendasPorDia[]> {
    try {
      const hoje = new Date();
      let inicioPeriodo: Date;
      let fimPeriodo: Date = hoje;
      
      // Se for período personalizado, usar as datas fornecidas
      if (periodo === 'custom' && dataInicio && dataFim) {
        inicioPeriodo = new Date(dataInicio);
        fimPeriodo = new Date(dataFim);
        fimPeriodo.setHours(23, 59, 59, 999);
      } else {
        // Calcular período baseado no parâmetro
        switch (periodo) {
          case '30d':
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 30);
            break;
          case 'month':
            inicioPeriodo = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
            break;
          default: // 7d
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 7);
        }
      }
      
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      // Buscar TODOS os pedidos do período (sem filtrar por status)
      // Incluir pedidos pagos mesmo que não estejam entregues
      let query = supabase
        .from('pedidos')
        .select('id, valor_total, data_pedido, status, status_pagamento, forma_pagamento')
        .gte('data_pedido', inicioPeriodo.toISOString())
        .lte('data_pedido', fimPeriodo.toISOString())
        .neq('status', 'cancelado'); // Apenas excluir cancelados
      
      // REGRA DE NEGÓCIO: Vendedor só vê seus dados
      if (isVendedor && user?.id) {
        query = query.eq('criado_por', user.id);
      }
      
      const { data: pedidos, error } = await query;
      
      if (error) throw error;
      
      // Debug: verificar dados retornados
      console.log(`📊 Vendas por Dia - Período: ${periodo}`);
      console.log(`📊 Data início: ${inicioPeriodo.toISOString()}, Data fim: ${fimPeriodo.toISOString()}`);
      console.log(`📊 Pedidos encontrados:`, pedidos?.length || 0);
      if (pedidos && pedidos.length > 0) {
        console.log('📊 Vendas por dia - Todos os pedidos:', pedidos.map(p => ({ 
          id: p.id || 'N/A',
          data: p.data_pedido, 
          valor: p.valor_total,
          status: p.status,
          status_pagamento: p.status_pagamento,
          forma_pagamento: p.forma_pagamento
        })));
      } else {
        console.warn('⚠️ Nenhum pedido encontrado no período!');
      }
      
      // Agrupar pedidos por dia primeiro
      const pedidosPorData = new Map<string, { vendas: number; pedidos: number; data: Date }>();
      
      pedidos?.forEach(p => {
        if (!p.data_pedido) return;
        const dataPedido = new Date(p.data_pedido);
        // Normalizar para apenas data (sem hora)
        const dataNormalizada = new Date(dataPedido.getFullYear(), dataPedido.getMonth(), dataPedido.getDate());
        const dataKey = dataNormalizada.toISOString().split('T')[0]; // YYYY-MM-DD
        
        if (pedidosPorData.has(dataKey)) {
          const existing = pedidosPorData.get(dataKey)!;
          existing.vendas += p.valor_total || 0;
          existing.pedidos += 1;
        } else {
          pedidosPorData.set(dataKey, {
            vendas: p.valor_total || 0,
            pedidos: 1,
            data: dataNormalizada
          });
        }
      });
      
      // Calcular duração do período em dias
      const duracaoDias = Math.ceil((fimPeriodo.getTime() - inicioPeriodo.getTime()) / (1000 * 60 * 60 * 24));
      
      console.log(`📊 Duração do período: ${duracaoDias} dias`);
      console.log('📊 Datas com pedidos encontradas:', Array.from(pedidosPorData.keys()).sort());
      
      const vendasPorDia: VendasPorDia[] = [];
      
      // Para períodos longos (mais de 60 dias), agrupar por semana
      // Para períodos médios (15-60 dias), mostrar todos os dias
      // Para períodos curtos (menos de 15 dias), mostrar todos os dias
      
      if (duracaoDias > 60) {
        // Agrupar por semana para períodos muito longos
        const vendasPorSemana = new Map<string, { vendas: number; pedidos: number; semanaInicio: Date }>();
        
        pedidosPorData.forEach((dados, dataKey) => {
          const data = new Date(dataKey + 'T00:00:00');
          if (data < inicioPeriodo || data > fimPeriodo) return;
          
          // Calcular início da semana (domingo)
          const inicioSemana = new Date(data);
          const diaSemana = inicioSemana.getDay();
          inicioSemana.setDate(inicioSemana.getDate() - diaSemana);
          inicioSemana.setHours(0, 0, 0, 0);
          
          const semanaKey = inicioSemana.toISOString().split('T')[0];
          
          if (vendasPorSemana.has(semanaKey)) {
            const existing = vendasPorSemana.get(semanaKey)!;
            existing.vendas += dados.vendas;
            existing.pedidos += dados.pedidos;
          } else {
            vendasPorSemana.set(semanaKey, {
              vendas: dados.vendas,
              pedidos: dados.pedidos,
              semanaInicio: inicioSemana
            });
          }
        });
        
        // Criar array de todas as semanas do período
        const semanas: Date[] = [];
        let dataAtual = new Date(inicioPeriodo);
        while (dataAtual <= fimPeriodo) {
          const inicioSemana = new Date(dataAtual);
          const diaSemana = inicioSemana.getDay();
          inicioSemana.setDate(inicioSemana.getDate() - diaSemana);
          inicioSemana.setHours(0, 0, 0, 0);
          
          if (!semanas.find(s => s.getTime() === inicioSemana.getTime())) {
            semanas.push(new Date(inicioSemana));
          }
          
          dataAtual.setDate(dataAtual.getDate() + 7);
        }
        
        semanas.sort((a, b) => a.getTime() - b.getTime());
        
        semanas.forEach(semanaInicio => {
          const semanaKey = semanaInicio.toISOString().split('T')[0];
          const dados = vendasPorSemana.get(semanaKey) || { vendas: 0, pedidos: 0, semanaInicio };
          
          const semanaFim = new Date(semanaInicio);
          semanaFim.setDate(semanaFim.getDate() + 6);
          
          const label = `${semanaInicio.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' })} - ${semanaFim.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' })}`;
          
          vendasPorDia.push({
            day: label,
            vendas: Math.round(dados.vendas),
            pedidos: dados.pedidos
          });
        });
      } else {
        // Mostrar todos os dias do período
        const todasAsDatas: Date[] = [];
        let dataAtual = new Date(inicioPeriodo);
        
        while (dataAtual <= fimPeriodo) {
          todasAsDatas.push(new Date(dataAtual));
          dataAtual.setDate(dataAtual.getDate() + 1);
        }
        
        todasAsDatas.forEach(dataAtual => {
          const dataKey = dataAtual.toISOString().split('T')[0];
          const dados = pedidosPorData.get(dataKey) || { vendas: 0, pedidos: 0 };
          
          const diaSemana = dataAtual.toLocaleDateString('pt-BR', { weekday: 'short' });
          const diaMes = dataAtual.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
          const diaLabel = (diaSemana.charAt(0).toUpperCase() + diaSemana.slice(1, 3)) + ' ' + diaMes;
          
          vendasPorDia.push({
            day: diaLabel,
            vendas: Math.round(dados.vendas),
            pedidos: dados.pedidos
          });
        });
      }
      
      console.log('📊 Total de pontos no gráfico:', vendasPorDia.length);
      console.log('📊 Primeiro ponto:', vendasPorDia[0]);
      console.log('📊 Último ponto:', vendasPorDia[vendasPorDia.length - 1]);
      
      console.log('📊 Vendas por dia processadas (últimos 7 dias):', vendasPorDia);
      console.log('📊 Detalhes dos dias:', vendasPorDia.map(v => `${v.day}: ${v.pedidos} pedidos, R$ ${v.vendas}`));
      console.log('📊 Total de pedidos no período:', pedidos?.length || 0);
      console.log('📊 Período selecionado:', periodo, '- Início:', inicioPeriodo.toISOString(), '- Fim:', fimPeriodo.toISOString());
      
      // Debug: mostrar datas dos pedidos encontrados
      if (pedidos && pedidos.length > 0) {
        const datasPedidos = pedidos.map(p => {
          const data = new Date(p.data_pedido);
          return data.toLocaleDateString('pt-BR') + ' ' + data.toLocaleTimeString('pt-BR');
        });
        console.log('📊 Datas dos pedidos encontrados:', datasPedidos);
      }
      
      // Sempre retornar dados reais (mesmo que sejam zeros)
      return vendasPorDia;
      
    } catch (error) {
      console.error('Erro ao obter vendas por dia:', error);
      throw new Error('Erro ao carregar vendas por dia');
    }
  },

  // Buscar produtos mais vendidos
  async obterTopProdutos(periodo: string = '30d', dataInicio?: string, dataFim?: string): Promise<TopProduto[]> {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      const hoje = new Date();
      let inicioPeriodo: Date;
      let fimPeriodo: Date = hoje;
      
      // Se for período personalizado, usar as datas fornecidas
      if (periodo === 'custom' && dataInicio && dataFim) {
        inicioPeriodo = new Date(dataInicio);
        fimPeriodo = new Date(dataFim);
        fimPeriodo.setHours(23, 59, 59, 999);
      } else {
        // Calcular período baseado no parâmetro
        switch (periodo) {
          case '7d':
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 7);
            break;
          case 'month':
            inicioPeriodo = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
            break;
          default: // 30d
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 30);
        }
      }
      
      // Buscar itens de pedidos com filtro de data
      let query = supabase
        .from('itens_pedido')
        .select(`
          quantidade,
          subtotal,
          produto_id,
          pedido:pedidos!inner(data_pedido, status, criado_por)
        `)
        .gte('pedido.data_pedido', inicioPeriodo.toISOString())
        .lte('pedido.data_pedido', fimPeriodo.toISOString())
        .in('pedido.status', ['entregue', 'concluido', 'em_entrega', 'pronto', 'em_preparo', 'aprovado']);
      
      // REGRA DE NEGÓCIO: Vendedor só vê dados dos seus pedidos
      if (isVendedor && user?.id) {
        query = query.eq('pedido.criado_por', user.id);
      }
      
      const { data: itensPedidos, error } = await query;
      
      if (error) {
        console.error('Erro ao buscar itens de pedidos:', error);
        throw error;
      }
      
      if (!itensPedidos || itensPedidos.length === 0) {
        return [];
      }
      
      // Buscar nomes dos produtos
      const { data: produtos, error: produtosError } = await supabase
        .from('produtos')
        .select('id, nome');
      
      if (produtosError) {
        console.error('Erro ao buscar produtos:', produtosError);
        throw produtosError;
      }
      
      // Agrupar por produto_id
      const produtosMap = new Map();
      
      itensPedidos.forEach((item: any) => {
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
      
      console.log(`📊 Top Produtos - Período: ${periodo}, Produtos encontrados: ${topProdutos.length}`);
      
      return topProdutos;
      
    } catch (error) {
      console.error('Erro ao obter top produtos:', error);
      throw new Error('Erro ao carregar produtos mais vendidos');
    }
  },

  // Buscar métodos de pagamento
  async obterMetodosPagamento(periodo: string = '30d', dataInicio?: string, dataFim?: string): Promise<MetodoPagamento[]> {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      const hoje = new Date();
      let inicioPeriodo: Date;
      let fimPeriodo: Date = hoje;
      
      // Se for período personalizado, usar as datas fornecidas
      if (periodo === 'custom' && dataInicio && dataFim) {
        inicioPeriodo = new Date(dataInicio);
        fimPeriodo = new Date(dataFim);
        fimPeriodo.setHours(23, 59, 59, 999);
      } else {
        // Calcular período baseado no parâmetro
        switch (periodo) {
          case '30d':
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 30);
            break;
          case 'month':
            inicioPeriodo = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
            break;
          default: // 7d
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 7);
        }
      }
      
      // Buscar TODOS os pedidos do período (sem filtrar por status)
      // Incluir pedidos pagos mesmo que não estejam entregues
      let query = supabase
        .from('pedidos')
        .select('forma_pagamento, valor_total, status_pagamento')
        .gte('data_pedido', inicioPeriodo.toISOString())
        .lte('data_pedido', fimPeriodo.toISOString())
        .neq('status', 'cancelado'); // Apenas excluir cancelados
      
      // REGRA DE NEGÓCIO: Vendedor só vê seus dados
      if (isVendedor && user?.id) {
        query = query.eq('criado_por', user.id);
      }
      
      const { data: pedidos, error } = await query;
      
      if (error) throw error;
      
      // Debug: verificar dados retornados
      console.log(`📊 Métodos de Pagamento - Período: ${periodo}, Pedidos encontrados:`, pedidos?.length || 0);
      if (pedidos && pedidos.length > 0) {
        console.log('📊 Métodos de pagamento encontrados:', pedidos.map(p => ({ metodo: p.forma_pagamento, valor: p.valor_total })));
      }
      
      // Função para normalizar nomes de métodos de pagamento
      const normalizarMetodoPagamento = (metodo: string): string => {
        if (!metodo) return 'Não informado';
        
        const metodoLower = metodo.toLowerCase().trim();
        
        // Normalizar variações de nomes
        if (metodoLower.includes('pix')) return 'PIX';
        if (metodoLower.includes('cartão') && metodoLower.includes('crédito')) return 'Cartão de Crédito';
        if (metodoLower.includes('cartao') && metodoLower.includes('credito')) return 'Cartão de Crédito';
        if (metodoLower.includes('cartão') && metodoLower.includes('débito')) return 'Cartão de Débito';
        if (metodoLower.includes('cartao') && metodoLower.includes('debito')) return 'Cartão de Débito';
        if (metodoLower.includes('dinheiro')) return 'Dinheiro';
        if (metodoLower.includes('credito') && !metodoLower.includes('debito')) return 'Cartão de Crédito';
        if (metodoLower.includes('debito')) return 'Cartão de Débito';
        
        // Retornar o nome original se não houver correspondência
        return metodo.trim();
      };
      
      // Agrupar por método de pagamento e somar valores
      const contadores = new Map<string, { count: number; valor: number }>();
      const totalPedidos = pedidos?.length || 0;
      let valorTotal = 0;
      
      pedidos?.forEach(pedido => {
        const metodoOriginal = pedido.forma_pagamento || 'Não informado';
        const metodo = normalizarMetodoPagamento(metodoOriginal);
        
        // IMPORTANTE: Usar valor_total (valor original, sem desconto)
        const valor = pedido.valor_total || 0;
        valorTotal += valor;
        
        if (contadores.has(metodo)) {
          const existing = contadores.get(metodo)!;
          existing.count += 1;
          existing.valor += valor;
        } else {
          contadores.set(metodo, { count: 1, valor });
        }
      });
      
      // Converter para array com percentuais baseados no valor total
      const cores = {
        'PIX': '#10B981',
        'Cartão de Crédito': '#3B82F6',
        'Cartão Crédito': '#3B82F6',
        'Dinheiro': '#F59E0B',
        'Cartão de Débito': '#EF4444',
        'Cartão Débito': '#EF4444',
      };
      
      const metodosPagamento: MetodoPagamento[] = Array.from(contadores.entries())
        .map(([metodo, dados]) => ({
          name: metodo,
          // Percentual baseado no valor total (não na quantidade)
          value: valorTotal > 0 ? Math.round((dados.valor / valorTotal) * 100) : 0,
          color: cores[metodo as keyof typeof cores] || '#6B7280'
        }))
        .sort((a, b) => b.value - a.value);
      
      // Debug: verificar resultado final
      console.log('📊 Métodos de pagamento agrupados:', metodosPagamento);
      console.log('📊 Valor total:', valorTotal);
      
      // Sempre retornar dados reais (mesmo que seja array vazio)
      return metodosPagamento;
      
    } catch (error) {
      console.error('Erro ao obter métodos de pagamento:', error);
      throw new Error('Erro ao carregar métodos de pagamento');
    }
  },

  // Buscar pedidos por bairro
  async obterPedidosPorBairro(periodo: string = '30d', dataInicio?: string, dataFim?: string): Promise<PedidoPorBairro[]> {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      const hoje = new Date();
      let inicioPeriodo: Date;
      let fimPeriodo: Date = hoje;
      
      // Se for período personalizado, usar as datas fornecidas
      if (periodo === 'custom' && dataInicio && dataFim) {
        inicioPeriodo = new Date(dataInicio);
        fimPeriodo = new Date(dataFim);
        fimPeriodo.setHours(23, 59, 59, 999);
      } else {
        // Calcular período baseado no parâmetro
        switch (periodo) {
          case '7d':
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 7);
            break;
          case 'month':
            inicioPeriodo = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
            break;
          default: // 30d
            inicioPeriodo = new Date(hoje);
            inicioPeriodo.setDate(hoje.getDate() - 30);
        }
      }
      
      const contadores = new Map<string, number>();
      
      // 1. Tentar buscar da tabela entregas (fonte mais confiável)
      try {
        const bairrosDeEntregas = await buscarBairrosDeEntregas(inicioPeriodo, isVendedor, user?.id);
        bairrosDeEntregas.forEach(item => {
          contadores.set(item.name, (contadores.get(item.name) || 0) + item.orders);
        });
      } catch (error) {
        console.log('Não foi possível buscar da tabela entregas:', error);
      }
      
      // 2. O campo endereco_entrega_bairro não existe na tabela pedidos
      // O bairro é obtido através do relacionamento com a tabela clientes (já implementado acima)
      
      // 3. Se ainda não encontrou dados, buscar bairro do cliente
      if (contadores.size === 0) {
        try {
          let queryPedidos = supabase
            .from('pedidos')
            .select(`
              id,
              data_pedido,
              criado_por,
              cliente:clientes!inner(endereco_bairro)
            `)
            .gte('data_pedido', inicioPeriodo.toISOString())
            .lte('data_pedido', fimPeriodo.toISOString());
          
          // REGRA DE NEGÓCIO: Vendedor só vê seus dados
          if (isVendedor && user?.id) {
            queryPedidos = queryPedidos.eq('criado_por', user.id);
          }
          
          const { data: pedidosComCliente, error: errorPedidosCliente } = await queryPedidos;
          
          if (!errorPedidosCliente && pedidosComCliente && pedidosComCliente.length > 0) {
            pedidosComCliente.forEach((pedido: any) => {
              const cliente = pedido.cliente;
              if (cliente && cliente.endereco_bairro && cliente.endereco_bairro.trim() !== '') {
                const bairro = cliente.endereco_bairro.trim();
                contadores.set(bairro, (contadores.get(bairro) || 0) + 1);
              }
            });
            console.log(`✅ Encontrados ${contadores.size} bairros na tabela clientes`);
          }
        } catch (error) {
          console.log('Não foi possível buscar bairro dos clientes:', error);
        }
      }
      
      // Se não encontrou nenhum bairro, retornar vazio
      if (contadores.size === 0) {
        console.log(`📊 Pedidos por Bairro - Período: ${periodo}, Nenhum bairro encontrado`);
        return [];
      }
      
      // Calcular total e percentuais
      const total = Array.from(contadores.values()).reduce((sum, count) => sum + count, 0);
      
      // Converter para array com percentuais
      const pedidosPorBairro: PedidoPorBairro[] = Array.from(contadores.entries())
        .map(([bairro, count]) => ({
          name: bairro,
          orders: count,
          percentage: total > 0 ? Math.round((count / total) * 100) : 0
        }))
        .sort((a, b) => b.orders - a.orders)
        .slice(0, 4); // Top 4 bairros
      
      console.log(`📊 Pedidos por Bairro - Período: ${periodo}, Bairros encontrados: ${pedidosPorBairro.length}`);
      
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
  },

  // Obter relatório de produtos vendidos por período
  async obterRelatorioVendasProdutos(
    periodo: 'dia' | 'semana' | 'mes' | 'custom' = 'mes',
    dataInicio?: string,
    dataFim?: string
  ): Promise<Array<{
    nome_produto: string;
    valor_unitario: number;
    quantidade_vendida: number;
    valor_total: number;
  }>> {
    try {
      const hoje = new Date();
      let inicioPerio: Date;
      let fimPeriodo: Date = hoje;
      
      // Se for período personalizado, usar as datas fornecidas
      if (periodo === 'custom' && dataInicio && dataFim) {
        inicioPerio = new Date(dataInicio);
        fimPeriodo = new Date(dataFim);
        // Ajustar para incluir todo o dia final
        fimPeriodo.setHours(23, 59, 59, 999);
      } else {
        // Calcular período baseado no parâmetro
        switch (periodo) {
          case 'dia':
            inicioPerio = new Date(hoje);
            inicioPerio.setDate(hoje.getDate() - 1);
            break;
          case 'semana':
            inicioPerio = new Date(hoje);
            inicioPerio.setDate(hoje.getDate() - 7);
            break;
          case 'mes':
          default:
            inicioPerio = new Date(hoje);
            inicioPerio.setDate(hoje.getDate() - 30);
            break;
        }
      }
      
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      // Buscar todos os itens de pedidos do período
      let query = supabase
        .from('itens_pedido')
        .select(`
          quantidade,
          preco_unitario,
          subtotal,
          produto:produtos!inner(id, nome),
          pedido:pedidos!inner(data_pedido, status, criado_por)
        `)
        .gte('pedido.data_pedido', inicioPerio.toISOString())
        .lte('pedido.data_pedido', fimPeriodo.toISOString())
        .in('pedido.status', ['entregue', 'concluido', 'em_entrega', 'pronto', 'em_preparo', 'aprovado']);
      
      // REGRA DE NEGÓCIO: Vendedor só vê dados dos seus pedidos
      if (isVendedor && user?.id) {
        query = query.eq('pedido.criado_por', user.id);
      }
      
      const { data: itens, error } = await query;
      
      if (error) {
        console.error('Erro ao buscar itens de pedidos:', error);
        throw error;
      }
      
      if (!itens || itens.length === 0) {
        return [];
      }
      
      // Agrupar por produto
      const produtosMap = new Map<number, {
        nome_produto: string;
        valor_unitario: number;
        quantidade_vendida: number;
        valor_total: number;
      }>();
      
      itens.forEach((item: any) => {
        const produto = item.produto;
        const produtoId = produto?.id;
        const nomeProduto = produto?.nome || 'Produto não encontrado';
        
        if (produtoId) {
          if (produtosMap.has(produtoId)) {
            const existing = produtosMap.get(produtoId)!;
            existing.quantidade_vendida += item.quantidade || 0;
            existing.valor_total += item.subtotal || 0;
            // Atualizar valor unitário médio
            existing.valor_unitario = existing.valor_total / existing.quantidade_vendida;
          } else {
            produtosMap.set(produtoId, {
              nome_produto: nomeProduto,
              valor_unitario: item.preco_unitario || 0,
              quantidade_vendida: item.quantidade || 0,
              valor_total: item.subtotal || 0
            });
          }
        }
      });
      
      // Converter para array e ordenar por valor total (do maior para o menor)
      const resultado = Array.from(produtosMap.values())
        .sort((a, b) => b.valor_total - a.valor_total);
      
      console.log(`📊 Relatório de Vendas de Produtos - Período: ${periodo}, Total de produtos: ${resultado.length}`);
      
      return resultado;
      
    } catch (error: any) {
      console.error('Erro ao obter relatório de vendas de produtos:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Obter relatório financeiro e de pedidos
  async obterRelatorioFinanceiro(periodo: string = '7d', dataInicio?: string, dataFim?: string): Promise<RelatorioFinanceiro> {
    try {
      const hoje = new Date();
      let inicioAtual: Date;
      let fimAtual: Date = hoje;
      
      // Se for período personalizado, usar as datas fornecidas
      if (periodo === 'custom' && dataInicio && dataFim) {
        inicioAtual = new Date(dataInicio);
        fimAtual = new Date(dataFim);
        fimAtual.setHours(23, 59, 59, 999);
      } else {
        switch (periodo) {
          case '30d':
            inicioAtual = new Date(hoje);
            inicioAtual.setDate(hoje.getDate() - 30);
            break;
          case 'month':
            // Primeiro dia do mês atual
            inicioAtual = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
            break;
          default:
            inicioAtual = new Date(hoje);
            inicioAtual.setDate(hoje.getDate() - 7);
        }
      }
      
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      // Buscar todos os pedidos do período (sem filtrar por status)
      let query = supabase
        .from('pedidos')
        .select('valor_total, valor_desconto, percentual_desconto, tipo_desconto, valor_pago, status_pagamento, status, data_pedido, criado_por')
        .gte('data_pedido', inicioAtual.toISOString())
        .lte('data_pedido', fimAtual.toISOString());
      
      // REGRA DE NEGÓCIO: Vendedor só vê seus dados
      if (isVendedor && user?.id) {
        query = query.eq('criado_por', user.id);
      }
      
      const { data: pedidos, error } = await query;
      
      if (error) throw error;
      
      if (!pedidos || pedidos.length === 0) {
        return {
          valor_total_pedidos: 0,
          valor_desconto_total: 0,
          valor_final_pedidos: 0,
          valor_pago: 0,
          valor_pendente: 0,
          quantidade_pedidos: 0,
          quantidade_entregue: 0,
          quantidade_pendente: 0,
          quantidade_cancelado: 0,
          ticket_medio: 0,
          percentual_pago: 0,
          percentual_pendente: 0,
          percentual_desconto_total: 0
        };
      }
      
      // IMPORTANTE: valor_total é o valor ORIGINAL (não muda quando desconto é aplicado)
      // Calcular métricas baseadas no valor original
      const valor_total_pedidos = pedidos.reduce((sum, p) => sum + (p.valor_total || 0), 0);
      
      // Calcular total de descontos aplicados
      const valor_desconto_total = pedidos.reduce((sum, p) => {
        if (p.tipo_desconto === 'valor' && p.valor_desconto) {
          return sum + p.valor_desconto;
        } else if (p.tipo_desconto === 'percentual' && p.percentual_desconto) {
          // Calcular desconto percentual sobre o valor_total original
          const valorOriginal = p.valor_total || 0;
          return sum + (valorOriginal * p.percentual_desconto / 100);
        }
        return sum;
      }, 0);
      
      // Valor final a pagar = valor_total (original) - descontos
      const valor_final_pedidos = valor_total_pedidos - valor_desconto_total;
      
      const valor_pago = pedidos.reduce((sum, p) => sum + (p.valor_pago || 0), 0);
      const valor_pendente = valor_final_pedidos - valor_pago;
      
      const quantidade_pedidos = pedidos.length;
      const quantidade_entregue = pedidos.filter(p => 
        p.status === 'entregue' || p.status === 'concluido'
      ).length;
      const quantidade_pendente = pedidos.filter(p => 
        p.status !== 'entregue' && p.status !== 'concluido' && p.status !== 'cancelado'
      ).length;
      const quantidade_cancelado = pedidos.filter(p => p.status === 'cancelado').length;
      
      // Ticket médio baseado no valor original
      const ticket_medio = quantidade_pedidos > 0 ? valor_total_pedidos / quantidade_pedidos : 0;
      
      // Percentuais baseados no valor final (original - desconto)
      const percentual_pago = valor_final_pedidos > 0 ? (valor_pago / valor_final_pedidos) * 100 : 0;
      const percentual_pendente = valor_final_pedidos > 0 ? (valor_pendente / valor_final_pedidos) * 100 : 0;
      
      // Percentual de desconto sobre o valor original
      const percentual_desconto = valor_total_pedidos > 0 ? (valor_desconto_total / valor_total_pedidos) * 100 : 0;
      
      return {
        valor_total_pedidos,
        valor_final_pedidos,
        valor_desconto_total,
        valor_pago,
        valor_pendente,
        quantidade_pedidos,
        quantidade_entregue,
        quantidade_pendente,
        quantidade_cancelado,
        ticket_medio,
        percentual_pago,
        percentual_pendente,
        percentual_desconto_total: percentual_desconto
      };
      
    } catch (error: any) {
      console.error('Erro ao obter relatório financeiro:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  }
}; 