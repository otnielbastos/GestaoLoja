import { supabase } from '../lib/supabase';
import type { Pedido, ItemPedido } from '../lib/supabase';
import { authService } from './supabaseAuth';
import { nowBrasiliaISO } from '../utils/dateUtils';

interface CriarPedidoData {
  cliente_id: number;
  tipo: 'pronta_entrega' | 'encomenda';
  data_entrega_prevista?: string;
  horario_entrega?: string;
  forma_pagamento: string;
  observacoes?: string;
  observacoes_producao?: string;
  itens: Array<{
    produto_id: number;
    quantidade: number;
    preco_unitario: number;
    desconto_valor?: number;
    desconto_percentual?: number;
    tipo_desconto?: 'valor' | 'percentual';
  }>;
}

interface ItemPedidoInput {
  produto_id: number;
  quantidade: number;
  preco_unitario: number;
  desconto_valor?: number;
  desconto_percentual?: number;
  tipo_desconto?: 'valor' | 'percentual';
}

interface AtualizarPedidoData {
  status?: string;
  data_pedido?: string;
  data_entrega_prevista?: string;
  horario_entrega?: string;
  forma_pagamento?: string;
  observacoes?: string;
  observacoes_producao?: string;
  itens?: Array<{
    produto_id: number;
    quantidade: number;
    preco_unitario: number;
    desconto_valor?: number;
    desconto_percentual?: number;
    tipo_desconto?: 'valor' | 'percentual';
  }>;
}

interface AtualizarPagamentoData {
  status_pagamento: 'pendente' | 'pago' | 'parcial';
  valor_pago: number;
  observacoes_pagamento?: string;
  valor_desconto?: number;
  percentual_desconto?: number;
  tipo_desconto?: 'valor' | 'percentual' | null;
}

// Função para normalizar status
const normalizeStatus = (status: string): string => {
  if (!status || status.trim() === '') {
    return 'pendente';
  }
  return status.toLowerCase().trim();
};

// Função para validar status
const isValidStatus = (status: string): boolean => {
  const validStatuses = [
    'pendente', 'aprovado', 'aguardando_producao', 'em_preparo', 
    'em_separacao', 'produzido', 'pronto', 'em_entrega', 
    'entregue', 'concluido', 'cancelado'
  ];
  return validStatuses.includes(normalizeStatus(status));
};

// Função para gerar próximo número do pedido
const gerarProximoNumero = async (): Promise<string> => {
  const { data: ultimoPedido } = await supabase
    .from('pedidos')
    .select('numero_pedido')
    .order('id', { ascending: false })
    .limit(1)
    .single();

  if (ultimoPedido?.numero_pedido) {
    const numero = parseInt(ultimoPedido.numero_pedido.replace('#', '')) + 1;
    return `#${numero.toString().padStart(3, '0')}`;
  }
  
  return '#001';
};

