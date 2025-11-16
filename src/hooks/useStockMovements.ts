import { useState, useEffect } from "react";
import api from "@/services/api";

export interface StockMovement {
  id: number;
  produto_id: number;
  produto_nome: string;
  unidade_medida: string;
  categoria: string;
  tipo_movimento: "entrada" | "saida" | "ajuste";
  quantidade: number;
  motivo: string;
  valor?: number;
  documento_referencia?: string;
  data_fabricacao?: string;
  data_validade?: string;
  observacao?: string;
  data_movimentacao: string;
  quantidade_atual?: number;
}

export function useStockMovements() {
  const [movements, setMovements] = useState<StockMovement[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Carregar movimentações
  const loadMovements = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await api.estoque.listarMovimentacoes();
      
      if (response && response.success) {
        setMovements(response.data || []);
      } else {
        console.error('❌ Resposta da API sem sucesso:', response);
        throw new Error('Erro ao carregar movimentações - resposta inválida');
      }
    } catch (err: any) {
      console.error('❌ Erro ao carregar movimentações:', err);
      setError(err.message || 'Erro ao carregar movimentações');
      setMovements([]);
    } finally {
      setLoading(false);
    }
  };

  // Carregar movimentações ao montar o componente
  useEffect(() => {
    loadMovements();
  }, []);

  // Adicionar movimentação
  const addMovement = async (movementData: Omit<StockMovement, 'id'>) => {
    try {
      const response = await api.estoque.movimentar(movementData);
      
      if (response.success) {
        // Recarregar lista após adicionar
        await loadMovements();
        return response;
      } else {
        throw new Error('Erro ao adicionar movimentação');
      }
    } catch (err) {
      console.error('Erro ao adicionar movimentação:', err);
      throw err;
    }
  };

  // Atualizar movimentação
  const updateMovement = async (id: number, movementData: Omit<StockMovement, 'id'>) => {
    try {
      const response = await api.estoque.atualizarMovimentacao(id, movementData);
      
      if (response.success) {
        // Recarregar lista após atualizar
        await loadMovements();
        return response;
      } else {
        throw new Error('Erro ao atualizar movimentação');
      }
    } catch (err) {
      console.error('Erro ao atualizar movimentação:', err);
      throw err;
    }
  };

  // Deletar movimentação
  const deleteMovement = async (id: number) => {
    try {
      const response = await api.estoque.deletarMovimentacao(id);
      
      if (response.success) {
        setMovements(prev => prev.filter(m => m.id !== id));
      } else {
        throw new Error('Erro ao deletar movimentação');
      }
    } catch (err) {
      console.error('Erro ao deletar movimentação:', err);
      throw err;
    }
  };

  // Buscar movimentação por ID
  const getMovement = async (id: number) => {
    try {
      const response = await api.estoque.buscarMovimentacaoPorId(id);
      
      if (response.success) {
        return response.data;
      } else {
        throw new Error('Erro ao buscar movimentação');
      }
    } catch (err) {
      console.error('Erro ao buscar movimentação:', err);
      throw err;
    }
  };

  // Buscar produtos com estoque baixo
  const getLowStockProducts = async () => {
    try {
      const response = await api.estoque.buscarEstoqueBaixo();
      
      if (response && response.success) {
        return response.data || [];
      } else {
        console.warn('⚠️ Falha ao buscar produtos com estoque baixo:', response);
        return [];
      }
    } catch (err) {
      console.error('❌ Erro ao buscar produtos com estoque baixo:', err);
      return []; // Retorna array vazio ao invés de lançar erro
    }
  };

  // Buscar relatório de estoque
  const getStockReport = async () => {
    try {
      const response = await api.estoque.relatorioEstoque();
      
      if (response && response.success) {
        return response.data || null;
      } else {
        console.warn('⚠️ Falha ao buscar relatório de estoque:', response);
        return null;
      }
    } catch (err) {
      console.error('❌ Erro ao buscar relatório de estoque:', err);
      return null; // Retorna null ao invés de lançar erro
    }
  };

  return {
    movements,
    loading,
    error,
    addMovement,
    updateMovement,
    deleteMovement,
    getMovement,
    getLowStockProducts,
    getStockReport,
    reloadMovements: loadMovements
  };
}
