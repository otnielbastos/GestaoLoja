import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Order } from "@/hooks/useOrders";
import { Customer } from "@/hooks/useCustomers";
import { CustomerSelect } from "@/components/CustomerSelect";
import { OrderItems } from "@/components/OrderItems";
import { useToast } from "@/hooks/use-toast";

interface OrderFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (order: Omit<Order, 'id'>) => void;
  order?: Order;
}

const paymentMethods = [
  "Dinheiro",
  "Cartão de Crédito",
  "Cartão de Débito",
  "PIX",
  "Boleto"
];

// Status específicos para cada tipo de pedido
const getStatusOptions = (tipo: "pronta_entrega" | "encomenda") => {
  if (tipo === "encomenda") {
    return [
      { value: "pendente", label: "📝 Pendente", description: "Aguardando confirmação" },
      { value: "aprovado", label: "👍 Aprovado", description: "Pedido confirmado" },
      { value: "aguardando_producao", label: "⏳ Aguardando Produção", description: "Na fila de produção" },
      { value: "em_preparo", label: "👨‍🍳 Em Preparo", description: "Sendo produzido" },
      { value: "produzido", label: "✨ Produzido", description: "Produção finalizada" },
      { value: "pronto", label: "🍽️ Pronto", description: "Pronto para entrega" },
      { value: "em_entrega", label: "🚚 Em Entrega", description: "Saiu para entrega" },
      { value: "entregue", label: "✅ Entregue", description: "Entregue ao cliente" },
      { value: "concluido", label: "🎉 Concluído", description: "Pedido finalizado" },
      { value: "cancelado", label: "❌ Cancelado", description: "Pedido cancelado" }
    ];
  } else {
    // Status para pronta_entrega
    return [
      { value: "pendente", label: "📝 Pendente", description: "Aguardando confirmação" },
      { value: "aprovado", label: "👍 Aprovado", description: "Pedido confirmado" },
      { value: "em_separacao", label: "📦 Em Separação", description: "Separando produtos" },
      { value: "pronto", label: "🍽️ Pronto", description: "Pronto para entrega" },
      { value: "em_entrega", label: "🚚 Em Entrega", description: "Saiu para entrega" },
      { value: "entregue", label: "✅ Entregue", description: "Entregue ao cliente" },
      { value: "concluido", label: "🎉 Concluído", description: "Pedido finalizado" },
      { value: "cancelado", label: "❌ Cancelado", description: "Pedido cancelado" }
    ];
  }
};

const orderTypes = [
  { value: "pronta_entrega", label: "Pronta Entrega", description: "Produto já está em estoque" },
  { value: "encomenda", label: "Encomenda", description: "Produto será produzido sob demanda" }
];

