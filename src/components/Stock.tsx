import { useState, useEffect } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Warehouse, Plus, Search, TrendingUp, TrendingDown, AlertTriangle, Edit, Trash2 } from "lucide-react";
import { useStockMovements } from "@/hooks/useStockMovements";
import { StockMovementFormModal } from "@/components/StockMovementFormModal";
import { DeleteConfirmModal } from "@/components/DeleteConfirmModal";
import { useToast } from "@/hooks/use-toast";

export function Stock() {
  const [searchTerm, setSearchTerm] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [editingMovement, setEditingMovement] = useState<number | null>(null);
  const [deletingMovement, setDeletingMovement] = useState<number | null>(null);
  const [lowStockProducts, setLowStockProducts] = useState<any[]>([]);
  const [stockReport, setStockReport] = useState<any>(null);
  
  const { movements, loading, error, addMovement, updateMovement, deleteMovement, getMovement, getLowStockProducts, getStockReport } = useStockMovements();
  const { toast } = useToast();

  // Carregar dados adicionais
  useEffect(() => {
    loadLowStockProducts();
    loadStockReport();
  }, []);

  const loadLowStockProducts = async () => {
    try {
      const products = await getLowStockProducts();
      setLowStockProducts(products || []);
    } catch (error) {
      console.error('❌ Erro ao carregar produtos com estoque baixo:', error);
      setLowStockProducts([]);
    }
  };

  const loadStockReport = async () => {
    try {
      const report = await getStockReport();
      setStockReport(report);
    } catch (error) {
      console.error('❌ Erro ao carregar relatório de estoque:', error);
      setStockReport(null);
    }
  };

  const handleEdit = async (id: number) => {
    setEditingMovement(id);
    setIsFormOpen(true);
  };

  const handleDelete = (id: number) => {
    setDeletingMovement(id);
    setIsDeleteOpen(true);
  };

  const handleFormSubmit = async (movementData: any) => {
    try {
      if (editingMovement) {
        await updateMovement(editingMovement, movementData);
        toast({
          title: "Movimentação atualizada",
          description: "A movimentação foi atualizada com sucesso.",
        });
      } else {
        await addMovement(movementData);
        toast({
          title: "Movimentação criada",
          description: "A movimentação foi registrada com sucesso.",
        });
      }
      setEditingMovement(null);
      // Recarregar dados
      loadLowStockProducts();
      loadStockReport();
    } catch (error: any) {
      toast({
        title: "Erro",
        description: error.response?.data?.message || "Ocorreu um erro ao salvar a movimentação.",
        variant: "destructive",
      });
    }
  };

  const handleDeleteConfirm = async () => {
    if (deletingMovement) {
      try {
        await deleteMovement(deletingMovement);
        toast({
          title: "Movimentação excluída",
          description: "A movimentação foi excluída com sucesso.",
          variant: "destructive",
        });
        setDeletingMovement(null);
        // Recarregar dados
        loadLowStockProducts();
        loadStockReport();
      } catch (error: any) {
        toast({
          title: "Erro",
          description: error.response?.data?.message || "Ocorreu um erro ao excluir a movimentação.",
          variant: "destructive",
        });
      }
    }
  };

  const getMovementIcon = (type: string) => {
    return type === "entrada" ? (
      <TrendingUp className="w-4 h-4 text-green-600" />
    ) : type === "saida" ? (
      <TrendingDown className="w-4 h-4 text-red-600" />
    ) : (
      <AlertTriangle className="w-4 h-4 text-blue-600" />
    );
  };

  const getMovementColor = (type: string) => {
    switch (type) {
      case "entrada":
        return "bg-green-100 text-green-800 border-green-200";
      case "saida":
        return "bg-red-100 text-red-800 border-red-200";
      case "ajuste":
        return "bg-blue-100 text-blue-800 border-blue-200";
      default:
        return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const getMovementTypeLabel = (type: string) => {
    switch (type) {
      case "entrada": return "Entrada";
      case "saida": return "Saída";
      case "ajuste": return "Ajuste";
      default: return type;
    }
  };

  const filteredMovements = movements.filter(movement => {
    const matchesSearch = movement.produto_nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         movement.motivo.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesType = !typeFilter || movement.tipo_movimento === typeFilter;
    
    return matchesSearch && matchesType;
  });

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR');
  };

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
  };

  const formatCurrency = (value: number | string) => {
    const numValue = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(numValue)) return 'R$ 0,00';
    
    return numValue.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  };

  if (loading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="text-center py-12">
          <Warehouse className="w-12 h-12 mx-auto text-gray-400 mb-4" />
          <p className="text-gray-600">Carregando dados do estoque...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="text-center py-12">
          <AlertTriangle className="w-12 h-12 mx-auto text-red-400 mb-4" />
          <h3 className="text-lg font-semibold text-gray-800 mb-2">Erro ao carregar estoque</h3>
          <p className="text-red-600 mb-4">{error}</p>
          <Button onClick={() => window.location.reload()} variant="outline">
            Tentar novamente
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-2">
            <Warehouse className="w-8 h-8" />
            Controle de Estoque
          </h2>
          <p className="text-gray-600">Monitore movimentações e níveis de estoque</p>
        </div>
        <Button onClick={() => setIsFormOpen(true)} className="bg-gradient-to-r from-orange-500 to-red-600 hover:from-orange-600 hover:to-red-700 text-white">
          <Plus className="w-4 h-4 mr-2" />
          Nova Movimentação
        </Button>
      </div>

      {/* Low Stock Alert */}
      {lowStockProducts.length > 0 && (
        <Card className="border-0 shadow-md bg-orange-50 border-orange-200">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-orange-800">
              <AlertTriangle className="w-5 h-5" />
              Alerta de Estoque Baixo
            </CardTitle>
            <CardDescription className="text-orange-700">
              Os seguintes produtos estão com estoque abaixo do mínimo
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {lowStockProducts.map((product, index) => (
                <div key={index} className="flex justify-between items-center p-3 bg-white rounded-lg border border-orange-200">
                  <div>
                    <p className="font-medium text-gray-800">{product.nome}</p>
                    <p className="text-sm text-gray-600">{product.categoria}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-lg font-bold text-orange-600">{product.quantidade_atual}</p>
                    <p className="text-xs text-gray-500">Min: {product.quantidade_minima}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Search and Filters */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <Input
                placeholder="Buscar por produto ou motivo..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            <div className="flex gap-2">
              <select
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-md text-sm"
              >
                <option value="">Todos os tipos</option>
                <option value="entrada">Entradas</option>
                <option value="saida">Saídas</option>
                <option value="ajuste">Ajustes</option>
              </select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Stock Movements */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle>Movimentações Recentes</CardTitle>
          <CardDescription>Histórico de entradas e saídas de produtos</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {filteredMovements.length === 0 ? (
              <div className="text-center py-8">
                <p className="text-gray-500">Nenhuma movimentação encontrada</p>
              </div>
            ) : (
              filteredMovements.map((movement) => (
                <div key={movement.id} className="flex flex-col lg:flex-row lg:items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                  <div className="flex items-start gap-4">
                    <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-red-600 rounded-full flex items-center justify-center text-white font-bold">
                      {getMovementIcon(movement.tipo_movimento)}
                    </div>
                    <div className="flex-1">
                      <div className="flex flex-col sm:flex-row sm:items-center gap-2 mb-2">
                        <h3 className="font-semibold text-gray-800">{movement.produto_nome}</h3>
                        <Badge className={`w-fit ${getMovementColor(movement.tipo_movimento)}`}>
                          {getMovementTypeLabel(movement.tipo_movimento)}
                        </Badge>
                      </div>
                      <div className="text-sm text-gray-600 space-y-1">
                        <p><strong>Motivo:</strong> {movement.motivo}</p>
                        <p><strong>Data/Hora:</strong> {formatDate(movement.data_movimentacao)} às {formatTime(movement.data_movimentacao)}</p>
                        {movement.valor && <p><strong>Valor:</strong> {formatCurrency(movement.valor)}</p>}
                        {movement.documento_referencia && <p><strong>Doc:</strong> {movement.documento_referencia}</p>}
                        {movement.data_fabricacao && <p><strong>Fabricação:</strong> {formatDate(movement.data_fabricacao)}</p>}
                        {movement.data_validade && <p><strong>Validade:</strong> {formatDate(movement.data_validade)}</p>}
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4 mt-4 lg:mt-0">
                    <div className="grid grid-cols-1 gap-4 text-center">
                      <div>
                        <p className={`text-lg font-bold ${movement.tipo_movimento === "entrada" ? "text-green-600" : movement.tipo_movimento === "saida" ? "text-red-600" : "text-blue-600"}`}>
                          {movement.tipo_movimento === "entrada" ? "+" : movement.tipo_movimento === "saida" ? "-" : "="}{movement.quantidade}
                        </p>
                        <p className="text-xs text-gray-500">Quantidade</p>
                      </div>
                    </div>
                    
                    <div className="flex gap-2">
                      <Button size="sm" variant="outline" onClick={() => handleEdit(movement.id)}>
                        <Edit className="w-4 h-4 mr-1" />
                        Editar
                      </Button>
                      <Button size="sm" variant="outline" onClick={() => handleDelete(movement.id)}>
                        <Trash2 className="w-4 h-4 mr-1" />
                        Excluir
                      </Button>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-green-600">{movements.filter(m => m.tipo_movimento === "entrada").length}</p>
            <p className="text-sm text-gray-600">Entradas Total</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-red-600">{movements.filter(m => m.tipo_movimento === "saida").length}</p>
            <p className="text-sm text-gray-600">Saídas Total</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-orange-600">{lowStockProducts.length}</p>
            <p className="text-sm text-gray-600">Produtos em Falta</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-blue-600">
              {stockReport ? formatCurrency(stockReport.resumo?.valor_total_custo || 0) : "R$ 0,00"}
            </p>
            <p className="text-sm text-gray-600">Valor do Estoque</p>
          </CardContent>
        </Card>
      </div>

      {/* Modals */}
      <StockMovementFormModal
        isOpen={isFormOpen}
        onClose={() => {
          setIsFormOpen(false);
          setEditingMovement(null);
        }}
        onSubmit={handleFormSubmit}
        movement={editingMovement ? movements.find(m => m.id === editingMovement) : undefined}
      />

      <DeleteConfirmModal
        isOpen={isDeleteOpen}
        onClose={() => {
          setIsDeleteOpen(false);
          setDeletingMovement(null);
        }}
        onConfirm={handleDeleteConfirm}
        itemName={deletingMovement ? movements.find(m => m.id === deletingMovement)?.produto_nome || '' : ''}
      />
    </div>
  );
}
