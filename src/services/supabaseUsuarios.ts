import { supabase } from '../lib/supabase';
import { authService } from './supabaseAuth';
import bcrypt from 'bcryptjs';

interface UsuarioData {
  nome: string;
  email: string;
  password?: string;
  perfil_id: number;
  ativo?: boolean;
}

interface FiltrosUsuarios {
  page?: number;
  limit?: number;
  search?: string;
  perfil?: string;
  status?: 'ativo' | 'inativo' | '';
}

// Função para hash da senha
const hashPassword = async (password: string): Promise<string> => {
  const salt = await bcrypt.genSalt(12);
  return bcrypt.hash(password, salt);
};

// Função para registrar auditoria
const registrarAuditoria = async (
  usuarioId: number,
  acao: string,
  tabela: string,
  registroId: number,
  dadosAntigos?: any,
  dadosNovos?: any
) => {
  try {
    await supabase
      .from('auditoria')
      .insert({
        usuario_id: usuarioId,
        acao,
        tabela,
        registro_id: registroId,
        dados_antigos: dadosAntigos,
        dados_novos: dadosNovos,
        ip_address: '127.0.0.1', // Seria obtido do request em um ambiente real
        user_agent: navigator.userAgent
      });
  } catch (error) {
    console.error('Erro ao registrar auditoria:', error);
  }
};

