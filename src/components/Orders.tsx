import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ShoppingCart, Plus, Search, Edit, Trash2, Truck, DollarSign, CheckCircle, Filter, X } from "lucide-react";
import { useOrders } from "@/hooks/useOrders";
import { OrderFormModal } from "@/components/OrderFormModal";
import { DeleteConfirmModal } from "@/components/DeleteConfirmModal";
import { PaymentModal } from "@/components/PaymentModal";
import { useToast } from "@/hooks/use-toast";

export function Orders() {
  const [searchTerm, setSearchTerm] = useState("");
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [isPaymentOpen, setIsPaymentOpen] = useState(false);
  const [editingOrder, setEditingOrder] = useState<string | null>(null);
  const [deletingOrder, setDeletingOrder] = useState<string | null>(null);
  const [paymentOrder, setPaymentOrder] = useState<string | null>(null);
  const [statistics, setStatistics] = useState<any>(null);
  const [showFilters, setShowFilters] = useState(false);
  const [filterVersion, setFilterVersion] = useState(0); // Para forçar re-renderização
  
  // Estados dos filtros
  const [filters, setFilters] = useState(() => {
    try {
      const hoje = new Date();
      const seteDiasAtras = new Date(hoje);
      seteDiasAtras.setDate(hoje.getDate() - 7);
      
      const startDate = seteDiasAtras.toISOString().split('T')[0];
      const endDate = hoje.toISOString().split('T')[0]; // Incluir hoje
      
      return {
        startDate,
        endDate,
        status: "",
        tipo: "",
        paymentStatus: ""
      };
    } catch (error) {
      console.error('Erro ao inicializar filtros:', error);
      return {
        startDate: "",
        endDate: "",
        status: "",
        tipo: "",
        paymentStatus: ""
      };
    }
  });
  
  const { 
    orders, 
    loading, 
    error, 
    addOrder, 
    updateOrder, 
    deleteOrder, 
    getOrder, 
    getStatistics,
    updatePayment,
    markAsDelivered,
    searchOrders,
    refreshOrders
  } = useOrders();
  const { toast } = useToast();

  // Carregar estatísticas
  useEffect(() => {
    loadStatistics();
  }, []);

  const loadStatistics = async () => {
    try {
      const stats = await getStatistics();
      setStatistics(stats);
    } catch (error) {
      console.error('Erro ao carregar estatísticas:', error);
    }
  };

  const applyFilters = async () => {
    try {
      await refreshOrders();
      
      toast({
        title: "Filtros aplicados",
        description: "A lista foi atualizada com sucesso.",
      });
    } catch (error) {
      console.error('Erro ao aplicar filtros:', error);
      toast({
        title: "Erro",
        description: "Erro ao aplicar filtros.",
        variant: "destructive",
      });
    }
  };

  const clearFilters = () => {
    try {
      const hoje = new Date();
      const seteDiasAtras = new Date(hoje);
      seteDiasAtras.setDate(hoje.getDate() - 7);
      
      const startDate = seteDiasAtras.toISOString().split('T')[0];
      const endDate = hoje.toISOString().split('T')[0]; // Incluir hoje
      
      setFilters({
        startDate,
        endDate,
        status: "",
        tipo: "",
        paymentStatus: ""
      });
      refreshOrders();
    } catch (error) {
      console.error('Erro ao limpar filtros:', error);
    }
  };

  const handleFilterChange = (field: string, value: string) => {
    try {
      setFilters(prev => ({
        ...prev,
        [field]: value
      }));
      // Forçar re-renderização para aplicar filtros em tempo real
      setFilterVersion(v => v + 1);
    } catch (error) {
      console.error('Erro ao alterar filtro:', error);
    }
  };

  const handleEdit = (id: string) => {
    setEditingOrder(id);
    setIsFormOpen(true);
  };

  const handleDelete = (id: string) => {
    setDeletingOrder(id);
    setIsDeleteOpen(true);
  };

  const handleFormSubmit = async (orderData: any) => {
    try {
      if (editingOrder) {
        await updateOrder(editingOrder, orderData);
        toast({
          title: "Pedido atualizado",
          description: "O pedido foi atualizado com sucesso.",
        });
      } else {
        await addOrder(orderData);
        toast({
          title: "Pedido criado",
          description: "O pedido foi criado com sucesso.",
        });
      }
      setEditingOrder(null);
      loadStatistics(); // Recarregar estatísticas
    } catch (error: any) {
      // Formatar mensagem de erro para melhor exibição
      const errorMessage = error.message || "Ocorreu um erro ao salvar o pedido.";
      const isMultiLine = errorMessage.includes('\n');
      
      toast({
        title: editingOrder ? "Erro ao atualizar pedido" : "Erro ao criar pedido",
        description: (
          <div className={isMultiLine ? "whitespace-pre-line" : ""}>
            {errorMessage}
          </div>
        ),
        variant: "destructive",
        duration: 8000, // Aumentar duração para dar tempo de ler
      });
    }
  };

  const handleDeleteConfirm = async () => {
    if (deletingOrder) {
      try {
        await deleteOrder(deletingOrder);
        toast({
          title: "Pedido cancelado",
          description: "O pedido foi cancelado com sucesso.",
          variant: "destructive",
        });
        setDeletingOrder(null);
        loadStatistics(); // Recarregar estatísticas
      } catch (error: any) {
        toast({
          title: "Erro",
          description: error.message || "Ocorreu um erro ao cancelar o pedido.",
          variant: "destructive",
        });
      }
    }
  };

  const handlePayment = (id: string) => {
    try {
      const order = getOrder(id);
      if (!order) {
        toast({
          title: "Erro",
          description: "Pedido não encontrado. Por favor, recarregue a página.",
          variant: "destructive",
        });
        return;
      }
      setPaymentOrder(id);
      setIsPaymentOpen(true);
    } catch (error: any) {
      console.error('Erro ao abrir modal de pagamento:', error);
      toast({
        title: "Erro",
        description: error.message || "Ocorreu um erro ao abrir o modal de pagamento.",
        variant: "destructive",
      });
    }
  };

  const handlePaymentSubmit = async (paymentData: any) => {
    if (paymentOrder) {
      try {
        await updatePayment(paymentOrder, paymentData);
        toast({
          title: "Pagamento atualizado",
          description: "O status de pagamento foi atualizado com sucesso.",
        });
        setPaymentOrder(null);
        loadStatistics(); // Recarregar estatísticas
      } catch (error: any) {
        toast({
          title: "Erro",
          description: error.message || "Ocorreu um erro ao atualizar o pagamento.",
          variant: "destructive",
        });
      }
    }
  };

  const handleMarkAsDelivered = async (id: string) => {
    try {
      await markAsDelivered(id);
      toast({
        title: "Pedido entregue",
        description: "O pedido foi marcado como entregue com sucesso.",
      });
      loadStatistics(); // Recarregar estatísticas
    } catch (error: any) {
      toast({
        title: "Erro",
        description: error.message || "Ocorreu um erro ao marcar como entregue.",
        variant: "destructive",
      });
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "entregue": 
      case "concluido": return "bg-green-100 text-green-800 border-green-200";
      case "pronto": return "bg-blue-100 text-blue-800 border-blue-200";
      case "em_preparo": 
      case "em_separacao": return "bg-yellow-100 text-yellow-800 border-yellow-200";
      case "produzido": return "bg-purple-100 text-purple-800 border-purple-200";
      case "aguardando_producao": return "bg-orange-100 text-orange-800 border-orange-200";
      case "em_entrega": return "bg-indigo-100 text-indigo-800 border-indigo-200";
      case "aprovado": return "bg-cyan-100 text-cyan-800 border-cyan-200";
      case "pendente": return "bg-gray-100 text-gray-800 border-gray-200";
      case "cancelado": return "bg-red-100 text-red-800 border-red-200";
      default: return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "pronto": return "🍽️";
      case "em_preparo": return "👨‍🍳";
      case "produzido": return "✨";
      case "aguardando_producao": return "⏳";
      case "em_separacao": return "📦";
      case "em_entrega": return "🚚";
      case "entregue": 
      case "concluido": return "✅";
      case "aprovado": return "👍";
      case "pendente": return "📝";
      case "cancelado": return "❌";
      default: return "📦";
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case "pendente": return "Pendente";
      case "aprovado": return "Aprovado";
      case "aguardando_producao": return "Aguardando Produção";
      case "em_preparo": return "Em Preparo";
      case "em_separacao": return "Em Separação";
      case "produzido": return "Produzido";
      case "pronto": return "Pronto";
      case "em_entrega": return "Em Entrega";
      case "entregue": return "Entregue";
      case "concluido": return "Concluído";
      case "cancelado": return "Cancelado";
      default: return status;
    }
  };

  const getTypeColor = (tipo: string) => {
    switch (tipo) {
      case "encomenda": return "bg-blue-100 text-blue-800 border-blue-200";
      case "pronta_entrega": return "bg-green-100 text-green-800 border-green-200";
      default: return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const getTypeLabel = (tipo: string) => {
    switch (tipo) {
      case "encomenda": return "Encomenda";
      case "pronta_entrega": return "Pronta Entrega";
      default: return "Pronta Entrega";
    }
  };

  const getTypeIcon = (tipo: string) => {
    switch (tipo) {
      case "encomenda": return "📅";
      case "pronta_entrega": return "⚡";
      default: return "⚡";
    }
  };

  const getPaymentStatusColor = (status: string) => {
    switch (status) {
      case "pago": return "bg-green-100 text-green-800 border-green-200";
      case "parcial": return "bg-yellow-100 text-yellow-800 border-yellow-200";
      case "pendente": return "bg-red-100 text-red-800 border-red-200";
      default: return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const getPaymentStatusLabel = (status: string) => {
    switch (status) {
      case "pago": return "Pago";
      case "parcial": return "Parcial";
      case "pendente": return "Pendente";
      default: return "Pendente";
    }
  };

  const formatDate = (dateString: string) => {
    if (!dateString) return '';
    
    // Evitar problemas de timezone parseando diretamente
    const [year, month, day] = dateString.split('-');
    const date = new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
    
    return date.toLocaleDateString('pt-BR');
  };

  const formatTime = (timeString: string) => {
    if (!timeString) return '';
    return timeString.substring(0, 5);
  };

  // Aplicar filtros em tempo real (key: filterVersion força re-cálculo)
  const filteredOrders = orders.filter(order => {
    // Filtro de busca por texto
    const matchesSearch = searchTerm === "" || 
      order.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.customerPhone.includes(searchTerm);
    
    if (!matchesSearch) return false;
    
    // Filtro de data
    if (filters.startDate) {
      const orderDate = new Date(order.date);
      const startDate = new Date(filters.startDate);
      if (orderDate < startDate) return false;
    }
    
    if (filters.endDate) {
      const orderDate = new Date(order.date);
      const endDate = new Date(filters.endDate);
      endDate.setHours(23, 59, 59, 999); // Incluir o dia completo
      if (orderDate > endDate) return false;
    }
    
    // Filtro de status
    if (filters.status && filters.status !== "" && filters.status !== "all") {
      if (order.status !== filters.status) return false;
    }
    
    // Filtro de tipo
    if (filters.tipo && filters.tipo !== "" && filters.tipo !== "all") {
      if (order.tipo !== filters.tipo) return false;
    }
    
    // Filtro de status de pagamento
    if (filters.paymentStatus && filters.paymentStatus !== "" && filters.paymentStatus !== "all") {
      if (order.paymentStatus !== filters.paymentStatus) return false;
    }
    
    return true;
  });

  if (loading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="text-center py-12">
          <p>Carregando pedidos...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="text-center py-12">
          <p className="text-red-500">Erro: {error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-2">
            <ShoppingCart className="w-8 h-8" />
            Pedidos
          </h2>
          <p className="text-gray-600">
            Gerencie todos os pedidos da loja
            {filters.startDate && filters.endDate && (
              <span className="ml-2 text-blue-600 font-medium">
                • {formatDate(filters.startDate)} até {formatDate(filters.endDate)}
              </span>
            )}
          </p>
        </div>
        <div className="flex gap-2">
          <Button 
            variant="outline" 
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center gap-2"
          >
            <Filter className="w-4 h-4" />
            Filtros
          </Button>
          <Button onClick={() => setIsFormOpen(true)} className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white">
            <Plus className="w-4 h-4 mr-2" />
            Novo Pedido
          </Button>
        </div>
      </div>

      {/* Seção de Filtros */}
      {showFilters && (
        <Card className="border-blue-200 bg-blue-50">
          <CardHeader className="pb-4">
            <CardTitle className="text-lg flex items-center gap-2">
              <Filter className="w-5 h-5" />
              Filtros Avançados
              <Button 
                variant="ghost" 
                size="sm" 
                onClick={() => setShowFilters(false)}
                className="ml-auto"
              >
                <X className="w-4 h-4" />
              </Button>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
              {/* Data Início */}
              <div>
                <Label htmlFor="startDate">Data Início</Label>
                <Input
                  id="startDate"
                  type="date"
                  value={filters.startDate || ""}
                  onChange={(e) => handleFilterChange('startDate', e.target.value)}
                />
              </div>
              
              {/* Data Fim */}
              <div>
                <Label htmlFor="endDate">Data Fim</Label>
                <Input
                  id="endDate"
                  type="date"
                  value={filters.endDate || ""}
                  onChange={(e) => handleFilterChange('endDate', e.target.value)}
                />
              </div>
              
              {/* Tipo de Pedido */}
              <div>
                <Label htmlFor="filterTipo">Tipo de Pedido</Label>
                <Select value={filters.tipo || "all"} onValueChange={(value) => handleFilterChange('tipo', value === "all" ? "" : value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Todos os tipos" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos os tipos</SelectItem>
                    <SelectItem value="pronta_entrega">⚡ Pronta Entrega</SelectItem>
                    <SelectItem value="encomenda">📅 Encomenda</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              {/* Status */}
              <div>
                <Label htmlFor="filterStatus">Status</Label>
                <Select value={filters.status || "all"} onValueChange={(value) => handleFilterChange('status', value === "all" ? "" : value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Todos os status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos os status</SelectItem>
                    <SelectItem value="pendente">📝 Pendente</SelectItem>
                    <SelectItem value="aprovado">👍 Aprovado</SelectItem>
                    <SelectItem value="aguardando_producao">⏳ Aguardando Produção</SelectItem>
                    <SelectItem value="em_preparo">👨‍🍳 Em Preparo</SelectItem>
                    <SelectItem value="em_separacao">📦 Em Separação</SelectItem>
                    <SelectItem value="produzido">✨ Produzido</SelectItem>
                    <SelectItem value="pronto">🍽️ Pronto</SelectItem>
                    <SelectItem value="em_entrega">🚚 Em Entrega</SelectItem>
                    <SelectItem value="entregue">✅ Entregue</SelectItem>
                    <SelectItem value="concluido">🎉 Concluído</SelectItem>
                    <SelectItem value="cancelado">❌ Cancelado</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              {/* Status Pagamento */}
              <div>
                <Label htmlFor="filterPayment">Status Pagamento</Label>
                <Select value={filters.paymentStatus || "all"} onValueChange={(value) => handleFilterChange('paymentStatus', value === "all" ? "" : value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Todos" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos</SelectItem>
                    <SelectItem value="pendente">🔴 Pendente</SelectItem>
                    <SelectItem value="parcial">🟡 Parcial</SelectItem>
                    <SelectItem value="pago">🟢 Pago</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            
            {/* Botões de Ação */}
            <div className="flex flex-wrap gap-2">
              <Button onClick={applyFilters} className="bg-blue-600 hover:bg-blue-700">
                <Search className="w-4 h-4 mr-2" />
                Aplicar Filtros
              </Button>
              <Button variant="outline" onClick={clearFilters}>
                <X className="w-4 h-4 mr-2" />
                Limpar Filtros
              </Button>
              
              {/* Filtros Rápidos */}
              <div className="flex gap-1 ml-auto">
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={() => {
                    try {
                      const hoje = new Date().toISOString().split('T')[0];
                      setFilters(prev => ({ ...prev, startDate: hoje, endDate: hoje }));
                    } catch (error) {
                      console.error('Erro ao definir filtro hoje:', error);
                    }
                  }}
                >
                  Hoje
                </Button>
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={() => {
                    try {
                      const hoje = new Date().toISOString().split('T')[0];
                      const semanaAtras = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
                      setFilters(prev => ({ ...prev, startDate: semanaAtras, endDate: hoje }));
                    } catch (error) {
                      console.error('Erro ao definir filtro 7 dias:', error);
                    }
                  }}
                >
                  7 dias
                </Button>
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={() => {
                    try {
                      const hoje = new Date().toISOString().split('T')[0];
                      const mesAtras = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
                      setFilters(prev => ({ ...prev, startDate: mesAtras, endDate: hoje }));
                    } catch (error) {
                      console.error('Erro ao definir filtro 30 dias:', error);
                    }
                  }}
                >
                  30 dias
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Informação sobre filtros aplicados */}
      {(filters.status || filters.tipo || filters.paymentStatus) && (
        <Card className="border-blue-200 bg-blue-50">
          <CardContent className="p-4">
            <p className="text-sm text-blue-700">
              <strong>{filteredOrders.length}</strong> {filteredOrders.length === 1 ? 'pedido encontrado' : 'pedidos encontrados'} 
              {' '}de um total de <strong>{orders.length}</strong>
            </p>
          </CardContent>
        </Card>
      )}

      {/* Orders List */}
      <div className="grid gap-4">
        {filteredOrders.length === 0 ? (
          <div className="text-center py-8">
            <p className="text-gray-500">Nenhum pedido encontrado</p>
            {orders.length > 0 && (
              <p className="text-sm text-gray-400 mt-2">
                Tente ajustar os filtros para ver mais resultados
              </p>
            )}
          </div>
        ) : (
          filteredOrders.map((order) => (
            <Card key={order.id} className="hover:shadow-lg transition-shadow duration-200 border-0 shadow-md">
              <CardContent className="p-6">
                <div className="flex flex-col lg:flex-row lg:items-start justify-between gap-4">
                  <div className="flex items-start gap-4 flex-1">
                    <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-bold">
                      {order.id.slice(-2)}
                    </div>
                    <div className="flex-1">
                      <div className="flex flex-col sm:flex-row sm:items-center gap-2 mb-2">
                        <h3 className="font-semibold text-gray-800">{order.customerName}</h3>
                        <Badge className={`w-fit ${getStatusColor(order.status)}`}>
                          {getStatusIcon(order.status)} {getStatusLabel(order.status)}
                        </Badge>
                        <Badge className={`w-fit ${getTypeColor(order.tipo || 'pronta_entrega')}`}>
                          {getTypeIcon(order.tipo || 'pronta_entrega')} {getTypeLabel(order.tipo || 'pronta_entrega')}
                        </Badge>
                        <Badge className={`w-fit ${getPaymentStatusColor(order.paymentStatus || 'pendente')}`}>
                          💰 {getPaymentStatusLabel(order.paymentStatus || 'pendente')}
                        </Badge>
                      </div>
                      <div className="text-sm text-gray-600 space-y-1 mb-3">
                        <p><strong>Telefone:</strong> {order.customerPhone}</p>
                        <p><strong>Data/Hora:</strong> {formatTime(order.time)} - {formatDate(order.date)}</p>
                        
                        {/* Data de entrega prevista para encomendas */}
                        {order.tipo === 'encomenda' && order.data_entrega_prevista && (
                          <p className="text-blue-600">
                            <strong>📅 Entrega Prevista:</strong> {formatDate(order.data_entrega_prevista)}
                            {order.horario_entrega && ` às ${formatTime(order.horario_entrega)}`}
                          </p>
                        )}
                        
                        <p><strong>Pagamento:</strong> {order.paymentMethod}</p>
                        {order.paymentStatus !== 'pendente' && (
                          <p><strong>Valor Pago:</strong> R$ {(order.amountPaid || 0).toFixed(2)}</p>
                        )}
                        {order.address && <p><strong>Endereço:</strong> {order.address}</p>}
                        {order.notes && <p><strong>Observações:</strong> {order.notes}</p>}
                        
                        {/* Observações de produção para encomendas */}
                        {order.tipo === 'encomenda' && order.observacoes_producao && (
                          <p className="text-blue-600">
                            <strong>👨‍🍳 Obs. Produção:</strong> {order.observacoes_producao}
                          </p>
                        )}
                        
                        {order.paymentNotes && <p><strong>Obs. Pagamento:</strong> {order.paymentNotes}</p>}
                      </div>
                      
                      {/* Items List */}
                      <div className="bg-gray-50 rounded-lg p-3">
                        <h4 className="font-medium text-gray-800 mb-2">Itens do Pedido:</h4>
                        <div className="space-y-1">
                          {order.items.map((item, index) => (
                            <div key={index} className="flex justify-between text-sm">
                              <span>{item.quantity}x {item.productName}</span>
                              <span>R$ {item.total.toFixed(2)}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
                    <div className="text-right">
                      <p className="text-2xl font-bold text-green-600">R$ {order.total.toFixed(2)}</p>
                      <p className="text-sm text-gray-500">Valor Total</p>
                    </div>
                    
                    <div className="flex gap-2 flex-wrap">
                      <Button size="sm" variant="outline" onClick={() => handleEdit(order.id)}>
                        <Edit className="w-4 h-4 mr-1" />
                        Editar
                      </Button>
                      
                      <Button 
                        size="sm" 
                        variant="outline" 
                        onClick={() => handlePayment(order.id)}
                        className="border-green-200 text-green-700 hover:bg-green-50"
                      >
                        <DollarSign className="w-4 h-4 mr-1" />
                        Pagamento
                      </Button>
                      
                      {order.status === "pronto" && (
                        <Button 
                          size="sm" 
                          onClick={() => handleMarkAsDelivered(order.id)}
                          className="bg-blue-500 hover:bg-blue-600 text-white"
                        >
                          <Truck className="w-4 h-4 mr-1" />
                          Entregar
                        </Button>
                      )}
                      
                      {order.status !== "entregue" && order.status !== "concluido" && order.status !== "cancelado" && (
                        <Button size="sm" variant="outline" onClick={() => handleDelete(order.id)}>
                          <Trash2 className="w-4 h-4 mr-1" />
                          Cancelar
                        </Button>
                      )}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>

      {/* Modals */}
      {isFormOpen && (
        <OrderFormModal
          isOpen={isFormOpen}
          onClose={() => {
            setIsFormOpen(false);
            setEditingOrder(null);
          }}
          onSubmit={handleFormSubmit}
          order={editingOrder ? getOrder(editingOrder) : undefined}
        />
      )}

      {isDeleteOpen && (
        <DeleteConfirmModal
          isOpen={isDeleteOpen}
          onClose={() => setIsDeleteOpen(false)}
          onConfirm={handleDeleteConfirm}
          itemName={deletingOrder ? orders.find(o => o.id === deletingOrder)?.customerName || 'este pedido' : 'este pedido'}
        />
      )}

      {isPaymentOpen && (
        <PaymentModal
          isOpen={isPaymentOpen}
          onClose={() => {
            setIsPaymentOpen(false);
            setPaymentOrder(null);
          }}
          onSubmit={handlePaymentSubmit}
          order={paymentOrder ? getOrder(paymentOrder) : undefined}
        />
      )}
    </div>
  );
}