// Função para processar entrada automática de estoque (quando produção é finalizada)
const processarEntradaAutomaticaEstoque = async (pedidoId: number, itens: ItemPedido[] | ItemPedidoInput[], tipoPedido: string) => {
  try {
    console.log(`Processando entrada automática de estoque para pedido ${pedidoId}`);
    
    const produtosAfetados = [];
    
    for (const item of itens) {
      const { produto_id, quantidade } = item;
      
      // Inserir movimentação de entrada
      await supabase
        .from('movimentacoes_estoque')
        .insert({
          produto_id,
          tipo_movimento: 'entrada',
          quantidade,
          motivo: 'Produção finalizada - Encomenda',
          documento_referencia: `#${pedidoId}`,
          pedido_id: pedidoId,
          tipo_operacao: 'automatica',
          tipo_estoque: 'encomenda',
          data_fabricacao: nowBrasiliaISO().split('T')[0],
          observacao: 'Entrada automática por conclusão de produção - ESTOQUE DE ENCOMENDA'
        });
      
      // Atualizar estoque
      const { data: estoqueAtual } = await supabase
        .from('estoque')
        .select('*')
        .eq('produto_id', produto_id)
        .single();

      if (estoqueAtual) {
        await supabase
          .from('estoque')
          .update({
            quantidade_atual: estoqueAtual.quantidade_atual + quantidade,
            quantidade_encomenda: estoqueAtual.quantidade_encomenda + quantidade,
            ultima_atualizacao: nowBrasiliaISO()
          })
          .eq('produto_id', produto_id);
      } else {
        await supabase
          .from('estoque')
          .insert({
            produto_id,
            quantidade_atual: quantidade,
            quantidade_pronta_entrega: 0,
            quantidade_encomenda: quantidade
          });
      }
      
      produtosAfetados.push({
        produto_id,
        quantidade,
        operacao: 'entrada',
        tipo_estoque: 'encomenda'
      });
    }
    
    // Log da operação
    await supabase
      .from('log_operacoes_automaticas')
      .insert({
        pedido_id: pedidoId,
        tipo_operacao: 'entrada_estoque',
        status_anterior: 'qualquer',
        status_novo: 'produzido',
        produtos_afetados: produtosAfetados,
        observacoes: 'Entrada automática por conclusão da produção - ESTOQUE DE ENCOMENDA'
      });
    
    console.log(`Entrada automática processada com sucesso para pedido ${pedidoId}`);
    return true;
    
  } catch (error) {
    console.error('Erro ao processar entrada automática:', error);
    throw error;
  }
};

// Função para processar saída automática de estoque (quando entrega é realizada)
const processarSaidaAutomaticaEstoque = async (pedidoId: number, itens: ItemPedido[] | ItemPedidoInput[], tipoPedido: string) => {
  try {
    console.log(`Processando saída automática de estoque para pedido ${pedidoId} (tipo: ${tipoPedido})`);
    
    const produtosAfetados = [];
    const tipoEstoque = tipoPedido === 'encomenda' ? 'encomenda' : 'pronta_entrega';
    
    for (const item of itens) {
      const { produto_id, quantidade } = item;
      
      // Verificar se há estoque suficiente
      const { data: estoque } = await supabase
        .from('estoque')
        .select('*, produto:produtos(nome)')
        .eq('produto_id', produto_id)
        .single();
      
      if (!estoque) {
        throw new Error(`Produto ${produto_id} não encontrado no estoque`);
      }
      
      const quantidadeDisponivel = tipoPedido === 'encomenda' 
        ? estoque.quantidade_encomenda 
        : estoque.quantidade_pronta_entrega;
      
      if (quantidadeDisponivel < quantidade) {
        const produtoNome = (estoque.produto as any)?.nome || 'produto';
        throw new Error(`Estoque insuficiente para ${produtoNome}. Disponível: ${quantidadeDisponivel}, Necessário: ${quantidade}`);
      }
      
      // Inserir movimentação de saída
      await supabase
        .from('movimentacoes_estoque')
        .insert({
          produto_id,
          tipo_movimento: 'saida',
          quantidade,
          motivo: tipoPedido === 'encomenda' ? 'Entrega - Encomenda' : 'Venda - Pronta Entrega',
          documento_referencia: `#${pedidoId}`,
          pedido_id: pedidoId,
          tipo_operacao: 'automatica',
          tipo_estoque: tipoEstoque,
          observacao: 'Saída automática por entrega realizada'
        });
      
      // Atualizar estoque
      const novoEstoque = {
        quantidade_atual: estoque.quantidade_atual - quantidade,
        ultima_atualizacao: new Date().toISOString()
      } as any;

      if (tipoPedido === 'encomenda') {
        novoEstoque.quantidade_encomenda = estoque.quantidade_encomenda - quantidade;
      } else {
        novoEstoque.quantidade_pronta_entrega = estoque.quantidade_pronta_entrega - quantidade;
      }

      await supabase
        .from('estoque')
        .update(novoEstoque)
        .eq('produto_id', produto_id);
      
      produtosAfetados.push({
        produto_id,
        quantidade,
        operacao: 'saida',
        tipo_estoque: tipoEstoque
      });
    }
    
    // Log da operação
    await supabase
      .from('log_operacoes_automaticas')
      .insert({
        pedido_id: pedidoId,
        tipo_operacao: 'saida_estoque',
        status_anterior: 'pronto',
        status_novo: 'entregue',
        produtos_afetados: produtosAfetados,
        observacoes: `Saída automática por entrega - Tipo: ${tipoPedido} - Estoque: ${tipoEstoque}`
      });
    
    console.log(`Saída automática processada com sucesso para pedido ${pedidoId}`);
    return true;
    
  } catch (error) {
    console.error('Erro ao processar saída automática:', error);
    throw error;
  }
};

