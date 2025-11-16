import { supabase } from '../lib/supabase';

interface ProdutoData {
  nome: string;
  descricao?: string;
  preco_venda: number;
  preco_custo: number;
  quantidade_minima: number;
  categoria?: string;
  unidade_medida?: string;
  tipo_produto: 'producao_propria' | 'revenda' | 'materia_prima';
  imagem_url?: string;
  status?: 'ativo' | 'inativo';
}

export const produtosService = {
  // Listar todos os produtos
  async listarTodos() {
    try {
      const { data: produtos, error } = await supabase
        .from('produtos')
        .select(`
          *,
          estoque:estoque(quantidade_atual, quantidade_pronta_entrega, quantidade_encomenda)
        `)
        .order('nome');

      if (error) throw new Error('Erro ao buscar produtos');

      // REGRA DE NEGÓCIO: Converter valores numéricos e garantir que não sejam null/undefined
      const produtosFormatados = produtos.map(produto => ({
        id: parseInt(produto.id) || 0,
        nome: produto.nome || '',
        descricao: produto.descricao || '',
        preco_venda: parseFloat(produto.preco_venda) || 0,
        preco_custo: parseFloat(produto.preco_custo) || 0,
        quantidade_minima: parseInt(produto.quantidade_minima) || 0,
        quantidade_atual: produto.estoque?.[0]?.quantidade_atual || 0,
        quantidade_pronta_entrega: produto.estoque?.[0]?.quantidade_pronta_entrega || 0,
        quantidade_encomenda: produto.estoque?.[0]?.quantidade_encomenda || 0,
        categoria: produto.categoria || '',
        unidade_medida: produto.unidade_medida || 'un',
        tipo_produto: produto.tipo_produto || '',
        imagem_url: produto.imagem_url || null,
        status: produto.status || 'ativo',
        data_criacao: produto.data_criacao,
        data_atualizacao: produto.data_atualizacao
      }));

      return {
        success: true,
        data: produtosFormatados
      };

    } catch (error: any) {
      console.error('Erro ao listar produtos:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar produto por ID
  async buscarPorId(id: number) {
    try {
      const { data: produto, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw new Error('Produto não encontrado');

      return {
        success: true,
        data: produto
      };

    } catch (error: any) {
      console.error('Erro ao buscar produto:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Criar novo produto
  async criar(data: ProdutoData) {
    try {
      const { 
        nome, 
        descricao, 
        preco_venda, 
        preco_custo, 
        quantidade_minima,
        categoria, 
        unidade_medida,
        tipo_produto,
        imagem_url 
      } = data;

      // REGRA DE NEGÓCIO: Validações obrigatórias
      if (!nome || nome.trim() === '') {
        throw new Error('Nome do produto é obrigatório');
      }

      if (!preco_venda || preco_venda <= 0) {
        throw new Error('Preço de venda deve ser maior que zero');
      }

      if (!preco_custo || preco_custo < 0) {
        throw new Error('Preço de custo não pode ser negativo');
      }

      if (!tipo_produto || !['producao_propria', 'revenda', 'materia_prima'].includes(tipo_produto)) {
        throw new Error('Tipo de produto inválido');
      }

      // REGRA DE NEGÓCIO: Verificar se já existe produto com o mesmo nome
      const { data: produtosExistentes } = await supabase
        .from('produtos')
        .select('id')
        .eq('nome', nome.trim())
        .eq('status', 'ativo')
        .limit(1);

      if (produtosExistentes && produtosExistentes.length > 0) {
        throw new Error('Já existe um produto ativo com este nome');
      }

      const { data: produto, error } = await supabase
        .from('produtos')
        .insert({
          nome: nome.trim(),
          descricao: descricao?.trim() || null,
          preco_venda,
          preco_custo,
          quantidade_minima: quantidade_minima || 0,
          categoria: categoria?.trim() || null,
          unidade_medida: unidade_medida || 'un',
          tipo_produto,
          imagem_url: imagem_url || null,
          status: 'ativo'
        })
        .select()
        .single();

      if (error) {
        throw new Error('Erro ao criar produto');
      }

      // REGRA DE NEGÓCIO: Criar registro inicial no estoque
      await supabase
        .from('estoque')
        .insert({
          produto_id: produto.id,
          quantidade_atual: 0,
          quantidade_pronta_entrega: 0,
          quantidade_encomenda: 0
        });

      return {
        success: true,
        message: 'Produto criado com sucesso',
        data: produto
      };

    } catch (error: any) {
      console.error('Erro ao criar produto:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Atualizar produto
  async atualizar(id: number, data: Partial<ProdutoData>) {
    try {
      const { 
        nome, 
        descricao, 
        preco_venda, 
        preco_custo, 
        quantidade_minima, 
        categoria, 
        unidade_medida, 
        tipo_produto, 
        imagem_url, 
        status 
      } = data;

      // REGRA DE NEGÓCIO: Verificar se produto existe
      const { data: produtoExistente } = await supabase
        .from('produtos')
        .select('id, nome')
        .eq('id', id)
        .single();

      if (!produtoExistente) {
        throw new Error('Produto não encontrado');
      }

      // REGRA DE NEGÓCIO: Validações se nome foi alterado
      if (nome && nome.trim() !== '' && nome.trim() !== produtoExistente.nome) {
        const { data: produtosComNome } = await supabase
          .from('produtos')
          .select('id')
          .eq('nome', nome.trim())
          .neq('id', id)
          .eq('status', 'ativo')
          .limit(1);

        if (produtosComNome && produtosComNome.length > 0) {
          throw new Error('Já existe um produto ativo com este nome');
        }
      }

      // REGRA DE NEGÓCIO: Validações de valores
      if (preco_venda !== undefined && preco_venda <= 0) {
        throw new Error('Preço de venda deve ser maior que zero');
      }

      if (preco_custo !== undefined && preco_custo < 0) {
        throw new Error('Preço de custo não pode ser negativo');
      }

      if (tipo_produto && !['producao_propria', 'revenda', 'materia_prima'].includes(tipo_produto)) {
        throw new Error('Tipo de produto inválido');
      }

      const updateData: any = {};
      if (nome !== undefined) updateData.nome = nome.trim();
      if (descricao !== undefined) updateData.descricao = descricao?.trim() || null;
      if (preco_venda !== undefined) updateData.preco_venda = preco_venda;
      if (preco_custo !== undefined) updateData.preco_custo = preco_custo;
      if (quantidade_minima !== undefined) updateData.quantidade_minima = quantidade_minima;
      if (categoria !== undefined) updateData.categoria = categoria?.trim() || null;
      if (unidade_medida !== undefined) updateData.unidade_medida = unidade_medida || 'un';
      if (tipo_produto !== undefined) updateData.tipo_produto = tipo_produto;
      if (imagem_url !== undefined) updateData.imagem_url = imagem_url || null;
      if (status !== undefined) updateData.status = status;

      updateData.data_atualizacao = new Date().toISOString();

      const { error } = await supabase
        .from('produtos')
        .update(updateData)
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao atualizar produto');
      }

      return {
        success: true,
        message: 'Produto atualizado com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao atualizar produto:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Deletar produto
  async deletar(id: number) {
    try {
      // REGRA DE NEGÓCIO: Verificar se existem dependências (itens de pedido)
      const { data: itensVenda } = await supabase
        .from('itens_pedido')
        .select('id')
        .eq('produto_id', id)
        .limit(1);

      if (itensVenda && itensVenda.length > 0) {
        throw new Error('Não é possível excluir o produto pois existem vendas relacionadas');
      }

      // REGRA DE NEGÓCIO: Verificar se existem movimentações de estoque
      const { data: movimentacoes } = await supabase
        .from('movimentacoes_estoque')
        .select('id')
        .eq('produto_id', id)
        .limit(1);

      if (movimentacoes && movimentacoes.length > 0) {
        throw new Error('Não é possível excluir o produto pois existem movimentações de estoque relacionadas');
      }

      // Buscar informações do produto para deletar a imagem (se necessário)
      const { data: produto } = await supabase
        .from('produtos')
        .select('imagem_url')
        .eq('id', id)
        .single();

      if (!produto) {
        throw new Error('Produto não encontrado');
      }

      // Deletar registro do estoque
      await supabase
        .from('estoque')
        .delete()
        .eq('produto_id', id);

      // Deletar produto
      const { error } = await supabase
        .from('produtos')
        .delete()
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao deletar produto');
      }

      // TODO: Implementar deleção de arquivo de imagem do storage quando necessário
      // if (produto.imagem_url) {
      //   // Deletar imagem do Supabase Storage
      // }

      return {
        success: true,
        message: 'Produto deletado com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao deletar produto:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // REGRA DE NEGÓCIO: Listar produtos para venda (produção própria e revenda)
  async listarParaVenda() {
    try {
      const { data: produtos, error } = await supabase
        .from('produtos')
        .select(`
          id,
          nome,
          descricao,
          preco_venda,
          preco_custo,
          quantidade_minima,
          categoria,
          unidade_medida,
          tipo_produto,
          imagem_url,
          status,
          estoque:estoque(quantidade_atual, quantidade_pronta_entrega, quantidade_encomenda)
        `)
        .eq('status', 'ativo')
        .in('tipo_produto', ['producao_propria', 'revenda'])
        .order('nome');

      if (error) {
        throw new Error('Erro ao buscar produtos para venda');
      }
      
      // REGRA DE NEGÓCIO: Converter valores numéricos e garantir que não sejam null/undefined
      const produtosFormatados = produtos.map(produto => ({
        id: parseInt(produto.id) || 0,
        nome: produto.nome || '',
        descricao: produto.descricao || '',
        preco_venda: parseFloat(produto.preco_venda) || 0,
        preco_custo: parseFloat(produto.preco_custo) || 0,
        quantidade_minima: parseInt(produto.quantidade_minima) || 0,
        quantidade_atual: produto.estoque?.[0]?.quantidade_atual || 0,
        quantidade_pronta_entrega: produto.estoque?.[0]?.quantidade_pronta_entrega || 0,
        quantidade_encomenda: produto.estoque?.[0]?.quantidade_encomenda || 0,
        categoria: produto.categoria || '',
        unidade_medida: produto.unidade_medida || 'un',
        tipo_produto: produto.tipo_produto || '',
        imagem_url: produto.imagem_url || null,
        status: produto.status || 'ativo'
      }));
      
      return {
        success: true,
        data: produtosFormatados
      };

    } catch (error: any) {
      console.error('Erro ao listar produtos para venda:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Upload de imagem para Supabase Storage
  async uploadImagem(file: File) {
    try {
      if (!file) {
        throw new Error('Nenhum arquivo foi enviado');
      }

      // REGRA DE NEGÓCIO: Validar tipo de arquivo
      const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
      if (!allowedMimes.includes(file.type)) {
        throw new Error('Tipo de arquivo inválido. Apenas imagens são permitidas.');
      }

      // REGRA DE NEGÓCIO: Validar tamanho do arquivo (10MB)
      if (file.size > 10 * 1024 * 1024) {
        throw new Error('Arquivo muito grande. Limite de 10MB.');
      }

      // Gerar nome único para o arquivo
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const fileExt = file.name.split('.').pop();
      const fileName = `${uniqueSuffix}.${fileExt}`;

      // Upload para Supabase Storage
      const { data, error } = await supabase.storage
        .from('uploads')
        .upload(`produtos/${fileName}`, file);

      if (error) {
        throw new Error('Erro no upload do arquivo: ' + error.message);
      }

      // Construir URL da imagem
      const imageUrl = `/uploads/produtos/${fileName}`;

      return {
        success: true,
        data: { imageUrl }
      };

    } catch (error: any) {
      console.error('Erro no upload:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar produtos por categoria
  async buscarPorCategoria(categoria: string) {
    try {
      const { data: produtos, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('categoria', categoria)
        .eq('status', 'ativo')
        .order('nome');

      if (error) throw new Error('Erro ao buscar produtos por categoria');

      return {
        success: true,
        data: produtos || []
      };

    } catch (error: any) {
      console.error('Erro ao buscar produtos por categoria:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar produtos por tipo
  async buscarPorTipo(tipo: string) {
    try {
      const { data: produtos, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('tipo_produto', tipo)
        .eq('status', 'ativo')
        .order('nome');

      if (error) throw new Error('Erro ao buscar produtos por tipo');

      return {
        success: true,
        data: produtos || []
      };

    } catch (error: any) {
      console.error('Erro ao buscar produtos por tipo:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  }
}; 