import { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Users, Plus, Search, Edit, Trash2, MapPin, Phone } from "lucide-react";
import { useCustomers } from "@/hooks/useCustomers";
import { CustomerFormModal } from "@/components/CustomerFormModal";
import { DeleteConfirmModal } from "@/components/DeleteConfirmModal";
import { useToast } from "@/hooks/use-toast";

export function Customers() {
  const [searchTerm, setSearchTerm] = useState("");
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [editingCustomer, setEditingCustomer] = useState<number | null>(null);
  const [deletingCustomer, setDeletingCustomer] = useState<number | null>(null);
  const [statistics, setStatistics] = useState<any>(null);
  
  const { customers, loading, error, addCustomer, updateCustomer, deleteCustomer, getCustomer, getStatistics } = useCustomers();
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

  const handleEdit = (id: number) => {
    setEditingCustomer(id);
    setIsFormOpen(true);
  };

  const handleDelete = (id: number) => {
    setDeletingCustomer(id);
    setIsDeleteOpen(true);
  };

  const handleFormSubmit = async (customerData: any) => {
    try {
      if (editingCustomer) {
        await updateCustomer(editingCustomer, customerData);
        toast({
          title: "Cliente atualizado",
          description: "O cliente foi atualizado com sucesso.",
        });
      } else {
        await addCustomer(customerData);
        toast({
          title: "Cliente criado",
          description: "O cliente foi cadastrado com sucesso.",
        });
      }
      setEditingCustomer(null);
      loadStatistics(); // Recarregar estatísticas
    } catch (error: any) {
      toast({
        title: "Erro",
        description: error.message || "Ocorreu um erro ao salvar o cliente.",
        variant: "destructive",
      });
    }
  };

  const handleDeleteConfirm = async () => {
    if (deletingCustomer) {
      try {
        await deleteCustomer(deletingCustomer);
        toast({
          title: "Cliente excluído",
          description: "O cliente foi excluído com sucesso.",
          variant: "destructive",
        });
        setDeletingCustomer(null);
        loadStatistics(); // Recarregar estatísticas
      } catch (error: any) {
        toast({
          title: "Erro",
          description: error.response?.data?.message || "Ocorreu um erro ao excluir o cliente.",
          variant: "destructive",
        });
      }
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "VIP": return "bg-purple-100 text-purple-800 border-purple-200";
      case "Ativo": return "bg-green-100 text-green-800 border-green-200";
      case "Novo": return "bg-blue-100 text-blue-800 border-blue-200";
      case "Inativo": return "bg-gray-100 text-gray-800 border-gray-200";
      default: return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const filteredCustomers = customers.filter(customer =>
    customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    customer.phone.includes(searchTerm) ||
    customer.neighborhood.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="text-center py-12">
          <p>Carregando clientes...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-2">
            <Users className="w-8 h-8" />
            Clientes
          </h2>
          <p className="text-gray-600">Gerencie sua base de clientes</p>
        </div>
        <Button onClick={() => setIsFormOpen(true)} className="bg-gradient-to-r from-purple-500 to-pink-600 hover:from-purple-600 hover:to-pink-700 text-white">
          <Plus className="w-4 h-4 mr-2" />
          Novo Cliente
        </Button>
      </div>

      {/* Search and Filters */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <Input
                placeholder="Buscar por nome, telefone ou bairro..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            <div className="flex gap-2">
              <Button variant="outline">Todos</Button>
              <Button variant="outline">VIP</Button>
              <Button variant="outline">Ativos</Button>
              <Button variant="outline">Novos</Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Customers Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {filteredCustomers.length === 0 ? (
          <div className="lg:col-span-2 text-center py-8">
            <p className="text-gray-500">Nenhum cliente encontrado</p>
          </div>
        ) : (
          filteredCustomers.map((customer) => (
            <Card key={customer.id} className="hover:shadow-lg transition-shadow duration-200 border-0 shadow-md">
              <CardContent className="p-6">
                <div className="flex flex-col gap-4">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <h3 className="text-lg font-semibold text-gray-800">{customer.name}</h3>
                        <Badge className={`${getStatusColor(customer.customerStatus)}`}>
                          {customer.customerStatus}
                        </Badge>
                      </div>
                      
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-gray-600">
                        <div className="flex items-center gap-2">
                          <Phone className="w-4 h-4" />
                          <span>{customer.phone}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <MapPin className="w-4 h-4" />
                          <span>{customer.neighborhood}</span>
                        </div>
                        {customer.email && (
                          <div className="sm:col-span-2">
                            <p><strong>E-mail:</strong> {customer.email}</p>
                          </div>
                        )}
                        <div className="sm:col-span-2">
                          <p><strong>Endereço:</strong> {customer.address}</p>
                        </div>
                        {customer.notes && (
                          <div className="sm:col-span-2">
                            <p><strong>Observações:</strong> {customer.notes}</p>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
                    <div className="grid grid-cols-3 gap-4 text-center">
                      <div>
                        <p className="text-lg font-bold text-blue-600">{customer.orders}</p>
                        <p className="text-xs text-gray-500">Pedidos</p>
                      </div>
                      <div>
                        <p className="text-lg font-bold text-green-600">R$ {Number(customer.totalSpent || 0).toFixed(2)}</p>
                        <p className="text-xs text-gray-500">Total Gasto</p>
                      </div>
                      <div>
                        <p className="text-sm font-semibold text-gray-800">{customer.lastOrder || 'Nunca'}</p>
                        <p className="text-xs text-gray-500">Último Pedido</p>
                      </div>
                    </div>
                    
                    <div className="flex gap-2">
                      <Button size="sm" variant="outline" onClick={() => handleEdit(customer.id)}>
                        <Edit className="w-4 h-4 mr-1" />
                        Editar
                      </Button>
                      <Button size="sm" variant="outline" onClick={() => handleDelete(customer.id)}>
                        <Trash2 className="w-4 h-4 mr-1" />
                        Excluir
                      </Button>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-gray-800">{statistics?.resumo?.total_clientes || customers.length}</p>
            <p className="text-sm text-gray-600">Total de Clientes</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-purple-600">{customers.filter(c => c.customerStatus === "VIP").length}</p>
            <p className="text-sm text-gray-600">Clientes VIP</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-blue-600">{statistics?.resumo?.novos_ultimo_mes || customers.filter(c => c.customerStatus === "Novo").length}</p>
            <p className="text-sm text-gray-600">Novos este Mês</p>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-md">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-green-600">
              R$ {(() => {
                const ticketMedio = statistics?.resumo?.ticket_medio;
                if (ticketMedio && !isNaN(parseFloat(ticketMedio))) {
                  return parseFloat(ticketMedio).toFixed(2);
                }
                
                if (customers.length > 0) {
                  const total = customers.reduce((sum, c) => {
                    const spent = Number(c.totalSpent) || 0;
                    return sum + spent;
                  }, 0);
                  const average = total / customers.length;
                  return isNaN(average) ? '0.00' : average.toFixed(2);
                }
                
                return '0.00';
              })()}
            </p>
            <p className="text-sm text-gray-600">Ticket Médio</p>
          </CardContent>
        </Card>
      </div>

      {/* Modals */}
      <CustomerFormModal
        isOpen={isFormOpen}
        onClose={() => {
          setIsFormOpen(false);
          setEditingCustomer(null);
        }}
        onSubmit={handleFormSubmit}
        customer={editingCustomer ? customers.find(c => c.id === editingCustomer) : undefined}
      />

      <DeleteConfirmModal
        isOpen={isDeleteOpen}
        onClose={() => {
          setIsDeleteOpen(false);
          setDeletingCustomer(null);
        }}
        onConfirm={handleDeleteConfirm}
        itemName={deletingCustomer ? customers.find(c => c.id === deletingCustomer)?.name || '' : ''}
      />
    </div>
  );
}
