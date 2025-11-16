import { useState, useEffect } from "react";
import api from "@/services/api";

export interface Product {
  id: number;
  nome: string;
  descricao?: string;
  preco_venda: number;
  preco_custo: number;
  quantidade_minima: number;
  quantidade_atual: number;
  quantidade_pronta_entrega: number;
  quantidade_encomenda: number;
  categoria: string;
  unidade_medida: string;
  tipo_produto: string;
  imagem_url?: string;
  status?: string;
}

export const useProducts = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await api.produtos.listar();
      
      if (response.success) {
        // Garantir que os produtos têm os campos corretos
        const produtosFormatados = response.data.map((produto: any) => ({
          ...produto,
          preco_venda: Number(produto.preco_venda) || 0,
          quantidade_atual: Number(produto.quantidade_atual) || 0,
          preco_custo: Number(produto.preco_custo) || 0,
          quantidade_minima: Number(produto.quantidade_minima) || 0
        }));
        
        setProducts(produtosFormatados);
      } else {
        throw new Error('Erro ao carregar produtos');
      }
    } catch (err: any) {
      console.error('Erro ao buscar produtos:', err);
      setError(err.message || 'Erro ao carregar produtos');
    } finally {
      setLoading(false);
    }
  };

  const fetchProductsForSale = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await api.produtos.listarParaVenda();
      
      if (response.success) {
        // Garantir que os produtos têm os campos corretos
        const produtosFormatados = response.data.map((produto: any) => ({
          ...produto,
          preco_venda: Number(produto.preco_venda) || 0,
          quantidade_atual: Number(produto.quantidade_atual) || 0,
          preco_custo: Number(produto.preco_custo) || 0,
          quantidade_minima: Number(produto.quantidade_minima) || 0
        }));
        
        setProducts(produtosFormatados);
      } else {
        throw new Error('Erro ao carregar produtos para venda');
      }
    } catch (err: any) {
      console.error('Erro ao buscar produtos para venda:', err);
      setError(err.message || 'Erro ao carregar produtos para venda');
    } finally {
      setLoading(false);
    }
  };

  const addProduct = async (productData: Omit<Product, 'id'>) => {
    try {
      const response = await api.produtos.criar(productData);
      
      if (response.success) {
        setProducts(prev => [...prev, response.data]);
        return response.data;
      } else {
        throw new Error(response.message || 'Erro ao criar produto');
      }
    } catch (err: any) {
      console.error('Erro ao criar produto:', err);
      throw new Error(err.message || 'Erro ao criar produto');
    }
  };

  const updateProduct = async (id: number, productData: Omit<Product, 'id'>) => {
    try {
      const response = await api.produtos.atualizar(id, productData);
      
      if (response.success) {
        // Recarregar lista após atualizar
        await fetchProducts();
        return response;
      } else {
        throw new Error(response.message || 'Erro ao atualizar produto');
      }
    } catch (err: any) {
      console.error('Erro ao atualizar produto:', err);
      throw new Error(err.message || 'Erro ao atualizar produto');
    }
  };

  const deleteProduct = async (id: number) => {
    try {
      const response = await api.produtos.excluir(id);
      
      if (response.success) {
        setProducts(prev => prev.filter(p => p.id !== id));
      } else {
        throw new Error(response.message || 'Erro ao deletar produto');
      }
    } catch (err: any) {
      console.error('Erro ao deletar produto:', err);
      throw new Error(err.message || 'Erro ao deletar produto');
    }
  };

  useEffect(() => {
    // Por padrão, buscar todos os produtos (para administração)
    fetchProducts();
  }, []);

  return {
    products,
    loading,
    error,
    addProduct,
    updateProduct,
    deleteProduct,
    refreshProducts: fetchProducts,
    fetchProductsForSale,
    fetchAllProducts: fetchProducts
  };
};