export const pedidosService = {
  // Listar todos os pedidos com itens detalhados
  async listar(vendedor?: number) {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      let query = supabase
        .from('pedidos')
        .select(`
          *,
          cliente:clientes(*),
          itens:itens_pedido(
            *,
            produto:produtos(*)
          )
        `)
        .neq('status', 'cancelado');
      
      // REGRA DE NEGÓCIO: Vendedor só vê pedidos criados por ele
      if (isVendedor) {
        query = query.eq('criado_por', user.id);
      } else if (vendedor) {
        // Filtro opcional para outros perfis
        query = query.eq('criado_por', vendedor);
      }
      
      const { data: pedidos, error } = await query
        .order('data_pedido', { ascending: false });

      if (error) {
        throw new Error('Erro ao buscar pedidos');
      }

      return {
        success: true,
        data: pedidos
      };

    } catch (error: any) {
      console.error('Erro ao listar pedidos:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar pedido por ID
  async buscarPorId(id: number) {
    try {
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';

      let query = supabase
        .from('pedidos')
        .select(`
          *,
          cliente:clientes(*),
          itens:itens_pedido(
            *,
            produto:produtos(*)
          )
        `)
        .eq('id', id);

      // REGRA DE NEGÓCIO: Vendedor só pode buscar pedidos criados por ele
      if (isVendedor) {
        query = query.eq('criado_por', user.id);
      }

      const { data: pedido, error } = await query.single();

      if (error) {
        if (error.code === 'PGRST116') {
          throw new Error('Pedido não encontrado ou você não tem permissão para acessá-lo');
        }
        throw new Error('Pedido não encontrado');
      }

      return {
        success: true,
        data: pedido
      };

    } catch (error: any) {
      console.error('Erro ao buscar pedido:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Criar novo pedido
  async criar(data: CriarPedidoData, usuarioId: number) {
    try {
      const { cliente_id, tipo, data_entrega_prevista, horario_entrega, forma_pagamento, observacoes, observacoes_producao, itens } = data;

      // Validações
      if (!cliente_id || !forma_pagamento || !itens || itens.length === 0) {
        throw new Error('Dados obrigatórios não informados');
      }

      // Verificar se cliente existe
      const { data: cliente } = await supabase
        .from('clientes')
        .select('id')
        .eq('id', cliente_id)
        .single();

      if (!cliente) {
        throw new Error('Cliente não encontrado');
      }

      // Calcular valor total
      let valorTotal = 0;
      const itensCalculados = itens.map(item => {
        const desconto = item.tipo_desconto === 'percentual' 
          ? (item.preco_unitario * (item.desconto_percentual || 0)) / 100
          : (item.desconto_valor || 0);
        
        const precoComDesconto = item.preco_unitario - desconto;
        const subtotal = precoComDesconto * item.quantidade;
        valorTotal += subtotal;

        return {
          ...item,
          preco_unitario_com_desconto: precoComDesconto,
          subtotal,
          desconto_valor: item.desconto_valor || 0,
          desconto_percentual: item.desconto_percentual || 0,
          tipo_desconto: item.tipo_desconto || 'valor'
        };
      });

      // Gerar número do pedido
      const numeroPedido = await gerarProximoNumero();

      // Criar pedido
      // Preparar dados para inserção, tratando valores opcionais
      const dadosPedido: any = {
        cliente_id,
        numero_pedido: numeroPedido,
        status: 'pendente',
        tipo,
        valor_total: valorTotal,
        forma_pagamento,
        criado_por: usuarioId
      };

      // Adicionar campos opcionais apenas se tiverem valor
      if (data_entrega_prevista) {
        dadosPedido.data_entrega_prevista = data_entrega_prevista;
      }
      if (horario_entrega) {
        dadosPedido.horario_entrega = horario_entrega;
      }
      if (observacoes) {
        dadosPedido.observacoes = observacoes;
      }
      if (observacoes_producao) {
        dadosPedido.observacoes_producao = observacoes_producao;
      }

      const { data: novoPedido, error: pedidoError } = await supabase
        .from('pedidos')
        .insert(dadosPedido)
        .select()
        .single();

      if (pedidoError) {
        console.error('Erro detalhado ao criar pedido:', pedidoError);
        throw new Error(pedidoError.message || 'Erro ao criar pedido');
      }

      // Criar itens do pedido
      const itensParaInserir = itensCalculados.map(item => ({
        pedido_id: novoPedido.id,
        produto_id: item.produto_id,
        quantidade: item.quantidade,
        preco_unitario: item.preco_unitario,
        desconto_valor: item.desconto_valor,
        desconto_percentual: item.desconto_percentual,
        tipo_desconto: item.tipo_desconto,
        preco_unitario_com_desconto: item.preco_unitario_com_desconto,
        subtotal: item.subtotal
      }));

      const { error: itensError } = await supabase
        .from('itens_pedido')
        .insert(itensParaInserir);

      if (itensError) {
        // Reverter criação do pedido
        await supabase.from('pedidos').delete().eq('id', novoPedido.id);
        throw new Error('Erro ao criar itens do pedido');
      }

      // Para pedidos de pronta entrega, verificar estoque e fazer saída automática
      if (tipo === 'pronta_entrega') {
        for (const item of itens) {
          const { data: estoque } = await supabase
            .from('estoque')
            .select(`
              quantidade_pronta_entrega,
              produto:produtos(nome)
            `)
            .eq('produto_id', item.produto_id)
            .single();

          if (!estoque || estoque.quantidade_pronta_entrega < item.quantidade) {
            const produtoNome = (estoque?.produto as any)?.nome || 'produto';
            throw new Error(`Estoque insuficiente para ${produtoNome}. Disponível: ${estoque?.quantidade_pronta_entrega || 0}, Necessário: ${item.quantidade}`);
          }
        }
      }

      return {
        success: true,
        message: 'Pedido criado com sucesso',
        data: {
          id: novoPedido.id,
          numero_pedido: novoPedido.numero_pedido,
          valor_total: valorTotal
        }
      };

    } catch (error: any) {
      console.error('Erro ao criar pedido:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Atualizar pedido
  async atualizar(id: number, data: AtualizarPedidoData) {
    try {
      const { status, itens, ...outrosUpdateData } = data;

      // Buscar pedido atual
      const { data: pedidoAtual, error: pedidoError } = await supabase
        .from('pedidos')
        .select(`
          *,
          itens:itens_pedido(*)
        `)
        .eq('id', id)
        .single();

      if (pedidoError || !pedidoAtual) {
        throw new Error('Pedido não encontrado');
      }

      let updateData: any = { ...outrosUpdateData };

      // Processar atualização de itens se fornecidos
      if (itens && itens.length > 0) {
        console.log(`Atualizando itens do pedido ${id}:`, itens);
        console.log(`Pedido atual tem ${pedidoAtual.itens?.length || 0} itens`);
        
        // Remover itens antigos
        const { error: deleteError } = await supabase
          .from('itens_pedido')
          .delete()
          .eq('pedido_id', id);

        if (deleteError) {
          console.error('Erro ao remover itens antigos:', deleteError);
          throw new Error('Erro ao remover itens antigos');
        }

        console.log('Itens antigos removidos com sucesso');

        // Calcular novo valor total
        let valorTotal = 0;

        // Adicionar novos itens
        for (const item of itens) {
          const { produto_id, quantidade, preco_unitario, desconto_valor = 0, desconto_percentual = 0 } = item;
          
          console.log(`Processando item: produto_id=${produto_id}, quantidade=${quantidade}, preco=${preco_unitario}`);
          
          // Verificar se produto existe
          const { data: produto } = await supabase
            .from('produtos')
            .select('id, nome, status')
            .eq('id', produto_id)
            .eq('status', 'ativo')
            .single();
          
          if (!produto) {
            throw new Error(`Produto ${produto_id} não encontrado ou inativo`);
          }

          const subtotal = quantidade * preco_unitario - (desconto_valor || 0);
          const precoUnitarioComDesconto = preco_unitario - (desconto_valor || 0);
          valorTotal += subtotal;

          const { error: insertError } = await supabase
            .from('itens_pedido')
            .insert({
              pedido_id: id,
              produto_id,
              quantidade,
              preco_unitario,
              preco_unitario_com_desconto: precoUnitarioComDesconto,
              desconto_valor: desconto_valor || 0,
              desconto_percentual: desconto_percentual || 0,
              tipo_desconto: desconto_valor > 0 ? 'valor' : 'percentual',
              subtotal
            });

          if (insertError) {
            console.error('Erro ao inserir item:', insertError);
            throw new Error(`Erro ao inserir item do produto ${produto.nome}`);
          }

          console.log(`Item inserido com sucesso: ${produto.nome}`);
        }

        // Atualizar valor total do pedido
        updateData.valor_total = valorTotal;
        console.log(`Novo valor total calculado: R$ ${valorTotal.toFixed(2)}`);
      }

      // Se status está sendo alterado, validar e processar regras de negócio
      if (status) {
        const novoStatus = normalizeStatus(status);
        
        if (!isValidStatus(novoStatus)) {
          throw new Error('Status inválido');
        }

        updateData.status = novoStatus;

        // Buscar itens atualizados para processamento de estoque
        const itensParaProcessamento = itens || pedidoAtual.itens;

        // Regra: Produção finalizada (qualquer status -> produzido) para encomendas
        if (novoStatus === 'produzido' && pedidoAtual.tipo === 'encomenda' && !pedidoAtual.estoque_processado) {
          console.log(`Processando entrada automática para pedido ${id}: ${pedidoAtual.status} -> ${novoStatus}`);
          await processarEntradaAutomaticaEstoque(id, itensParaProcessamento, pedidoAtual.tipo);
          
          // Marcar que o estoque foi processado para evitar duplicações
          updateData.estoque_processado = true;
        }

        // REGRA 1: Encomenda - Saída automática quando sai de "produzido" para "entregue"
        if (pedidoAtual.status === 'produzido' && novoStatus === 'entregue' && pedidoAtual.tipo === 'encomenda') {
          console.log(`Processando saída automática para encomenda ${id}: produzido -> entregue`);
          await processarSaidaAutomaticaEstoque(id, itensParaProcessamento, pedidoAtual.tipo);
        }

        // REGRA 2: Pronta Entrega - Saída automática quando status for "entregue"
        if (novoStatus === 'entregue' && pedidoAtual.tipo === 'pronta_entrega') {
          console.log(`Processando saída automática para pronta entrega ${id}: -> entregue`);
          await processarSaidaAutomaticaEstoque(id, itensParaProcessamento, pedidoAtual.tipo);
        }
      }

      // Atualizar pedido
      const { error: updateError } = await supabase
        .from('pedidos')
        .update(updateData)
        .eq('id', id);

      if (updateError) {
        throw new Error('Erro ao atualizar pedido');
      }

      return {
        success: true,
        message: 'Pedido atualizado com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao atualizar pedido:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Cancelar pedido
  async cancelar(id: number, motivo?: string) {
    try {
      const { data: pedido } = await supabase
        .from('pedidos')
        .select('status')
        .eq('id', id)
        .single();

      if (!pedido) {
        throw new Error('Pedido não encontrado');
      }

      if (['entregue', 'concluido', 'cancelado'].includes(pedido.status)) {
        throw new Error('Não é possível cancelar este pedido');
      }

      await supabase
        .from('pedidos')
        .update({
          status: 'cancelado',
          observacoes: motivo ? `CANCELADO: ${motivo}` : 'CANCELADO'
        })
        .eq('id', id);

      return {
        success: true,
        message: 'Pedido cancelado com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao cancelar pedido:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Atualizar pagamento
  async atualizarPagamento(id: number, data: AtualizarPagamentoData) {
    try {
      const { status_pagamento, valor_pago, observacoes_pagamento, valor_desconto, percentual_desconto, tipo_desconto } = data;

      // Buscar pedido atual para verificar status e valor total
      const { data: pedidoAtual, error: pedidoError } = await supabase
        .from('pedidos')
        .select('*')
        .eq('id', id)
        .single();

      if (pedidoError || !pedidoAtual) {
        throw new Error('Pedido não encontrado');
      }

      // IMPORTANTE: valor_total permanece inalterado (valor original)
      // O desconto é registrado separadamente
      const valorOriginal = pedidoAtual.valor_total || 0;
      
      // Calcular desconto aplicado
      let descontoAplicado = 0;
      if (tipo_desconto === 'valor' && valor_desconto) {
        descontoAplicado = valor_desconto;
      } else if (tipo_desconto === 'percentual' && percentual_desconto) {
        descontoAplicado = (valorOriginal * percentual_desconto) / 100;
      }
      
      // Valor final a pagar (valor_total - desconto)
      const valorFinal = valorOriginal - descontoAplicado;

      // Preparar dados básicos de atualização
      // IMPORTANTE: NÃO alterar valor_total - ele mantém o valor original
      const updateData: any = {
        status_pagamento,
        valor_pago,
        observacoes_pagamento,
        // valor_total permanece inalterado
      };

      // Verificar se os campos de desconto existem na tabela
      // Se o pedido atual não tiver esses campos, não tentar atualizá-los
      const camposDescontoExistem = pedidoAtual.hasOwnProperty('valor_desconto') || 
                                     pedidoAtual.hasOwnProperty('valor_subtotal');
      
      if (camposDescontoExistem) {
        updateData.valor_desconto = tipo_desconto === 'valor' ? (valor_desconto || 0) : 0;
        updateData.percentual_desconto = tipo_desconto === 'percentual' ? (percentual_desconto || 0) : 0;
        updateData.tipo_desconto = tipo_desconto || null;
        // valor_subtotal pode ser usado para armazenar o valor original se necessário
        // Mas valor_total já é o valor original, então podemos não precisar de valor_subtotal
      }

      if (status_pagamento === 'pago') {
        updateData.data_pagamento = nowBrasiliaISO();
      }

      // REGRA 3: Conclusão automática quando pagamento integral + status entregue
      // Usar valorFinal (valor_total - desconto) para verificar pagamento integral
      if (status_pagamento === 'pago' && 
          valor_pago >= valorFinal && 
          pedidoAtual.status === 'entregue') {
        console.log(`Concluindo pedido ${id} automaticamente: pagamento integral + entregue`);
        updateData.status = 'concluido';
      }

      const { error: updateError } = await supabase
        .from('pedidos')
        .update(updateData)
        .eq('id', id);

      // Se houver erro relacionado a campos que não existem, tentar sem os campos de desconto
      if (updateError) {
        console.error('Erro ao atualizar pedido:', updateError);
        
        if (updateError.message && (
          updateError.message.includes('column') || 
          updateError.message.includes('does not exist') ||
          updateError.message.includes('unknown column') ||
          updateError.code === '42703' // PostgreSQL error code for undefined column
        )) {
          console.log('Campos de desconto não existem na tabela, atualizando apenas campos básicos...');
          
          // Remover campos de desconto e tentar novamente
          const updateDataBasico: any = {
            status_pagamento,
            valor_pago,
            observacoes_pagamento,
            // valor_total permanece inalterado
          };
          
          if (status_pagamento === 'pago') {
            updateDataBasico.data_pagamento = nowBrasiliaISO();
          }
          
          // Calcular valor final para verificação
          const valorFinalBasico = valorOriginal - descontoAplicado;
          if (status_pagamento === 'pago' && 
              valor_pago >= valorFinalBasico && 
              pedidoAtual.status === 'entregue') {
            updateDataBasico.status = 'concluido';
          }

          const { error: retryError } = await supabase
            .from('pedidos')
            .update(updateDataBasico)
            .eq('id', id);

          if (retryError) {
            throw new Error(retryError.message || 'Erro ao atualizar pagamento');
          }
        } else {
          throw new Error(updateError.message || 'Erro ao atualizar pagamento');
        }
      }

      return {
        success: true,
        message: 'Pagamento atualizado com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao atualizar pagamento:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Marcar como entregue
  async marcarEntregue(id: number) {
    try {
      return await this.atualizar(id, { status: 'entregue' });
    } catch (error: any) {
      throw new Error(error.message || 'Erro ao marcar como entregue');
    }
  },

  // Buscar pedidos não entregues
  async naoEntregues() {
    try {
      const { data: pedidos, error } = await supabase
        .from('pedidos')
        .select(`
          *,
          cliente:clientes(nome, telefone)
        `)
        .in('status', ['pronto', 'em_entrega'])
        .order('data_pedido', { ascending: true });

      if (error) {
        throw new Error('Erro ao buscar pedidos não entregues');
      }

      return {
        success: true,
        data: pedidos
      };

    } catch (error: any) {
      console.error('Erro ao buscar pedidos não entregues:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar pagamentos pendentes
  async pagamentosPendentes() {
    try {
      const { data: pedidos, error } = await supabase
        .from('pedidos')
        .select(`
          *,
          cliente:clientes(nome, telefone)
        `)
        .eq('status_pagamento', 'pendente')
        .neq('status', 'cancelado')
        .order('data_pedido', { ascending: true });

      if (error) {
        throw new Error('Erro ao buscar pagamentos pendentes');
      }

      return {
        success: true,
        data: pedidos
      };

    } catch (error: any) {
      console.error('Erro ao buscar pagamentos pendentes:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Estatísticas
  async estatisticas() {
    try {
      // Total de pedidos
      const { count: totalPedidos } = await supabase
        .from('pedidos')
        .select('*', { count: 'exact', head: true })
        .neq('status', 'cancelado');

      // Pedidos pendentes
      const { count: pedidosPendentes } = await supabase
        .from('pedidos')
        .select('*', { count: 'exact', head: true })
        .in('status', ['pendente', 'aprovado', 'aguardando_producao', 'em_preparo']);

      // Pedidos entregues
      const { count: pedidosEntregues } = await supabase
        .from('pedidos')
        .select('*', { count: 'exact', head: true })
        .in('status', ['entregue', 'concluido']);

      // Faturamento total
      const { data: faturamento } = await supabase
        .from('pedidos')
        .select('valor_total')
        .in('status', ['entregue', 'concluido']);

      const faturamentoTotal = faturamento?.reduce((acc, pedido) => acc + pedido.valor_total, 0) || 0;

      return {
        success: true,
        data: {
          total_pedidos: totalPedidos || 0,
          pedidos_pendentes: pedidosPendentes || 0,
          pedidos_entregues: pedidosEntregues || 0,
          faturamento_total: faturamentoTotal
        }
      };

    } catch (error: any) {
      console.error('Erro ao buscar estatísticas:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  }
}; 