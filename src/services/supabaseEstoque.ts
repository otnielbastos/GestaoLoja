import { supabase } from '../lib/supabase';
import { authService } from './supabaseAuth';
import { nowBrasiliaISO } from '../utils/dateUtils';

interface MovimentacaoEstoqueData {
  produto_id: number;
  tipo_movimento: 'entrada' | 'saida' | 'ajuste';
  quantidade: number;
  motivo: string;
  valor?: number;
  documento_referencia?: string;
  data_fabricacao?: string;
  data_validade?: string;
  observacao?: string;
  tipo_estoque?: 'pronta_entrega' | 'encomenda';
}

export const estoqueService = {
  // Listar todas as movimentações
  async listarMovimentacoes() {
    try {
      const { data: movimentacoes, error } = await supabase
        .from('movimentacoes_estoque')
        .select(`
          *,
          produto:produtos(nome, unidade_medida, categoria)
        `)
        .order('data_movimentacao', { ascending: false });

      if (error) {
        console.error('Erro Supabase ao buscar movimentações:', error);
        throw new Error(`Erro ao buscar movimentações: ${error.message}`);
      }

      // Formatar os dados para compatibilidade
      const movimentacoesFormatadas = (movimentacoes || []).map(mov => ({
        ...mov,
        produto_nome: mov.produto?.nome || 'Produto não encontrado',
        unidade_medida: mov.produto?.unidade_medida || '',
        categoria: mov.produto?.categoria || ''
      }));

      return {
        success: true,
        data: movimentacoesFormatadas
      };

    } catch (error: any) {
      console.error('Erro ao listar movimentações:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar movimentação por ID
  async buscarMovimentacaoPorId(id: number) {
    try {
      const { data: movimentacao, error } = await supabase
        .from('movimentacoes_estoque')
        .select(`
          *,
          produto:produtos(nome, unidade_medida, categoria)
        `)
        .eq('id', id)
        .single();

      if (error) throw new Error('Movimentação não encontrada');

      return {
        success: true,
        data: movimentacao
      };

    } catch (error: any) {
      console.error('Erro ao buscar movimentação:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Criar nova movimentação com todas as regras de negócio
  async criarMovimentacao(data: MovimentacaoEstoqueData) {
    try {
      const { 
        produto_id, 
        tipo_movimento, 
        quantidade, 
        motivo, 
        valor,
        documento_referencia, 
        data_fabricacao,
        data_validade,
        observacao,
        tipo_estoque = 'pronta_entrega'
      } = data;

      // Verificar se o produto existe
      const { data: produto, error: produtoError } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', produto_id)
        .single();

      if (produtoError || !produto) {
        throw new Error('Produto não encontrado');
      }

      // REGRA DE NEGÓCIO: Lógica para calcular data de validade automática para nhoques
      let dataValidadeFinal = data_validade;
      
      if (motivo === 'Produção' && data_fabricacao) {
        const produtoNome = produto.nome.toLowerCase();
        if (produtoNome.includes('nhoque')) {
          // Calcular automaticamente 3 meses a partir da data de fabricação
          const fabricacao = new Date(data_fabricacao);
          const validade = new Date(fabricacao);
          validade.setMonth(validade.getMonth() + 3);
          dataValidadeFinal = validade.toISOString().split('T')[0];
        }
      }

      // Buscar estoque atual
      const { data: estoqueAtual } = await supabase
        .from('estoque')
        .select('*')
        .eq('produto_id', produto_id)
        .single();

      // Calcular nova quantidade baseada no tipo de estoque
      let novaQuantidadeTotal = estoqueAtual?.quantidade_atual || 0;
      let novaQuantidadeProntaEntrega = estoqueAtual?.quantidade_pronta_entrega || 0;
      let novaQuantidadeEncomenda = estoqueAtual?.quantidade_encomenda || 0;

      if (tipo_movimento === 'entrada') {
        novaQuantidadeTotal += quantidade;
        if (tipo_estoque === 'encomenda') {
          novaQuantidadeEncomenda += quantidade;
        } else {
          novaQuantidadeProntaEntrega += quantidade;
        }
      } else if (tipo_movimento === 'saida') {
        // REGRA DE NEGÓCIO: Verificar se há estoque suficiente
        const quantidadeDisponivel = tipo_estoque === 'encomenda' 
          ? novaQuantidadeEncomenda 
          : novaQuantidadeProntaEntrega;

        if (quantidadeDisponivel < quantidade) {
          throw new Error(`Estoque insuficiente. Disponível: ${quantidadeDisponivel}, Solicitado: ${quantidade}`);
        }

        novaQuantidadeTotal -= quantidade;
        if (tipo_estoque === 'encomenda') {
          novaQuantidadeEncomenda -= quantidade;
        } else {
          novaQuantidadeProntaEntrega -= quantidade;
        }
      } else { // ajuste
        const diferenca = quantidade - novaQuantidadeTotal;
        novaQuantidadeTotal = quantidade;
        
        // Para ajustes, distribuir proporcionalmente entre pronta entrega e encomenda
        if (novaQuantidadeTotal > 0) {
          const proporcaoProntaEntrega = novaQuantidadeProntaEntrega / (novaQuantidadeProntaEntrega + novaQuantidadeEncomenda) || 0.5;
          novaQuantidadeProntaEntrega = Math.floor(novaQuantidadeTotal * proporcaoProntaEntrega);
          novaQuantidadeEncomenda = novaQuantidadeTotal - novaQuantidadeProntaEntrega;
        } else {
          novaQuantidadeProntaEntrega = 0;
          novaQuantidadeEncomenda = 0;
        }
      }

      // Inserir movimentação
      const { data: novaMovimentacao, error: movError } = await supabase
        .from('movimentacoes_estoque')
        .insert({
          produto_id,
          tipo_movimento,
          quantidade,
          motivo,
          valor,
          documento_referencia,
          data_fabricacao,
          data_validade: dataValidadeFinal,
          observacao,
          tipo_estoque,
          tipo_operacao: 'manual',
          usuario_id: authService.getCurrentUserId()
        })
        .select()
        .single();

      if (movError) {
        throw new Error('Erro ao registrar movimentação');
      }

      // Atualizar estoque
      if (estoqueAtual) {
        await supabase
          .from('estoque')
          .update({
            quantidade_atual: novaQuantidadeTotal,
            quantidade_pronta_entrega: novaQuantidadeProntaEntrega,
            quantidade_encomenda: novaQuantidadeEncomenda,
            ultima_atualizacao: nowBrasiliaISO()
          })
          .eq('produto_id', produto_id);
      } else {
        await supabase
          .from('estoque')
          .insert({
            produto_id,
            quantidade_atual: novaQuantidadeTotal,
            quantidade_pronta_entrega: novaQuantidadeProntaEntrega,
            quantidade_encomenda: novaQuantidadeEncomenda
          });
      }

      return {
        success: true,
        message: 'Movimentação registrada com sucesso',
        data: novaMovimentacao
      };

    } catch (error: any) {
      console.error('Erro ao criar movimentação:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Atualizar movimentação com reversão
  async atualizarMovimentacao(id: number, data: MovimentacaoEstoqueData) {
    try {
      const { 
        produto_id, 
        tipo_movimento, 
        quantidade, 
        motivo, 
        valor,
        documento_referencia, 
        data_fabricacao,
        data_validade,
        observacao,
        tipo_estoque = 'pronta_entrega'
      } = data;

      // Buscar movimentação atual
      const { data: movimentacaoAtual, error: movAtualError } = await supabase
        .from('movimentacoes_estoque')
        .select('*')
        .eq('id', id)
        .single();

      if (movAtualError || !movimentacaoAtual) {
        throw new Error('Movimentação não encontrada');
      }

      // Verificar se o produto existe
      const { data: produto, error: produtoError } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', produto_id)
        .single();

      if (produtoError || !produto) {
        throw new Error('Produto não encontrado');
      }

      // REGRA DE NEGÓCIO: Lógica para calcular data de validade automática para nhoques
      let dataValidadeFinal = data_validade;
      
      if (motivo === 'Produção' && data_fabricacao) {
        const produtoNome = produto.nome.toLowerCase();
        if (produtoNome.includes('nhoque')) {
          const fabricacao = new Date(data_fabricacao);
          const validade = new Date(fabricacao);
          validade.setMonth(validade.getMonth() + 3);
          dataValidadeFinal = validade.toISOString().split('T')[0];
        }
      }

      // Buscar estoque atual
      const { data: estoqueAtual } = await supabase
        .from('estoque')
        .select('*')
        .eq('produto_id', produto_id)
        .single();

      if (!estoqueAtual) {
        throw new Error('Estoque não encontrado');
      }

      // REGRA DE NEGÓCIO: Reverter movimentação antiga
      let quantidadeRevertidaTotal = estoqueAtual.quantidade_atual;
      let quantidadeRevertidaPronta = estoqueAtual.quantidade_pronta_entrega;
      let quantidadeRevertidaEncomenda = estoqueAtual.quantidade_encomenda;

      const movAntiga = movimentacaoAtual;
      const tipoEstoqueAntigo = movAntiga.tipo_estoque || 'pronta_entrega';

      if (movAntiga.tipo_movimento === 'entrada') {
        quantidadeRevertidaTotal -= movAntiga.quantidade;
        if (tipoEstoqueAntigo === 'encomenda') {
          quantidadeRevertidaEncomenda -= movAntiga.quantidade;
        } else {
          quantidadeRevertidaPronta -= movAntiga.quantidade;
        }
      } else if (movAntiga.tipo_movimento === 'saida') {
        quantidadeRevertidaTotal += movAntiga.quantidade;
        if (tipoEstoqueAntigo === 'encomenda') {
          quantidadeRevertidaEncomenda += movAntiga.quantidade;
        } else {
          quantidadeRevertidaPronta += movAntiga.quantidade;
        }
      }

      // Aplicar nova movimentação
      let novaQuantidadeTotal = quantidadeRevertidaTotal;
      let novaQuantidadePronta = quantidadeRevertidaPronta;
      let novaQuantidadeEncomenda = quantidadeRevertidaEncomenda;

      if (tipo_movimento === 'entrada') {
        novaQuantidadeTotal += quantidade;
        if (tipo_estoque === 'encomenda') {
          novaQuantidadeEncomenda += quantidade;
        } else {
          novaQuantidadePronta += quantidade;
        }
      } else if (tipo_movimento === 'saida') {
        const quantidadeDisponivel = tipo_estoque === 'encomenda' 
          ? novaQuantidadeEncomenda 
          : novaQuantidadePronta;

        if (quantidadeDisponivel < quantidade) {
          throw new Error(`Estoque insuficiente após reversão. Disponível: ${quantidadeDisponivel}, Solicitado: ${quantidade}`);
        }

        novaQuantidadeTotal -= quantidade;
        if (tipo_estoque === 'encomenda') {
          novaQuantidadeEncomenda -= quantidade;
        } else {
          novaQuantidadePronta -= quantidade;
        }
      } else { // ajuste
        novaQuantidadeTotal = quantidade;
        // Para ajustes, distribuir proporcionalmente
        if (novaQuantidadeTotal > 0) {
          const proporcaoProntaEntrega = novaQuantidadePronta / (novaQuantidadePronta + novaQuantidadeEncomenda) || 0.5;
          novaQuantidadePronta = Math.floor(novaQuantidadeTotal * proporcaoProntaEntrega);
          novaQuantidadeEncomenda = novaQuantidadeTotal - novaQuantidadePronta;
        } else {
          novaQuantidadePronta = 0;
          novaQuantidadeEncomenda = 0;
        }
      }

      // Atualizar movimentação
      await supabase
        .from('movimentacoes_estoque')
        .update({
          produto_id,
          tipo_movimento,
          quantidade,
          motivo,
          valor,
          documento_referencia,
          data_fabricacao,
          data_validade: dataValidadeFinal,
          observacao,
          tipo_estoque
        })
        .eq('id', id);

      // Atualizar estoque
      await supabase
        .from('estoque')
        .update({
          quantidade_atual: novaQuantidadeTotal,
          quantidade_pronta_entrega: novaQuantidadePronta,
          quantidade_encomenda: novaQuantidadeEncomenda,
          ultima_atualizacao: new Date().toISOString()
        })
        .eq('produto_id', produto_id);

      return {
        success: true,
        message: 'Movimentação atualizada com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao atualizar movimentação:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Deletar movimentação com reversão
  async deletarMovimentacao(id: number) {
    try {
      // Buscar movimentação
      const { data: movimentacao, error: movError } = await supabase
        .from('movimentacoes_estoque')
        .select('*')
        .eq('id', id)
        .single();

      if (movError || !movimentacao) {
        throw new Error('Movimentação não encontrada');
      }

      // REGRA DE NEGÓCIO: Não permitir exclusão de movimentações automáticas de pedidos
      if (movimentacao.tipo_operacao === 'automatica' && movimentacao.pedido_id) {
        throw new Error('Não é possível excluir movimentações automáticas vinculadas a pedidos');
      }

      // Buscar estoque atual
      const { data: estoqueAtual } = await supabase
        .from('estoque')
        .select('*')
        .eq('produto_id', movimentacao.produto_id)
        .single();

      if (!estoqueAtual) {
        throw new Error('Estoque não encontrado');
      }

      // Reverter movimentação
      let novaQuantidadeTotal = estoqueAtual.quantidade_atual;
      let novaQuantidadePronta = estoqueAtual.quantidade_pronta_entrega;
      let novaQuantidadeEncomenda = estoqueAtual.quantidade_encomenda;

      const tipoEstoque = movimentacao.tipo_estoque || 'pronta_entrega';

      if (movimentacao.tipo_movimento === 'entrada') {
        novaQuantidadeTotal -= movimentacao.quantidade;
        if (tipoEstoque === 'encomenda') {
          novaQuantidadeEncomenda -= movimentacao.quantidade;
        } else {
          novaQuantidadePronta -= movimentacao.quantidade;
        }
      } else if (movimentacao.tipo_movimento === 'saida') {
        novaQuantidadeTotal += movimentacao.quantidade;
        if (tipoEstoque === 'encomenda') {
          novaQuantidadeEncomenda += movimentacao.quantidade;
        } else {
          novaQuantidadePronta += movimentacao.quantidade;
        }
      }

      // Verificar se reversão resultaria em estoque negativo
      if (novaQuantidadeTotal < 0 || novaQuantidadePronta < 0 || novaQuantidadeEncomenda < 0) {
        throw new Error('Não é possível excluir movimentação: resultaria em estoque negativo');
      }

      // Deletar movimentação
      await supabase
        .from('movimentacoes_estoque')
        .delete()
        .eq('id', id);

      // Atualizar estoque
      await supabase
        .from('estoque')
        .update({
          quantidade_atual: novaQuantidadeTotal,
          quantidade_pronta_entrega: novaQuantidadePronta,
          quantidade_encomenda: novaQuantidadeEncomenda,
          ultima_atualizacao: new Date().toISOString()
        })
        .eq('produto_id', movimentacao.produto_id);

      return {
        success: true,
        message: 'Movimentação excluída com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao deletar movimentação:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar produtos com estoque baixo
  async buscarEstoqueBaixo() {
    try {
      const { data: produtos, error } = await supabase
        .from('produtos')
        .select(`
          *,
          estoque:estoque(quantidade_atual, quantidade_pronta_entrega, quantidade_encomenda)
        `)
        .eq('status', 'ativo')
        .order('nome');

      if (error) {
        console.error('Erro Supabase ao buscar estoque baixo:', error);
        throw new Error(`Erro ao buscar estoque baixo: ${error.message}`);
      }

      // Filtrar produtos com estoque baixo
      const produtosEstoqueBaixo = (produtos || []).filter(produto => {
        const quantidadeAtual = produto.estoque?.[0]?.quantidade_atual || 0;
        return quantidadeAtual <= produto.quantidade_minima;
      }).map(produto => ({
        ...produto,
        quantidade_atual: produto.estoque?.[0]?.quantidade_atual || 0,
        quantidade_pronta_entrega: produto.estoque?.[0]?.quantidade_pronta_entrega || 0,
        quantidade_encomenda: produto.estoque?.[0]?.quantidade_encomenda || 0
      }));

      return {
        success: true,
        data: produtosEstoqueBaixo
      };

    } catch (error: any) {
      console.error('Erro ao buscar estoque baixo:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Relatório de estoque
  async relatorioEstoque() {
    try {
      const { data: produtos, error } = await supabase
        .from('produtos')
        .select(`
          *,
          estoque:estoque(quantidade_atual, quantidade_pronta_entrega, quantidade_encomenda)
        `)
        .eq('status', 'ativo')
        .order('nome');

      if (error) {
        console.error('Erro Supabase ao gerar relatório:', error);
        throw new Error(`Erro ao gerar relatório de estoque: ${error.message}`);
      }

      // Enriquecer dados do estoque
      const produtosComEstoque = (produtos || []).map(produto => ({
        ...produto,
        quantidade_atual: produto.estoque?.[0]?.quantidade_atual || 0,
        quantidade_pronta_entrega: produto.estoque?.[0]?.quantidade_pronta_entrega || 0,
        quantidade_encomenda: produto.estoque?.[0]?.quantidade_encomenda || 0,
        valor_estoque: (produto.estoque?.[0]?.quantidade_atual || 0) * produto.preco_custo
      }));

      // Calcular estatísticas
      const totalProdutos = produtosComEstoque.length;
      const produtosComEstoque_count = produtosComEstoque.filter(p => p.quantidade_atual > 0).length;
      const produtosSemEstoque = produtosComEstoque.filter(p => p.quantidade_atual === 0).length;
      const produtosEstoqueBaixo = produtosComEstoque.filter(p => p.quantidade_atual > 0 && p.quantidade_atual <= p.quantidade_minima).length;
      const valorTotalEstoque = produtosComEstoque.reduce((acc, p) => acc + p.valor_estoque, 0);

      return {
        success: true,
        data: {
          produtos: produtosComEstoque,
          resumo: {
            total_produtos: totalProdutos,
            produtos_com_estoque: produtosComEstoque_count,
            produtos_sem_estoque: produtosSemEstoque,
            produtos_estoque_baixo: produtosEstoqueBaixo,
            valor_total_custo: valorTotalEstoque
          }
        }
      };

    } catch (error: any) {
      console.error('Erro ao gerar relatório:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  }
}; 