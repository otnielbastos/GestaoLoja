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

export const useProductsForSale = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

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
          quantidade_pronta_entrega: Number(produto.quantidade_pronta_entrega) || 0,
          quantidade_encomenda: Number(produto.quantidade_encomenda) || 0,
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

  useEffect(() => {
    fetchProductsForSale();
  }, []);

  return {
    products,
    loading,
    error,
    refreshProducts: fetchProductsForSale,
    fetchProductsForSale
  };
}; 