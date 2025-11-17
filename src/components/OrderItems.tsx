import React, { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Plus, Trash2, Loader2, RefreshCw } from "lucide-react";
import { OrderItem } from "@/hooks/useOrders";
import { useProductsForSale, Product } from "@/hooks/useProductsForSale";
import { useToast } from "@/hooks/use-toast";
import { ProductSelect } from "@/components/ProductSelect";
import { supabase } from "@/lib/supabase";

// A interface Product já inclui os campos de estoque separados

interface OrderItemsProps {
  items: OrderItem[];
  onItemsChange: (items: OrderItem[]) => void;
  tipoPedido?: 'pronta_entrega' | 'encomenda';
}

export function OrderItems({ items, onItemsChange, tipoPedido = 'pronta_entrega' }: OrderItemsProps) {
  const { products, loading: productsLoading, error: productsError, fetchProductsForSale } = useProductsForSale();
  const { toast } = useToast();
  const [newItem, setNewItem] = useState({
    productId: "",
    productName: "",
    quantity: 1,
    unitPrice: 0
  });

  const addItem = () => {
    try {
      if (!newItem.productId || !newItem.productName || newItem.unitPrice <= 0) {
        toast({
          title: "Erro ao adicionar item",
          description: "Por favor, selecione um produto e verifique o preço.",
          variant: "destructive",
        });
        return;
      }

      if (newItem.quantity <= 0) {
        toast({
          title: "Erro ao adicionar item",
          description: "A quantidade deve ser maior que zero.",
          variant: "destructive",
        });
        return;
      }

      const item: OrderItem = {
        id: Date.now().toString(),
        productId: parseInt(newItem.productId),
        productName: newItem.productName,
        quantity: newItem.quantity,
        unitPrice: newItem.unitPrice,
        total: newItem.quantity * newItem.unitPrice
      };

      console.log('Adicionando item:', item);
      
      onItemsChange([...items, item]);
      setNewItem({ productId: "", productName: "", quantity: 1, unitPrice: 0 });
      
      toast({
        title: "Item adicionado",
        description: `${item.productName} foi adicionado ao pedido.`,
      });
    } catch (error) {
      console.error('Erro ao adicionar item:', error);
      toast({
        title: "Erro ao adicionar item",
        description: "Ocorreu um erro inesperado. Tente novamente.",
        variant: "destructive",
      });
    }
  };

  const removeItem = (id: string) => {
    try {
      onItemsChange(items.filter(item => item.id !== id));
      toast({
        title: "Item removido",
        description: "O item foi removido do pedido.",
      });
    } catch (error) {
      console.error('Erro ao remover item:', error);
      toast({
        title: "Erro ao remover item",
        description: "Ocorreu um erro inesperado. Tente novamente.",
        variant: "destructive",
      });
    }
  };

  const updateItem = (id: string, field: string, value: any) => {
    try {
      const updatedItems = items.map(item => {
        if (item.id === id) {
          const updated = { ...item, [field]: value };
          if (field === 'quantity' || field === 'unitPrice') {
            updated.total = updated.quantity * updated.unitPrice;
          }
          return updated;
        }
        return item;
      });
      onItemsChange(updatedItems);
    } catch (error) {
      console.error('Erro ao atualizar item:', error);
      toast({
        title: "Erro ao atualizar item",
        description: "Ocorreu um erro inesperado. Tente novamente.",
        variant: "destructive",
      });
    }
  };

  const updateItemProduct = async (id: string, productId: number) => {
    try {
      let selectedProduct: Product | undefined = products.find(p => p.id === productId);
      
      // Se não encontrou nos produtos da lista atual, buscar diretamente no banco
      if (!selectedProduct) {
        try {
          const { data: produto, error } = await supabase
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
            .eq('id', productId)
            .single();

          if (produto && !error) {
            selectedProduct = {
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
            };
          }
        } catch (fetchError) {
          console.error('Erro ao buscar produto:', fetchError);
        }
      }

      if (!selectedProduct) {
        toast({
          title: "Produto não encontrado",
          description: "O produto selecionado não foi encontrado no banco de dados.",
          variant: "destructive",
        });
        return;
      }

      const updatedItems = items.map(item => {
        if (item.id === id) {
          const updated = { 
            ...item, 
            productId: selectedProduct!.id,
            productName: selectedProduct!.nome,
            unitPrice: Number(selectedProduct!.preco_venda) || 0
          };
          updated.total = updated.quantity * updated.unitPrice;
          return updated;
        }
        return item;
      });
      onItemsChange(updatedItems);
      
      // Mostrar aviso se produto está inativo
      if (selectedProduct.status === 'inativo') {
        toast({
          title: "Produto inativo",
          description: `O produto "${selectedProduct.nome}" está marcado como inativo.`,
          variant: "destructive",
        });
      }
    } catch (error) {
      console.error('Erro ao atualizar produto do item:', error);
      toast({
        title: "Erro ao atualizar produto",
        description: "Ocorreu um erro inesperado. Tente novamente.",
        variant: "destructive",
      });
    }
  };

  const handleProductSelect = (productId: string) => {
    try {
      if (!productId) {
        setNewItem(prev => ({
          ...prev,
          productId: "",
          productName: "",
          unitPrice: 0
        }));
        return;
      }

      const selectedProduct = products.find(p => p.id === parseInt(productId));
      if (selectedProduct) {
        setNewItem(prev => ({
          ...prev,
          productId,
          productName: selectedProduct.nome,
          unitPrice: Number(selectedProduct.preco_venda) || 0
        }));
      }
    } catch (error) {
      console.error('Erro ao selecionar produto:', error);
      toast({
        title: "Erro ao selecionar produto",
        description: "Ocorreu um erro inesperado. Tente novamente.",
        variant: "destructive",
      });
    }
  };

  const handleRefreshProducts = async () => {
    try {
      await fetchProductsForSale();
      toast({
        title: "Produtos atualizados",
        description: "A lista de produtos foi atualizada com sucesso.",
      });
    } catch (error) {
      toast({
        title: "Erro ao atualizar",
        description: "Não foi possível atualizar a lista de produtos.",
        variant: "destructive",
      });
    }
  };

  const totalValue = items.reduce((sum, item) => sum + (item.total || 0), 0);

  // Log para debug
  console.log('OrderItems - Products:', products);
  console.log('OrderItems - Products loading:', productsLoading);
  console.log('OrderItems - Products error:', productsError);
  console.log('OrderItems - Current items:', items);

  if (productsError) {
    return (
      <div className="space-y-4">
        <Label>Itens do Pedido *</Label>
        <div className="p-4 border border-red-200 rounded-md bg-red-50">
          <p className="text-red-700 mb-3">
            Erro ao carregar produtos: {productsError}
          </p>
          <Button 
            variant="outline" 
            size="sm"
            onClick={handleRefreshProducts}
            disabled={productsLoading}
          >
            {productsLoading ? (
              <Loader2 className="w-4 h-4 mr-2 animate-spin" />
            ) : (
              <RefreshCw className="w-4 h-4 mr-2" />
            )}
            Tentar novamente
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <Label className="text-base font-medium text-gray-700">Adicionar Produtos *</Label>
        <Button 
          variant="outline" 
          size="sm"
          onClick={handleRefreshProducts}
          disabled={productsLoading}
          className="hover:bg-gray-50 transition-colors"
        >
          {productsLoading ? (
            <Loader2 className="w-4 h-4 mr-2 animate-spin" />
          ) : (
            <RefreshCw className="w-4 h-4 mr-2" />
          )}
          Atualizar
        </Button>
      </div>
      
      {/* Add new item - Layout responsivo */}
      <div className="p-4 bg-gradient-to-br from-gray-50 to-white border-2 border-dashed border-gray-300 rounded-xl">
        <div className="grid grid-cols-12 gap-3 items-end">
          <div className="col-span-12 sm:col-span-5">
            <Label htmlFor="productSelect" className="text-xs font-semibold text-gray-600">Produto</Label>
            <ProductSelect
              value={newItem.productId || ""}
              onValueChange={handleProductSelect}
              placeholder={productsLoading ? "Carregando..." : "Selecione um produto"}
              tipoPedido={tipoPedido}
              disabled={productsLoading}
            />
          </div>
          <div className="col-span-4 sm:col-span-2">
            <Label htmlFor="quantity" className="text-xs font-semibold text-gray-600">Qtd</Label>
            <Input
              id="quantity"
              type="number"
              min="1"
              value={newItem.quantity}
              onChange={(e) => setNewItem(prev => ({ ...prev, quantity: parseInt(e.target.value) || 1 }))}
              className="font-medium"
            />
          </div>
          <div className="col-span-5 sm:col-span-3">
            <Label htmlFor="unitPrice" className="text-xs font-semibold text-gray-600">Preço Unit.</Label>
            <Input
              id="unitPrice"
              type="number"
              step="0.01"
              min="0"
              value={newItem.unitPrice}
              onChange={(e) => setNewItem(prev => ({ ...prev, unitPrice: parseFloat(e.target.value) || 0 }))}
              className="bg-gray-100 font-medium"
              readOnly
            />
          </div>
          <div className="col-span-3 sm:col-span-2">
            <Button 
              type="button" 
              onClick={addItem} 
              size="sm" 
              className="w-full bg-green-600 hover:bg-green-700 text-white font-semibold shadow-sm"
              disabled={!newItem.productId || newItem.unitPrice <= 0 || productsLoading}
            >
              <Plus className="w-4 h-4 sm:mr-1" />
              <span className="hidden sm:inline">Adicionar</span>
            </Button>
          </div>
        </div>
      </div>

      {/* Items list - Layout responsivo: cards no mobile, tabela no desktop */}
      {items.length > 0 && (
        <>
          {/* Layout Mobile: Cards verticais (sem scroll horizontal) */}
          <div className="lg:hidden space-y-3">
            {items.map((item, index) => (
              <div 
                key={item.id}
                className="p-4 bg-white border-2 border-gray-200 rounded-xl shadow-sm hover:shadow-md transition-shadow"
              >
                <div className="space-y-3">
                  {/* Produto - Nome simples */}
                  <div>
                    <Label className="text-xs font-semibold text-gray-600 mb-1.5 block">Produto</Label>
                    <div className="p-3 bg-gray-50 rounded-md border border-gray-200">
                      <p className="text-sm font-semibold text-gray-800">{item.productName}</p>
                    </div>
                  </div>

                  {/* Quantidade e Valores */}
                  <div className="grid grid-cols-3 gap-3">
                    <div>
                      <Label className="text-xs font-semibold text-gray-600 mb-1.5 block">Qtd</Label>
                      <Input
                        type="number"
                        min="1"
                        value={item.quantity}
                        onChange={(e) => updateItem(item.id, 'quantity', parseInt(e.target.value) || 1)}
                        className="font-semibold text-center"
                      />
                    </div>
                    <div>
                      <Label className="text-xs font-semibold text-gray-600 mb-1.5 block">Preço Unit.</Label>
                      <div className="h-10 flex items-center justify-center bg-gray-50 rounded-md border">
                        <span className="text-sm font-semibold text-gray-700">
                          R$ {(item.unitPrice || 0).toFixed(2)}
                        </span>
                      </div>
                    </div>
                    <div>
                      <Label className="text-xs font-semibold text-gray-600 mb-1.5 block">Total</Label>
                      <div className="h-10 flex items-center justify-center bg-green-50 rounded-md border border-green-200">
                        <span className="text-sm font-bold text-green-700">
                          R$ {(item.total || 0).toFixed(2)}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Botão remover */}
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => removeItem(item.id)}
                    className="w-full text-red-600 hover:bg-red-50 hover:text-red-700 hover:border-red-300 transition-colors"
                  >
                    <Trash2 className="w-4 h-4 mr-2" />
                    Remover Item
                  </Button>
                </div>
              </div>
            ))}

          </div>

          {/* Layout Desktop: Tabela (mantém o design atual) */}
          <div className="hidden lg:block border-2 border-gray-200 rounded-xl overflow-hidden shadow-sm">
            <Table>
              <TableHeader>
                <TableRow className="bg-gradient-to-r from-gray-50 to-gray-100 border-b-2 border-gray-300">
                  <TableHead className="min-w-[200px] w-[45%] font-bold text-gray-700">Produto</TableHead>
                  <TableHead className="min-w-[80px] w-[12%] font-bold text-gray-700">Qtd</TableHead>
                  <TableHead className="min-w-[100px] w-[15%] font-bold text-gray-700">Preço Unit.</TableHead>
                  <TableHead className="min-w-[100px] w-[15%] font-bold text-gray-700">Total</TableHead>
                  <TableHead className="min-w-[80px] w-[13%] text-right font-bold text-gray-700">Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((item, index) => (
                  <TableRow 
                    key={item.id}
                    className={`transition-colors hover:bg-gray-50 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-50/50'}`}
                  >
                    <TableCell className="min-w-[200px] w-[45%] py-3">
                      <div className="flex items-center">
                        <p className="text-sm font-medium text-gray-800">{item.productName}</p>
                      </div>
                    </TableCell>
                    <TableCell className="min-w-[80px] py-3">
                      <Input
                        type="number"
                        min="1"
                        value={item.quantity}
                        onChange={(e) => updateItem(item.id, 'quantity', parseInt(e.target.value) || 1)}
                        className="border-0 p-0 h-auto focus-visible:ring-0 w-16 font-semibold text-center"
                      />
                    </TableCell>
                    <TableCell className="min-w-[100px] py-3">
                      <div className="text-sm font-semibold whitespace-nowrap text-gray-700">
                        R$ {(item.unitPrice || 0).toFixed(2)}
                      </div>
                    </TableCell>
                    <TableCell className="min-w-[100px] py-3">
                      <div className="text-sm font-bold whitespace-nowrap text-green-700">
                        R$ {(item.total || 0).toFixed(2)}
                      </div>
                    </TableCell>
                    <TableCell className="min-w-[80px] text-right py-3">
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        onClick={() => removeItem(item.id)}
                        className="h-8 w-8 p-0 hover:bg-red-50 hover:text-red-600 transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </>
      )}

      {items.length === 0 && (
        <div className="text-center py-12 border-2 border-dashed border-gray-300 rounded-xl bg-gray-50">
          <svg className="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
          </svg>
          <p className="text-gray-500 font-medium text-lg">Nenhum item adicionado ao pedido</p>
          <p className="text-gray-400 text-sm mt-2">Selecione produtos acima para adicionar</p>
        </div>
      )}
    </div>
  );
}
