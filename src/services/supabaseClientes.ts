import { supabase } from '../lib/supabase';
import { authService } from './supabaseAuth';

interface ClienteData {
  nome: string;
  email?: string;
  telefone?: string;
  cpf_cnpj?: string;
  tipo_pessoa: 'fisica' | 'juridica';
  endereco_rua?: string;
  endereco_numero?: string;
  endereco_complemento?: string;
  endereco_bairro?: string;
  endereco_cidade?: string;
  endereco_estado?: string;
  endereco_cep?: string;
  observacoes?: string;
}

export const clientesService = {
  // Listar todos os clientes com estatísticas
  async listar(vendedorId?: number) {
    try {
      // Obter usuário atual
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';
      
      let query = supabase
        .from('clientes')
        .select(`
          *,
          pedidos(id, data_pedido, valor_total)
        `)
        .eq('status', 'ativo');

      // REGRA DE NEGÓCIO: Vendedor só vê clientes criados por ele
      if (isVendedor) {
        query = query.eq('criado_por', user.id);
      } else if (vendedorId) {
        // Filtro opcional para outros perfis
        query = query.eq('criado_por', vendedorId);
      }

      const { data: clientes, error } = await query.order('nome');

      if (error) {
        console.error('Erro na query de clientes:', error);
        throw new Error('Erro ao buscar clientes');
      }

      // REGRA DE NEGÓCIO: Calcular estatísticas para cada cliente
      const clientesComEstatisticas = clientes.map(cliente => {
        const pedidos = cliente.pedidos || [];
        const totalPedidos = pedidos.length;
        const ultimoPedido = totalPedidos > 0 
          ? pedidos.sort((a, b) => new Date(b.data_pedido).getTime() - new Date(a.data_pedido).getTime())[0].data_pedido
          : '';
        const totalGasto = pedidos.reduce((acc, pedido) => acc + (pedido.valor_total || 0), 0);

        return {
          ...cliente,
          total_pedidos: totalPedidos,
          ultimo_pedido: ultimoPedido,
          total_gasto: totalGasto,
          pedidos: undefined // Remover pedidos do retorno para economizar dados
        };
      });

      return {
        success: true,
        data: clientesComEstatisticas
      };

    } catch (error: any) {
      console.error('Erro ao listar clientes:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar cliente por ID com estatísticas
  async buscarPorId(id: number) {
    try {
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';

      let query = supabase
        .from('clientes')
        .select(`
          *,
          pedidos(id, data_pedido, valor_total, status)
        `)
        .eq('id', id);

      // REGRA DE NEGÓCIO: Vendedor só pode buscar clientes criados por ele
      if (isVendedor) {
        query = query.eq('criado_por', user.id);
      }

      const { data: cliente, error } = await query.single();

      if (error) {
        if (error.code === 'PGRST116') {
          throw new Error('Cliente não encontrado ou você não tem permissão para acessá-lo');
        }
        throw new Error('Cliente não encontrado');
      }

      // REGRA DE NEGÓCIO: Calcular estatísticas do cliente
      const pedidos = cliente.pedidos || [];
      const totalPedidos = pedidos.length;
      const ultimoPedido = totalPedidos > 0 
        ? pedidos.sort((a, b) => new Date(b.data_pedido).getTime() - new Date(a.data_pedido).getTime())[0].data_pedido
        : '';
      const totalGasto = pedidos.reduce((acc, pedido) => acc + (pedido.valor_total || 0), 0);

      return {
        success: true,
        data: {
          ...cliente,
          total_pedidos: totalPedidos,
          ultimo_pedido: ultimoPedido,
          total_gasto: totalGasto
        }
      };

    } catch (error: any) {
      console.error('Erro ao buscar cliente:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Criar novo cliente
  async criar(data: ClienteData) {
    try {
      const {
        nome,
        email,
        telefone,
        cpf_cnpj,
        tipo_pessoa,
        endereco_rua,
        endereco_numero,
        endereco_complemento,
        endereco_bairro,
        endereco_cidade,
        endereco_estado,
        endereco_cep,
        observacoes
      } = data;

      console.log('Criando cliente com dados:', data);

      // REGRA DE NEGÓCIO: Validações obrigatórias
      if (!nome || nome.trim() === '') {
        throw new Error('Nome do cliente é obrigatório');
      }

      if (!tipo_pessoa || !['fisica', 'juridica'].includes(tipo_pessoa)) {
        throw new Error('Tipo de pessoa inválido');
      }

      // REGRA DE NEGÓCIO: Converter campos vazios para null para evitar problemas com UNIQUE constraints
      const emailTratado = email && email.trim() !== '' ? email.trim().toLowerCase() : null;
      const cpfCnpjTratado = cpf_cnpj && cpf_cnpj.trim() !== '' ? cpf_cnpj.trim().replace(/\D/g, '') : null;
      const telefoneTratado = telefone && telefone.trim() !== '' ? telefone.trim() : null;

      // REGRA DE NEGÓCIO: Verificar se já existe cliente com mesmo email
      if (emailTratado) {
        const { data: emailExistente, error: emailError } = await supabase
          .from('clientes')
          .select('id')
          .eq('email', emailTratado)
          .eq('status', 'ativo')
          .maybeSingle();

        if (emailError) {
          console.error('Erro ao verificar email existente:', emailError);
        }

        if (emailExistente) {
          throw new Error('Já existe um cliente com este email');
        }
      }

      // REGRA DE NEGÓCIO: Verificar se já existe cliente com mesmo CPF/CNPJ
      if (cpfCnpjTratado) {
        const { data: cpfExistente, error: cpfError } = await supabase
          .from('clientes')
          .select('id')
          .eq('cpf_cnpj', cpfCnpjTratado)
          .eq('status', 'ativo')
          .maybeSingle();

        if (cpfError) {
          console.error('Erro ao verificar CPF/CNPJ existente:', cpfError);
        }

        if (cpfExistente) {
          throw new Error('Já existe um cliente com este CPF/CNPJ');
        }
      }

      // REGRA DE NEGÓCIO: Validações específicas por tipo de pessoa
      if (tipo_pessoa === 'fisica' && cpfCnpjTratado && cpfCnpjTratado.length !== 11) {
        throw new Error('CPF deve ter 11 dígitos');
      }

      if (tipo_pessoa === 'juridica' && cpfCnpjTratado && cpfCnpjTratado.length !== 14) {
        throw new Error('CNPJ deve ter 14 dígitos');
      }

      const { data: cliente, error } = await supabase
        .from('clientes')
        .insert({
          nome: nome.trim(),
          email: emailTratado,
          telefone: telefoneTratado,
          cpf_cnpj: cpfCnpjTratado,
          tipo_pessoa,
          endereco_rua: endereco_rua?.trim() || null,
          endereco_numero: endereco_numero?.trim() || null,
          endereco_complemento: endereco_complemento?.trim() || null,
          endereco_bairro: endereco_bairro?.trim() || null,
          endereco_cidade: endereco_cidade?.trim() || null,
          endereco_estado: endereco_estado?.trim() || null,
          endereco_cep: endereco_cep?.trim() || null,
          observacoes: observacoes?.trim() || null,
          status: 'ativo',
          criado_por: authService.getCurrentUserId()
        })
        .select()
        .single();

      if (error) {
        if (error.code === '23505') { // Unique constraint violation
          throw new Error('Email ou CPF/CNPJ já cadastrado');
        }
        throw new Error('Erro ao criar cliente');
      }

      console.log('Cliente criado com ID:', cliente.id);

      return {
        success: true,
        message: 'Cliente criado com sucesso',
        data: {
          ...cliente,
          total_pedidos: 0,
          ultimo_pedido: '',
          total_gasto: 0
        }
      };

    } catch (error: any) {
      console.error('Erro ao criar cliente:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Atualizar cliente
  async atualizar(id: number, data: Partial<ClienteData>) {
    try {
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';

      // REGRA DE NEGÓCIO: Vendedor só pode atualizar clientes criados por ele
      if (isVendedor) {
        // Verificar se o cliente pertence ao vendedor
        const { data: cliente, error: errorBusca } = await supabase
          .from('clientes')
          .select('criado_por')
          .eq('id', id)
          .eq('criado_por', user.id)
          .single();

        if (errorBusca || !cliente) {
          throw new Error('Cliente não encontrado ou você não tem permissão para editá-lo');
        }
      }

      const {
        nome,
        email,
        telefone,
        cpf_cnpj,
        tipo_pessoa,
        endereco_rua,
        endereco_numero,
        endereco_complemento,
        endereco_bairro,
        endereco_cidade,
        endereco_estado,
        endereco_cep,
        observacoes
      } = data;

      // REGRA DE NEGÓCIO: Converter campos vazios para null para evitar problemas com UNIQUE constraints
      const emailTratado = email && email.trim() !== '' ? email.trim().toLowerCase() : null;
      const cpfCnpjTratado = cpf_cnpj && cpf_cnpj.trim() !== '' ? cpf_cnpj.trim().replace(/\D/g, '') : null;
      const telefoneTratado = telefone && telefone.trim() !== '' ? telefone.trim() : null;

      // REGRA DE NEGÓCIO: Verificar se já existe outro cliente com mesmo email
      if (emailTratado) {
        const { data: emailExistente } = await supabase
          .from('clientes')
          .select('id')
          .eq('email', emailTratado)
          .eq('status', 'ativo')
          .neq('id', id)
          .single();

        if (emailExistente) {
          throw new Error('Já existe outro cliente com este email');
        }
      }

      // REGRA DE NEGÓCIO: Verificar se já existe outro cliente com mesmo CPF/CNPJ
      if (cpfCnpjTratado) {
        const { data: cpfExistente } = await supabase
          .from('clientes')
          .select('id')
          .eq('cpf_cnpj', cpfCnpjTratado)
          .eq('status', 'ativo')
          .neq('id', id)
          .single();

        if (cpfExistente) {
          throw new Error('Já existe outro cliente com este CPF/CNPJ');
        }
      }

      // REGRA DE NEGÓCIO: Validações específicas por tipo de pessoa
      if (tipo_pessoa === 'fisica' && cpfCnpjTratado && cpfCnpjTratado.length !== 11) {
        throw new Error('CPF deve ter 11 dígitos');
      }

      if (tipo_pessoa === 'juridica' && cpfCnpjTratado && cpfCnpjTratado.length !== 14) {
        throw new Error('CNPJ deve ter 14 dígitos');
      }

      const { data: cliente, error } = await supabase
        .from('clientes')
        .update({
          ...(nome && { nome: nome.trim() }),
          ...(emailTratado !== undefined && { email: emailTratado }),
          ...(telefoneTratado !== undefined && { telefone: telefoneTratado }),
          ...(cpfCnpjTratado !== undefined && { cpf_cnpj: cpfCnpjTratado }),
          ...(tipo_pessoa && { tipo_pessoa }),
          ...(endereco_rua !== undefined && { endereco_rua: endereco_rua?.trim() || null }),
          ...(endereco_numero !== undefined && { endereco_numero: endereco_numero?.trim() || null }),
          ...(endereco_complemento !== undefined && { endereco_complemento: endereco_complemento?.trim() || null }),
          ...(endereco_bairro !== undefined && { endereco_bairro: endereco_bairro?.trim() || null }),
          ...(endereco_cidade !== undefined && { endereco_cidade: endereco_cidade?.trim() || null }),
          ...(endereco_estado !== undefined && { endereco_estado: endereco_estado?.trim() || null }),
          ...(endereco_cep !== undefined && { endereco_cep: endereco_cep?.trim() || null }),
          ...(observacoes !== undefined && { observacoes: observacoes?.trim() || null })
        })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        if (error.code === '23505') { // Unique constraint violation
          throw new Error('Email ou CPF/CNPJ já cadastrado');
        }
        throw new Error('Erro ao atualizar cliente');
      }

      return {
        success: true,
        data: cliente
      };

    } catch (error: any) {
      console.error('Erro ao atualizar cliente:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Deletar cliente (soft delete)
  async deletar(id: number) {
    try {
      const user = authService.getCurrentUser();
      const isVendedor = user?.perfil === 'Vendedor';

      // REGRA DE NEGÓCIO: Vendedor só pode deletar clientes criados por ele
      if (isVendedor) {
        // Verificar se o cliente pertence ao vendedor
        const { data: cliente, error: errorBusca } = await supabase
          .from('clientes')
          .select('criado_por')
          .eq('id', id)
          .eq('criado_por', user.id)
          .single();

        if (errorBusca || !cliente) {
          throw new Error('Cliente não encontrado ou você não tem permissão para excluí-lo');
        }
      }

      // REGRA DE NEGÓCIO: Verificar se o cliente tem pedidos
      const { data: pedidos, error: errorPedidos } = await supabase
        .from('pedidos')
        .select('id')
        .eq('cliente_id', id)
        .limit(1);

      if (errorPedidos) {
        throw new Error('Erro ao verificar pedidos do cliente');
      }

      if (pedidos && pedidos.length > 0) {
        throw new Error('Não é possível excluir o cliente pois ele possui pedidos cadastrados');
      }

      // Realizar soft delete
      const { error } = await supabase
        .from('clientes')
        .update({ status: 'inativo' })
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao excluir cliente');
      }

      return {
        success: true,
        message: 'Cliente excluído com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao deletar cliente:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar clientes por texto
  async buscar(termo: string) {
    try {
      if (!termo || termo.trim() === '') {
        return await this.listar();
      }

      const termoBusca = `%${termo.trim()}%`;

      const { data: clientes, error } = await supabase
        .from('clientes')
        .select(`
          *,
          pedidos(id, data_pedido, valor_total)
        `)
        .eq('status', 'ativo')
        .or(`nome.ilike.${termoBusca},email.ilike.${termoBusca},telefone.ilike.${termoBusca},cpf_cnpj.ilike.${termoBusca}`)
        .order('nome');

      if (error) throw new Error('Erro ao buscar clientes');

      // Calcular estatísticas para cada cliente
      const clientesComEstatisticas = clientes.map(cliente => {
        const pedidos = cliente.pedidos || [];
        const totalPedidos = pedidos.length;
        const ultimoPedido = totalPedidos > 0 
          ? pedidos.sort((a, b) => new Date(b.data_pedido).getTime() - new Date(a.data_pedido).getTime())[0].data_pedido
          : '';
        const totalGasto = pedidos.reduce((acc, pedido) => acc + (pedido.valor_total || 0), 0);

        return {
          ...cliente,
          total_pedidos: totalPedidos,
          ultimo_pedido: ultimoPedido,
          total_gasto: totalGasto,
          pedidos: undefined
        };
      });

      return {
        success: true,
        data: clientesComEstatisticas
      };

    } catch (error: any) {
      console.error('Erro ao buscar clientes:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Estatísticas dos clientes
  async estatisticas() {
    try {
      // Total de clientes ativos
      const { count: totalClientes } = await supabase
        .from('clientes')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'ativo');

      // Clientes que fizeram pedidos
      const { data: clientesComPedidos } = await supabase
        .from('clientes')
        .select('id')
        .eq('status', 'ativo')
        .not('pedidos', 'is', null);

      // Novos clientes no mês
      const inicioMes = new Date();
      inicioMes.setDate(1);
      inicioMes.setHours(0, 0, 0, 0);

      const { count: novosClientesMes } = await supabase
        .from('clientes')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'ativo')
        .gte('data_cadastro', inicioMes.toISOString());

      // Top clientes por valor gasto
      const { data: topClientes } = await supabase
        .from('clientes')
        .select(`
          id,
          nome,
          pedidos(valor_total)
        `)
        .eq('status', 'ativo')
        .limit(10);

      const topClientesFormatados = topClientes?.map(cliente => {
        const totalGasto = cliente.pedidos?.reduce((acc, pedido) => acc + (pedido.valor_total || 0), 0) || 0;
        return {
          id: cliente.id,
          nome: cliente.nome,
          total_gasto: totalGasto
        };
      }).sort((a, b) => b.total_gasto - a.total_gasto).slice(0, 5) || [];

      return {
        success: true,
        data: {
          total_clientes: totalClientes || 0,
          clientes_com_pedidos: clientesComPedidos?.length || 0,
          novos_clientes_mes: novosClientesMes || 0,
          top_clientes: topClientesFormatados
        }
      };

    } catch (error: any) {
      console.error('Erro ao buscar estatísticas:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Reativar cliente
  async reativar(id: number) {
    try {
      const { data: cliente } = await supabase
        .from('clientes')
        .select('id')
        .eq('id', id)
        .single();

      if (!cliente) {
        throw new Error('Cliente não encontrado');
      }

      const { error } = await supabase
        .from('clientes')
        .update({ status: 'ativo' })
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao reativar cliente');
      }

      return {
        success: true,
        message: 'Cliente reativado com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao reativar cliente:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  }
}; 