export function OrderFormModal({ isOpen, onClose, onSubmit, order }: OrderFormModalProps) {
  const [formData, setFormData] = useState({
    customerId: 0,
    customerName: "",
    customerPhone: "",
    status: "pendente" as Order['status'],
    tipo: "pronta_entrega" as "pronta_entrega" | "encomenda",
    time: "",
    date: "",
    data_entrega_prevista: "",
    horario_entrega: "",
    items: [] as any[],
    paymentMethod: "",
    address: "",
    notes: "",
    observacoes_producao: "",
  });

  const { toast } = useToast();

  useEffect(() => {
    if (order) {
      setFormData({
        customerId: order.customerId,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        status: order.status,
        tipo: order.tipo || "pronta_entrega",
        time: order.time,
        date: order.date,
        data_entrega_prevista: order.data_entrega_prevista || "",
        horario_entrega: order.horario_entrega || "",
        items: order.items || [],
        paymentMethod: order.paymentMethod,
        address: order.address || "",
        notes: order.notes || "",
        observacoes_producao: order.observacoes_producao || "",
      });
    } else {
      const now = new Date();
      setFormData({
        customerId: 0,
        customerName: "",
        customerPhone: "",
        status: "pendente",
        tipo: "pronta_entrega",
        time: now.toTimeString().slice(0, 5),
        date: now.toISOString().split('T')[0],
        data_entrega_prevista: "",
        horario_entrega: "",
        items: [],
        paymentMethod: "",
        address: "",
        notes: "",
        observacoes_producao: "",
      });
    }
  }, [order, isOpen]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.customerId) {
      toast({
        title: "Cliente não selecionado",
        description: "Por favor, selecione um cliente para o pedido.",
        variant: "destructive",
      });
      return;
    }

    if (formData.items.length === 0) {
      toast({
        title: "Nenhum item adicionado",
        description: "Por favor, adicione pelo menos um item ao pedido.",
        variant: "destructive",
      });
      return;
    }

    if (!formData.paymentMethod) {
      toast({
        title: "Método de pagamento",
        description: "Por favor, selecione um método de pagamento.",
        variant: "destructive",
      });
      return;
    }

    // Validação específica para encomendas
    if (formData.tipo === "encomenda" && !formData.data_entrega_prevista) {
      toast({
        title: "Data de entrega obrigatória",
        description: "Para encomendas, é obrigatório informar a data de entrega prevista.",
        variant: "destructive",
      });
      return;
    }

    const total = formData.items.reduce((sum: number, item: any) => sum + item.total, 0);

    const orderData: Omit<Order, 'id'> = {
      customerId: formData.customerId,
      customerName: formData.customerName,
      customerPhone: formData.customerPhone,
      total: total,
      status: formData.status,
      tipo: formData.tipo,
      time: formData.time,
      date: formData.date,
      data_entrega_prevista: formData.data_entrega_prevista || null,
      horario_entrega: formData.horario_entrega || null,
      items: formData.items,
      paymentMethod: formData.paymentMethod,
      address: formData.address,
      notes: formData.notes,
      observacoes_producao: formData.observacoes_producao,
    };

    onSubmit(orderData);
    onClose();
  };

  const handleCustomerSelect = (customerId: number, customer: Customer) => {
    setFormData(prev => ({
      ...prev,
      customerId: customerId,
      customerName: customer.name,
      customerPhone: customer.phone,
      address: customer.address,
    }));
  };

  const handleChange = (field: string, value: string) => {
    setFormData(prev => {
      const newData = {
        ...prev,
        [field]: value
      };
      
      // Se mudou o tipo de pedido, verificar se o status atual é válido para o novo tipo
      if (field === 'tipo') {
        const validStatuses = getStatusOptions(value as "pronta_entrega" | "encomenda").map(s => s.value);
        if (!validStatuses.includes(prev.status)) {
          // Se o status atual não é válido para o novo tipo, resetar para "pendente"
          newData.status = "pendente";
          toast({
            title: "Status ajustado",
            description: `O status foi alterado para "Pendente" pois não é válido para ${value === "encomenda" ? "Encomendas" : "Pronta Entrega"}.`,
          });
        }
      }
      
      return newData;
    });
  };

  const total = formData.items.reduce((sum: number, item: any) => sum + item.total, 0);

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent 
        className="max-w-7xl max-h-[95vh] w-[95vw] overflow-y-auto"
        style={{
          // Melhor suporte a dispositivos móveis
          touchAction: 'pan-y',
          WebkitOverflowScrolling: 'touch'
        }}
      >
        <DialogHeader>
          <DialogTitle>
            {order ? 'Editar Pedido' : 'Novo Pedido'}
          </DialogTitle>
          <DialogDescription>
            {order ? 'Edite as informações do pedido abaixo.' : 'Preencha as informações para criar um novo pedido.'}
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Seção Superior: Informações do Pedido */}
          <div className="space-y-6">
            <div className="flex items-center gap-3 pb-4 border-b-2 border-blue-500">
              <div className="p-2 bg-blue-100 rounded-lg">
                <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-800">Informações do Pedido</h3>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {/* Cliente - Ocupa 2 colunas em telas grandes */}
              <div className="sm:col-span-2 lg:col-span-1">
                <CustomerSelect
                  value={formData.customerId || undefined}
                  onValueChange={handleCustomerSelect}
                />
              </div>

              {/* Tipo de Pedido - Ocupa 2 colunas em telas grandes */}
              <div className="sm:col-span-2 lg:col-span-2">
                <Label className="text-base font-medium flex items-center gap-2 mb-2">
                  <span>Tipo de Pedido *</span>
                </Label>
                <RadioGroup 
                  value={formData.tipo} 
                  onValueChange={(value) => handleChange('tipo', value)}
                  className="grid grid-cols-1 sm:grid-cols-2 gap-3"
                >
                  {orderTypes.map((type) => (
                    <div 
                      key={type.value} 
                      className={`flex items-start space-x-3 p-4 border-2 rounded-xl transition-all duration-200 cursor-pointer ${
                        formData.tipo === type.value 
                          ? 'border-blue-500 bg-blue-50 shadow-sm' 
                          : 'border-gray-200 hover:border-gray-300 hover:shadow-sm'
                      }`}
                    >
                      <RadioGroupItem value={type.value} id={type.value} className="mt-1" />
                      <div className="flex-1 min-w-0">
                        <Label htmlFor={type.value} className="font-semibold cursor-pointer text-sm">
                          {type.label}
                        </Label>
                        <p className="text-xs text-muted-foreground mt-1">
                          {type.description}
                        </p>
                      </div>
                    </div>
                  ))}
                </RadioGroup>
              </div>

              {/* Data e Horário do Pedido */}
              <div>
                <Label htmlFor="date">Data do Pedido *</Label>
                <Input
                  id="date"
                  type="date"
                  value={formData.date}
                  onChange={(e) => handleChange('date', e.target.value)}
                  required
                />
              </div>
              <div>
                <Label htmlFor="time">Horário do Pedido *</Label>
                <Input
                  id="time"
                  type="time"
                  value={formData.time}
                  onChange={(e) => handleChange('time', e.target.value)}
                  required
                />
              </div>

              {/* Status e Pagamento */}
              <div>
                <Label htmlFor="status">Status *</Label>
                <Select value={formData.status} onValueChange={(value) => handleChange('status', value)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {getStatusOptions(formData.tipo).map(status => (
                      <SelectItem key={status.value} value={status.value}>
                        {status.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="paymentMethod">Forma de Pagamento *</Label>
                <Select value={formData.paymentMethod} onValueChange={(value) => handleChange('paymentMethod', value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione..." />
                  </SelectTrigger>
                  <SelectContent>
                    {paymentMethods.map(method => (
                      <SelectItem key={method} value={method}>
                        {method}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Campos de Entrega - Obrigatórios para encomendas */}
              {formData.tipo === "encomenda" && (
                <div className="sm:col-span-2 lg:col-span-3 p-5 bg-gradient-to-br from-blue-50 to-indigo-50 border-2 border-blue-200 rounded-xl shadow-sm">
                  <div className="flex items-center gap-2 mb-4">
                    <div className="p-1.5 bg-blue-500 rounded-lg">
                      <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                    <h4 className="font-semibold text-blue-900">Detalhes da Encomenda</h4>
                  </div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    <div>
                      <Label htmlFor="data_entrega_prevista">Data de Entrega Prevista *</Label>
                      <Input
                        id="data_entrega_prevista"
                        type="date"
                        value={formData.data_entrega_prevista}
                        onChange={(e) => handleChange('data_entrega_prevista', e.target.value)}
                        min={formData.date}
                        required
                      />
                    </div>
                    <div>
                      <Label htmlFor="horario_entrega">Horário de Entrega</Label>
                      <Input
                        id="horario_entrega"
                        type="time"
                        value={formData.horario_entrega}
                        onChange={(e) => handleChange('horario_entrega', e.target.value)}
                      />
                    </div>
                    <div className="sm:col-span-2">
                      <Label htmlFor="observacoes_producao">Observações para Produção</Label>
                      <Textarea
                        id="observacoes_producao"
                        value={formData.observacoes_producao}
                        onChange={(e) => handleChange('observacoes_producao', e.target.value)}
                        placeholder="Instruções específicas para a produção..."
                        rows={2}
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* Endereço de Entrega */}
              <div className="sm:col-span-2 lg:col-span-3">
                <Label htmlFor="address">Endereço de Entrega</Label>
                <Textarea
                  id="address"
                  value={formData.address}
                  onChange={(e) => handleChange('address', e.target.value)}
                  placeholder="Endereço completo para entrega..."
                  rows={2}
                />
              </div>

              {/* Observações Gerais - Ocupa toda a largura */}
              <div className="sm:col-span-2 lg:col-span-3">
                <Label htmlFor="notes">Observações Gerais</Label>
                <Textarea
                  id="notes"
                  value={formData.notes}
                  onChange={(e) => handleChange('notes', e.target.value)}
                  placeholder="Observações adicionais..."
                  rows={2}
                />
              </div>
            </div>
          </div>

          {/* Seção Inferior: Itens do Pedido */}
          <div className="space-y-6">
            <div className="flex items-center gap-3 pb-4 border-b-2 border-green-500">
              <div className="p-2 bg-green-100 rounded-lg">
                <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <div className="flex-1">
                <h3 className="text-xl font-bold text-gray-800">Itens do Pedido</h3>
                <p className="text-xs text-gray-500 mt-0.5">Adicione os produtos ao pedido</p>
              </div>
              {formData.items.length > 0 && (
                <div className="px-3 py-1.5 bg-green-100 text-green-700 rounded-full text-sm font-semibold">
                  {formData.items.length} {formData.items.length === 1 ? 'item' : 'itens'}
                </div>
              )}
            </div>
            
            <OrderItems
              items={formData.items}
              onItemsChange={(items) => setFormData(prev => ({ ...prev, items }))}
              tipoPedido={formData.tipo}
            />
            
            <div className="bg-gradient-to-br from-gray-50 to-gray-100 p-5 rounded-xl border-2 border-gray-200 shadow-sm">
              <div className="flex justify-between items-center">
                <div className="flex items-center gap-2">
                  <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span className="text-lg font-bold text-gray-800">Total do Pedido:</span>
                </div>
                <span className="text-2xl font-bold text-green-600">R$ {total.toFixed(2)}</span>
              </div>
              {formData.tipo === "encomenda" && (
                <div className="mt-3 pt-3 border-t border-gray-300 flex items-start gap-2">
                  <svg className="w-5 h-5 text-blue-500 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                  </svg>
                  <p className="text-sm text-blue-700">
                    <span className="font-semibold">Encomenda:</span> Os produtos serão produzidos após aprovação do pedido.
                  </p>
                </div>
              )}
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-6 border-t">
            <Button 
              type="button" 
              variant="outline" 
              onClick={onClose}
              className="px-6"
            >
              Cancelar
            </Button>
            <Button 
              type="submit"
              className="px-6 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              {order ? 'Atualizar' : 'Criar'} Pedido
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