export const usuariosService = {
  // Listar usuários com paginação e filtros
  async listar(filtros: FiltrosUsuarios = {}) {
    try {
      const {
        page = 1,
        limit = 10,
        search = '',
        perfil = '',
        status = ''
      } = filtros;

      const offset = (page - 1) * limit;

      let query = supabase
        .from('usuarios')
        .select(`
          id,
          nome,
          email,
          ativo,
          ultimo_acesso,
          data_criacao,
          perfil:perfis(id, nome)
        `);

      // REGRA DE NEGÓCIO: Aplicar filtros
      if (search) {
        query = query.or(`nome.ilike.%${search}%,email.ilike.%${search}%`);
      }

      if (perfil) {
        query = query.eq('perfis.nome', perfil);
      }

      if (status === 'ativo') {
        query = query.eq('ativo', true);
      } else if (status === 'inativo') {
        query = query.eq('ativo', false);
      }

      // Contar total de registros
      const { count: total } = await supabase
        .from('usuarios')
        .select('*', { count: 'exact', head: true });

      // Aplicar paginação e ordenação
      const { data: usuarios, error } = await query
        .order('data_criacao', { ascending: false })
        .range(offset, offset + limit - 1);

      if (error) throw new Error('Erro ao buscar usuários');

      return {
        success: true,
        data: {
          usuarios: usuarios || [],
          pagination: {
            current_page: page,
            per_page: limit,
            total: total || 0,
            total_pages: Math.ceil((total || 0) / limit)
          }
        }
      };

    } catch (error: any) {
      console.error('Erro ao listar usuários:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar usuário por ID
  async buscarPorId(id: number) {
    try {
      const { data: usuario, error } = await supabase
        .from('usuarios')
        .select(`
          id,
          nome,
          email,
          ativo,
          ultimo_acesso,
          data_criacao,
          data_atualizacao,
          perfil:perfis(id, nome)
        `)
        .eq('id', id)
        .single();

      if (error) throw new Error('Usuário não encontrado');

      return {
        success: true,
        data: usuario
      };

    } catch (error: any) {
      console.error('Erro ao buscar usuário:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Criar usuário
  async criar(data: UsuarioData) {
    try {
      const { nome, email, password, perfil_id } = data;

      // REGRA DE NEGÓCIO: Validações obrigatórias
      if (!nome || nome.trim().length < 2) {
        throw new Error('Nome deve ter pelo menos 2 caracteres');
      }

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        throw new Error('Email inválido');
      }

      if (!perfil_id || perfil_id < 1) {
        throw new Error('Perfil inválido');
      }

      // REGRA DE NEGÓCIO: Verificar se o email já existe
      const { data: usuarioExistente } = await supabase
        .from('usuarios')
        .select('id')
        .eq('email', email.toLowerCase())
        .single();

      if (usuarioExistente) {
        throw new Error('Email já está em uso');
      }

      // REGRA DE NEGÓCIO: Verificar se o perfil existe e está ativo
      const { data: perfil } = await supabase
        .from('perfis')
        .select('id, nome')
        .eq('id', perfil_id)
        .eq('ativo', true)
        .single();

      if (!perfil) {
        throw new Error('Perfil inválido ou inativo');
      }

      // REGRA DE NEGÓCIO: Gerar senha padrão se não fornecida
      const senhaFinal = password || 'usuario123';
      const senhaHash = await hashPassword(senhaFinal);

      const { data: usuario, error } = await supabase
        .from('usuarios')
        .insert({
          nome: nome.trim(),
          email: email.toLowerCase(),
          senha: '', // Campo em branco por segurança
          senha_hash: senhaHash,
          perfil_id,
          ativo: true,
          status: 'ativo',
          criado_por: authService.getCurrentUserId()
        })
        .select()
        .single();

      if (error) {
        throw new Error('Erro ao criar usuário');
      }

      const novoUsuario = {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
        perfil_id,
        perfil: perfil.nome,
        ativo: true
      };

      await registrarAuditoria(
        authService.getCurrentUserId()!,
        'CREATE',
        'usuarios',
        usuario.id,
        null,
        novoUsuario
      );

      return {
        success: true,
        message: 'Usuário criado com sucesso',
        data: novoUsuario
      };

    } catch (error: any) {
      console.error('Erro ao criar usuário:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Atualizar usuário
  async atualizar(id: number, data: Partial<UsuarioData>) {
    try {
      const { nome, email, password, perfil_id, ativo } = data;

      // REGRA DE NEGÓCIO: Buscar usuário atual
      const { data: usuarioAtual, error: usuarioError } = await supabase
        .from('usuarios')
        .select('*')
        .eq('id', id)
        .single();

      if (usuarioError || !usuarioAtual) {
        throw new Error('Usuário não encontrado');
      }

      // REGRA DE NEGÓCIO: Validações
      if (nome !== undefined && nome.trim().length < 2) {
        throw new Error('Nome deve ter pelo menos 2 caracteres');
      }

      if (email !== undefined && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        throw new Error('Email inválido');
      }

      if (password !== undefined && password.trim() !== '' && password.length < 6) {
        throw new Error('Senha deve ter pelo menos 6 caracteres');
      }

      if (perfil_id !== undefined && perfil_id < 1) {
        throw new Error('Perfil inválido');
      }

      // REGRA DE NEGÓCIO: Verificar duplicata de email (exceto o próprio usuário)
      if (email && email.toLowerCase() !== usuarioAtual.email) {
        const { data: emailExistente } = await supabase
          .from('usuarios')
          .select('id')
          .eq('email', email.toLowerCase())
          .neq('id', id)
          .single();

        if (emailExistente) {
          throw new Error('Email já está em uso');
        }
      }

      // REGRA DE NEGÓCIO: Verificar se perfil existe e está ativo
      if (perfil_id) {
        const { data: perfil } = await supabase
          .from('perfis')
          .select('id')
          .eq('id', perfil_id)
          .eq('ativo', true)
          .single();

        if (!perfil) {
          throw new Error('Perfil inválido ou inativo');
        }
      }

      // REGRA DE NEGÓCIO: Não permitir que o usuário desative a si mesmo
      const usuarioLogado = authService.getCurrentUserId();
      if (usuarioLogado === id && ativo === false) {
        throw new Error('Você não pode desativar sua própria conta');
      }

      const updateData: any = {
        data_atualizacao: new Date().toISOString(),
        atualizado_por: usuarioLogado
      };

      if (nome !== undefined) updateData.nome = nome.trim();
      if (email !== undefined) updateData.email = email.toLowerCase();
      if (perfil_id !== undefined) updateData.perfil_id = perfil_id;
      if (ativo !== undefined) updateData.ativo = ativo;

      // REGRA DE NEGÓCIO: Se senha foi fornecida, fazer hash e atualizar
      if (password !== undefined && password.trim() !== '') {
        const senhaHash = await hashPassword(password.trim());
        updateData.senha_hash = senhaHash;
        updateData.tentativas_login = 0;
        updateData.bloqueado_ate = null;
        
        // Desativar todas as sessões do usuário para forçar novo login
        await supabase
          .from('sessoes')
          .update({ ativo: false })
          .eq('usuario_id', id);
      }

      const { error } = await supabase
        .from('usuarios')
        .update(updateData)
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao atualizar usuário');
      }

      await registrarAuditoria(
        usuarioLogado!,
        'UPDATE',
        'usuarios',
        id,
        usuarioAtual,
        { ...updateData, password: password ? '***' : undefined } // Não registrar senha em texto
      );

      return {
        success: true,
        message: password && password.trim() !== '' 
          ? 'Usuário atualizado com sucesso. Senha alterada.' 
          : 'Usuário atualizado com sucesso'
      };

    } catch (error: any) {
      console.error('Erro ao atualizar usuário:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // REGRA DE NEGÓCIO: Desativar usuário (não excluir)
  async desativar(id: number) {
    try {
      const usuarioLogado = authService.getCurrentUserId();

      // REGRA DE NEGÓCIO: Não permitir desativar a si mesmo
      if (usuarioLogado === id) {
        throw new Error('Você não pode desativar sua própria conta');
      }

      const { data: usuario } = await supabase
        .from('usuarios')
        .select('nome, ativo')
        .eq('id', id)
        .single();

      if (!usuario) {
        throw new Error('Usuário não encontrado');
      }

      if (!usuario.ativo) {
        throw new Error('Usuário já está desativado');
      }

      const { error } = await supabase
        .from('usuarios')
        .update({
          ativo: false,
          data_atualizacao: new Date().toISOString(),
          atualizado_por: usuarioLogado
        })
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao desativar usuário');
      }

      // REGRA DE NEGÓCIO: Desativar todas as sessões do usuário
      await supabase
        .from('sessoes')
        .update({ ativo: false })
        .eq('usuario_id', id);

      await registrarAuditoria(
        usuarioLogado!,
        'DEACTIVATE',
        'usuarios',
        id,
        { ativo: true },
        { ativo: false }
      );

      return {
        success: true,
        message: `Usuário ${usuario.nome} desativado com sucesso`
      };

    } catch (error: any) {
      console.error('Erro ao desativar usuário:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Reativar usuário
  async reativar(id: number) {
    try {
      const usuarioLogado = authService.getCurrentUserId();

      const { data: usuario } = await supabase
        .from('usuarios')
        .select('nome, ativo')
        .eq('id', id)
        .single();

      if (!usuario) {
        throw new Error('Usuário não encontrado');
      }

      if (usuario.ativo) {
        throw new Error('Usuário já está ativo');
      }

      const { error } = await supabase
        .from('usuarios')
        .update({
          ativo: true,
          status: 'ativo',
          tentativas_login: 0,
          bloqueado_ate: null,
          data_atualizacao: new Date().toISOString(),
          atualizado_por: usuarioLogado
        })
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao reativar usuário');
      }

      await registrarAuditoria(
        usuarioLogado!,
        'REACTIVATE',
        'usuarios',
        id,
        { ativo: false },
        { ativo: true }
      );

      return {
        success: true,
        message: `Usuário ${usuario.nome} reativado com sucesso`
      };

    } catch (error: any) {
      console.error('Erro ao reativar usuário:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // REGRA DE NEGÓCIO: Resetar senha do usuário
  async resetarSenha(id: number, novaSenha?: string) {
    try {
      const usuarioLogado = authService.getCurrentUserId();

      const { data: usuario } = await supabase
        .from('usuarios')
        .select('nome')
        .eq('id', id)
        .single();

      if (!usuario) {
        throw new Error('Usuário não encontrado');
      }

      // REGRA DE NEGÓCIO: Senha padrão se não informada
      const senhaFinal = novaSenha || 'usuario123';
      const senhaHash = await hashPassword(senhaFinal);

      const { error } = await supabase
        .from('usuarios')
        .update({
          senha_hash: senhaHash,
          tentativas_login: 0,
          bloqueado_ate: null,
          data_atualizacao: new Date().toISOString(),
          atualizado_por: usuarioLogado
        })
        .eq('id', id);

      if (error) {
        throw new Error('Erro ao resetar senha');
      }

      // REGRA DE NEGÓCIO: Desativar todas as sessões do usuário para forçar novo login
      await supabase
        .from('sessoes')
        .update({ ativo: false })
        .eq('usuario_id', id);

      await registrarAuditoria(
        usuarioLogado!,
        'RESET_PASSWORD',
        'usuarios',
        id,
        null,
        { action: 'password_reset' }
      );

      return {
        success: true,
        message: `Senha do usuário ${usuario.nome} resetada com sucesso. Nova senha: ${senhaFinal}`
      };

    } catch (error: any) {
      console.error('Erro ao resetar senha:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar perfis disponíveis
  async buscarPerfis() {
    try {
      const { data: perfis, error } = await supabase
        .from('perfis')
        .select('*')
        .eq('ativo', true)
        .order('nome');

      if (error) throw new Error('Erro ao buscar perfis');

      return {
        success: true,
        data: perfis || []
      };

    } catch (error: any) {
      console.error('Erro ao buscar perfis:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Estatísticas de usuários
  async estatisticas() {
    try {
      // Total de usuários
      const { count: totalUsuarios } = await supabase
        .from('usuarios')
        .select('*', { count: 'exact', head: true });

      // Usuários ativos
      const { count: usuariosAtivos } = await supabase
        .from('usuarios')
        .select('*', { count: 'exact', head: true })
        .eq('ativo', true);

      // Usuários inativos
      const { count: usuariosInativos } = await supabase
        .from('usuarios')
        .select('*', { count: 'exact', head: true })
        .eq('ativo', false);

      // Usuários por perfil
      const { data: usuariosPorPerfil } = await supabase
        .from('usuarios')
        .select(`
          perfil_id,
          perfil:perfis(nome)
        `)
        .eq('ativo', true);

      const estatisticasPerfis = usuariosPorPerfil?.reduce((acc, usuario) => {
        const perfil = (usuario.perfil as any)?.nome || 'Sem perfil';
        acc[perfil] = (acc[perfil] || 0) + 1;
        return acc;
      }, {} as Record<string, number>) || {};

      // Últimos acessos
      const { data: ultimosAcessos } = await supabase
        .from('usuarios')
        .select('nome, ultimo_acesso')
        .eq('ativo', true)
        .not('ultimo_acesso', 'is', null)
        .order('ultimo_acesso', { ascending: false })
        .limit(5);

      return {
        success: true,
        data: {
          total_usuarios: totalUsuarios || 0,
          usuarios_ativos: usuariosAtivos || 0,
          usuarios_inativos: usuariosInativos || 0,
          usuarios_por_perfil: estatisticasPerfis,
          ultimos_acessos: ultimosAcessos || []
        }
      };

    } catch (error: any) {
      console.error('Erro ao buscar estatísticas:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Buscar permissões de um perfil
  async buscarPermissoesPerfil(perfilId: number) {
    try {
      console.log('🔍 Buscando permissões para perfil ID:', perfilId);
      
      const { data: perfil, error } = await supabase
        .from('perfis')
        .select('id, nome, permissoes')
        .eq('id', perfilId)
        .eq('ativo', true)
        .single();

      console.log('📋 Resultado da consulta perfil:', { perfil, error });

      if (error) {
        console.error('❌ Erro na consulta do perfil:', error);
        throw new Error('Perfil não encontrado');
      }

      if (!perfil) {
        console.error('❌ Perfil não encontrado para ID:', perfilId);
        throw new Error('Perfil não encontrado');
      }

      console.log('✅ Perfil encontrado:', {
        id: perfil.id,
        nome: perfil.nome,
        permissoes: perfil.permissoes
      });

      return {
        success: true,
        data: {
          id: perfil.id,
          nome: perfil.nome,
          permissoes: perfil.permissoes || { pages: [], actions: {} }
        }
      };

    } catch (error: any) {
      console.error('💥 Erro ao buscar permissões do perfil:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Criar novo perfil
  async criarPerfil(data: { nome: string; descricao: string; permissoes: any }) {
    try {
      console.log('🆕 Criando novo perfil:', data);

      const usuarioLogado = authService.getCurrentUserId();
      if (!usuarioLogado) {
        throw new Error('Usuário não autenticado');
      }

      // Verificar se o perfil já existe
      const { data: perfilExistente } = await supabase
        .from('perfis')
        .select('id')
        .eq('nome', data.nome)
        .single();

      if (perfilExistente) {
        throw new Error('Já existe um perfil com este nome');
      }

      const { data: novoPerfil, error } = await supabase
        .from('perfis')
        .insert({
          nome: data.nome,
          descricao: data.descricao,
          permissoes: data.permissoes,
          ativo: true
        })
        .select()
        .single();

      if (error) {
        console.error('❌ Erro ao criar perfil:', error);
        throw new Error('Erro ao criar perfil');
      }

      await registrarAuditoria(
        usuarioLogado,
        'CREATE',
        'perfis',
        novoPerfil.id,
        null,
        novoPerfil
      );

      return {
        success: true,
        data: novoPerfil,
        message: 'Perfil criado com sucesso'
      };

    } catch (error: any) {
      console.error('💥 Erro ao criar perfil:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Atualizar perfil existente
  async atualizarPerfil(id: number, data: { nome: string; descricao: string; permissoes: any }) {
    try {
      console.log('✏️ Atualizando perfil ID:', id, 'com dados:', data);

      const usuarioLogado = authService.getCurrentUserId();
      if (!usuarioLogado) {
        throw new Error('Usuário não autenticado');
      }

      // Buscar perfil atual
      const { data: perfilAtual, error: buscarError } = await supabase
        .from('perfis')
        .select('*')
        .eq('id', id)
        .single();

      if (buscarError || !perfilAtual) {
        throw new Error('Perfil não encontrado');
      }

      // Verificar se o nome não está sendo usado por outro perfil
      if (data.nome !== perfilAtual.nome) {
        const { data: perfilExistente } = await supabase
          .from('perfis')
          .select('id')
          .eq('nome', data.nome)
          .neq('id', id)
          .single();

        if (perfilExistente) {
          throw new Error('Já existe um perfil com este nome');
        }
      }

      const { data: perfilAtualizado, error } = await supabase
        .from('perfis')
        .update({
          nome: data.nome,
          descricao: data.descricao,
          permissoes: data.permissoes,
          data_atualizacao: new Date().toISOString()
        })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        console.error('❌ Erro ao atualizar perfil:', error);
        throw new Error('Erro ao atualizar perfil');
      }

      await registrarAuditoria(
        usuarioLogado,
        'UPDATE',
        'perfis',
        id,
        perfilAtual,
        perfilAtualizado
      );

      return {
        success: true,
        data: perfilAtualizado,
        message: 'Perfil atualizado com sucesso'
      };

    } catch (error: any) {
      console.error('💥 Erro ao atualizar perfil:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  },

  // Excluir perfil
  async excluirPerfil(id: number) {
    try {
      console.log('🗑️ Excluindo perfil ID:', id);

      const usuarioLogado = authService.getCurrentUserId();
      if (!usuarioLogado) {
        throw new Error('Usuário não autenticado');
      }

      // Verificar se o perfil existe
      const { data: perfil, error: buscarError } = await supabase
        .from('perfis')
        .select('*')
        .eq('id', id)
        .single();

      if (buscarError || !perfil) {
        throw new Error('Perfil não encontrado');
      }

      // Verificar se há usuários usando este perfil
      const { count: usuariosComPerfil } = await supabase
        .from('usuarios')
        .select('*', { count: 'exact', head: true })
        .eq('perfil_id', id)
        .eq('ativo', true);

      if (usuariosComPerfil && usuariosComPerfil > 0) {
        throw new Error('Não é possível excluir um perfil que possui usuários ativos');
      }

      // Em vez de excluir, vamos desativar o perfil
      const { error } = await supabase
        .from('perfis')
        .update({
          ativo: false,
          data_atualizacao: new Date().toISOString()
        })
        .eq('id', id);

      if (error) {
        console.error('❌ Erro ao desativar perfil:', error);
        throw new Error('Erro ao excluir perfil');
      }

      await registrarAuditoria(
        usuarioLogado,
        'DELETE',
        'perfis',
        id,
        perfil,
        { ativo: false }
      );

      return {
        success: true,
        message: 'Perfil excluído com sucesso'
      };

    } catch (error: any) {
      console.error('💥 Erro ao excluir perfil:', error);
      throw new Error(error.message || 'Erro interno do servidor');
    }
  }
};

export const supabaseUsuarios = usuariosService;
export default usuariosService; 