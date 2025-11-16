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
        className="max-w-6xl max-h-[95vh] w-[95vw] overflow-y-auto"
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
        
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 touch-optimized">
            <div className="space-y-4">
              <CustomerSelect
                value={formData.customerId || undefined}
                onValueChange={handleCustomerSelect}
              />

              {/* Tipo de Pedido */}
              <div>
                <Label className="text-base font-medium">Tipo de Pedido *</Label>
                <RadioGroup 
                  value={formData.tipo} 
                  onValueChange={(value) => handleChange('tipo', value)}
                  className="mt-2"
                >
                  {orderTypes.map((type) => (
                    <div key={type.value} className="flex items-start space-x-2 p-3 border rounded-lg">
                      <RadioGroupItem value={type.value} id={type.value} className="mt-1" />
                      <div className="flex-1">
                        <Label htmlFor={type.value} className="font-medium cursor-pointer">
                          {type.label}
                        </Label>
                        <p className="text-sm text-muted-foreground mt-1">
                          {type.description}
                        </p>
                      </div>
                    </div>
                  ))}
                </RadioGroup>
              </div>

              <div className="grid grid-cols-2 gap-4">
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
              </div>

              {/* Campos de Entrega - Obrigatórios para encomendas */}
              {formData.tipo === "encomenda" && (
                <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                  <h4 className="font-medium text-blue-900 mb-3">Detalhes da Encomenda</h4>
                  <div className="grid grid-cols-2 gap-4">
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
                  </div>
                  <div className="mt-4">
                    <Label htmlFor="observacoes_producao">Observações para Produção</Label>
                    <Textarea
                      id="observacoes_producao"
                      value={formData.observacoes_producao}
                      onChange={(e) => handleChange('observacoes_producao', e.target.value)}
                      placeholder="Instruções específicas para a produção..."
                      rows={3}
                    />
                  </div>
                </div>
              )}

              <div className="grid grid-cols-2 gap-4">
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
              </div>

              <div>
                <Label htmlFor="address">Endereço de Entrega</Label>
                <Textarea
                  id="address"
                  value={formData.address}
                  onChange={(e) => handleChange('address', e.target.value)}
                  placeholder="Endereço completo para entrega..."
                  rows={3}
                />
              </div>

              <div>
                <Label htmlFor="notes">Observações Gerais</Label>
                <Textarea
                  id="notes"
                  value={formData.notes}
                  onChange={(e) => handleChange('notes', e.target.value)}
                  placeholder="Observações adicionais..."
                  rows={3}
                />
              </div>
            </div>

            <div className="space-y-4">
              <OrderItems
                items={formData.items}
                onItemsChange={(items) => setFormData(prev => ({ ...prev, items }))}
                tipoPedido={formData.tipo}
              />
              
              <div className="bg-gray-50 p-4 rounded-lg">
                <div className="flex justify-between items-center text-lg font-bold">
                  <span>Total:</span>
                  <span>R$ {total.toFixed(2)}</span>
                </div>
                {formData.tipo === "encomenda" && (
                  <p className="text-sm text-blue-600 mt-2">
                    💡 Encomenda: Os produtos serão produzidos após aprovação
                  </p>
                )}
              </div>
            </div>
          </div>

          <div className="flex justify-end space-x-2">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancelar
            </Button>
            <Button type="submit">
              {order ? 'Atualizar' : 'Criar'} Pedido
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
