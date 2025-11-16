import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Package, Plus, Search, Edit, Trash2, Filter } from "lucide-react";
import { useProducts, Product } from "@/hooks/useProducts";
import { ProductFormModal } from "@/components/ProductFormModal";
import { DeleteConfirmModal } from "@/components/DeleteConfirmModal";
import { getImageUrl } from "@/services/api";
import { usePageAccess } from "@/components/ProtectedComponent";
import { useToast } from "@/hooks/use-toast";

export function Products() {
  const { products, loading, error, addProduct, updateProduct, deleteProduct } = useProducts();
  const { hasActionAccess } = usePageAccess('produtos');
  const { toast } = useToast();
  const [searchTerm, setSearchTerm] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [showLowStock, setShowLowStock] = useState(false);
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [deletingProduct, setDeletingProduct] = useState<Product | null>(null);

  // Extract unique categories and product types
  const categories = [...new Set(products.map(p => p.categoria))];
  const productTypes = [
    { value: 'producao_propria', label: '🏪 Produção Própria' },
    { value: 'revenda', label: '🛒 Revenda' },
    { value: 'congelado', label: '🧊 Congelado' },
    { value: 'ingrediente', label: '🥄 Ingrediente' },
    { value: 'bebida', label: '🥤 Bebida' },
    { value: 'doce', label: '🍭 Doce' },
    { value: 'salgado', label: '🥨 Salgado' },
    { value: 'massa', label: '🍝 Massa' },
    { value: 'molho', label: '🍅 Molho' },
    { value: 'tempero', label: '🌿 Tempero' },
    { value: 'outros', label: '📦 Outros' }
  ];

  const handleCreateProduct = () => {
    setEditingProduct(null);
    setIsFormModalOpen(true);
  };

  const handleEditProduct = (product: Product) => {
    setEditingProduct(product);
    setIsFormModalOpen(true);
  };

  const handleDeleteProduct = (product: Product) => {
    setDeletingProduct(product);
    setIsDeleteModalOpen(true);
  };

  const handleFormSubmit = async (productData: Omit<Product, 'id'>) => {
    try {
      if (editingProduct) {
        await updateProduct(editingProduct.id, productData);
      } else {
        await addProduct(productData);
      }
      setIsFormModalOpen(false);
      setEditingProduct(null);
    } catch (error: any) {
      console.error('Error saving product:', error);
      // Handle error (show toast, etc.)
    }
  };

  const handleConfirmDelete = async () => {
    if (deletingProduct) {
      try {
        await deleteProduct(deletingProduct.id);
        toast({
          title: "Produto excluído",
          description: "O produto foi excluído com sucesso.",
        });
        setIsDeleteModalOpen(false);
        setDeletingProduct(null);
      } catch (error: any) {
        console.error('Error deleting product:', error);
        toast({
          title: "Erro ao excluir produto",
          description: error.message || "Não foi possível excluir o produto. Verifique se não há pedidos relacionados.",
          variant: "destructive",
          duration: 5000,
        });
      }
    }
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const getProductTypeInfo = (type: string) => {
    const typeInfo = productTypes.find(t => t.value === type);
    return {
      label: typeInfo?.label || '📦 Outros',
      color: type === 'producao_propria' ? 'bg-green-500' : 
             type === 'revenda' ? 'bg-blue-500' :
             type === 'congelado' ? 'bg-cyan-500' : 
             type === 'ingrediente' ? 'bg-yellow-500' :
             type === 'bebida' ? 'bg-purple-500' :
             type === 'doce' ? 'bg-pink-500' :
             type === 'salgado' ? 'bg-orange-500' :
             type === 'massa' ? 'bg-indigo-500' :
             type === 'molho' ? 'bg-red-500' :
             type === 'tempero' ? 'bg-green-600' :
             'bg-gray-500'
    };
  };

  // Apply filters
  const filteredProducts = products.filter(product => {
    const matchesSearch = product.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         product.categoria.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = !categoryFilter || product.categoria === categoryFilter;
    const matchesType = !typeFilter || product.tipo_produto === typeFilter;
    const matchesLowStock = !showLowStock || product.quantidade_atual <= product.quantidade_minima;
    
    return matchesSearch && matchesCategory && matchesType && matchesLowStock;
  });

  // Calculate stats
  const totalProducts = products.length;
  const lowStockProducts = products.filter(p => p.quantidade_atual <= p.quantidade_minima).length;
  const totalValue = products.reduce((sum, p) => sum + (p.preco_venda * p.quantidade_atual), 0);

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-2">
            <Package className="w-8 h-8" />
            Produtos
          </h2>
          <p className="text-gray-600">Gerencie seus produtos e estoque</p>
        </div>
        {hasActionAccess('criar') && (
          <Button 
            onClick={handleCreateProduct}
            className="bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white"
          >
            <Plus className="w-4 h-4 mr-2" />
            Novo Produto
          </Button>
        )}
      </div>

      {/* Search and Filters */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <Input
                placeholder="Buscar produtos por nome ou categoria..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            <div className="flex gap-2 flex-wrap">
              <select
                value={categoryFilter}
                onChange={(e) => setCategoryFilter(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-md text-sm"
              >
                <option value="">Todas as categorias</option>
                {categories.map(category => (
                  <option key={category} value={category}>{category}</option>
                ))}
              </select>
              <select
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-md text-sm"
              >
                <option value="">Todos os tipos</option>
                {productTypes.map(type => (
                  <option key={type.value} value={type.value}>{type.label}</option>
                ))}
              </select>
              <Button
                variant={showLowStock ? "default" : "outline"}
                onClick={() => setShowLowStock(!showLowStock)}
                size="sm"
              >
                <Filter className="w-4 h-4 mr-1" />
                Estoque Baixo
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Products Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {loading ? (
          <div>Carregando produtos...</div>
        ) : error ? (
          <div>Erro ao carregar produtos: {error}</div>
        ) : (
          filteredProducts.map((product) => (
            <Card key={product.id} className="hover:shadow-lg transition-all duration-200 border-0 shadow-md hover:scale-105">
              <CardContent className="p-4">
                <div className="aspect-square relative mb-4 rounded-lg overflow-hidden bg-gray-100">
                  <Badge className={`absolute top-2 left-2 ${getProductTypeInfo(product.tipo_produto).color} text-white text-xs`}>
                    {getProductTypeInfo(product.tipo_produto).label}
                  </Badge>
                  {product.quantidade_atual <= product.quantidade_minima && (
                    <Badge className="absolute top-2 right-2 bg-red-500 text-white">
                      Estoque Baixo
                    </Badge>
                  )}
                  {product.imagem_url ? (
                    <img
                      src={getImageUrl(product.imagem_url)}
                      alt={product.nome}
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        console.error('❌ Erro ao carregar imagem:', {
                          produto: product.nome,
                          imagem_url: product.imagem_url,
                          src: getImageUrl(product.imagem_url),
                          error: e
                        });
                      }}
                      onLoad={() => {
                        // Imagem carregada com sucesso
                      }}
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <Package className="w-12 h-12 text-gray-300" />
                    </div>
                  )}
                </div>
                
                <div className="space-y-2">
                  <div>
                    <h3 className="font-semibold text-gray-800 text-sm">{product.nome}</h3>
                    <p className="text-xs text-gray-600">{product.categoria}</p>
                    {product.descricao && (
                      <p className="text-xs text-gray-500 mt-1 line-clamp-2">{product.descricao}</p>
                    )}
                  </div>
                  
                  <div className="flex justify-between items-center">
                    <div>
                      <p className="text-lg font-bold text-green-600">{formatCurrency(product.preco_venda)}</p>
                      <p className="text-xs text-gray-500">Custo: {formatCurrency(product.preco_custo)}</p>
                    </div>
                    <div className="text-right">
                      <div className="space-y-1">
                        <p className="text-sm font-semibold text-gray-800">
                          Total: {product.quantidade_atual} {product.unidade_medida}
                        </p>
                        <div className="text-xs text-gray-500 space-y-0.5">
                          <p>Pronta: {product.quantidade_pronta_entrega || 0}</p>
                          <p>Encomenda: {product.quantidade_encomenda || 0}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex gap-2 pt-2">
                    {hasActionAccess('editar') && (
                      <Button 
                        size="sm" 
                        variant="outline" 
                        className="flex-1"
                        onClick={() => handleEditProduct(product)}
                      >
                        <Edit className="w-3 h-3 mr-1" />
                        Editar
                      </Button>
                    )}
                    {hasActionAccess('excluir') && (
                      <Button 
                        size="sm" 
                        variant="outline" 
                        className="text-red-600 hover:text-red-700 hover:bg-red-50"
                        onClick={() => handleDeleteProduct(product)}
                      >
                        <Trash2 className="w-3 h-3" />
                      </Button>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>

      {filteredProducts.length === 0 && (
        <div className="text-center py-12">
          <Package className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-600 mb-2">Nenhum produto encontrado</h3>
          <p className="text-gray-500 mb-4">
            {searchTerm || categoryFilter || typeFilter || showLowStock 
              ? 'Tente ajustar os filtros ou buscar por outros termos.'
              : 'Comece adicionando alguns produtos ao seu estoque.'
            }
          </p>
          {!searchTerm && !categoryFilter && !typeFilter && !showLowStock && hasActionAccess('criar') && (
            <Button onClick={handleCreateProduct}>
              <Plus className="w-4 h-4 mr-2" />
              Adicionar Primeiro Produto
            </Button>
          )}
        </div>
      )}

      {/* Stats Summary */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-gray-800">{totalProducts}</p>
            <p className="text-sm text-gray-600">Total de Produtos</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-orange-600">{lowStockProducts}</p>
            <p className="text-sm text-gray-600">Estoque Baixo</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-green-600">{formatCurrency(totalValue)}</p>
            <p className="text-sm text-gray-600">Valor Total em Estoque</p>
          </CardContent>
        </Card>
      </div>

      {/* Modals */}
      <ProductFormModal
        isOpen={isFormModalOpen}
        onClose={() => setIsFormModalOpen(false)}
        onSubmit={handleFormSubmit}
        product={editingProduct}
      />

      <DeleteConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={handleConfirmDelete}
        itemName={deletingProduct?.nome || ""}
      />
    </div>
  );
}
