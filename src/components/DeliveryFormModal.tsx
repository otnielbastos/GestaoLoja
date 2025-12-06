
import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Delivery } from "@/hooks/useDeliveries";

interface DeliveryFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (delivery: Omit<Delivery, 'id'>) => void;
  delivery?: Delivery;
}

const statusOptions = ["Pendente", "A caminho", "Entregue", "Não entregue"];

const deliveryPersons = [
  "Carlos Santos",
  "Roberto Lima",
  "Fernando Oliveira",
  "Ana Costa",
  "Pedro Silva"
];

const paymentMethods = [
  "Dinheiro",
  "Cartão na entrega",
  "PIX",
  "Cartão de Crédito",
  "Cartão de Débito"
];

export function DeliveryFormModal({ isOpen, onClose, onSubmit, delivery }: DeliveryFormModalProps) {
  const [formData, setFormData] = useState({
    orderId: "",
    customer: "",
    phone: "",
    address: "",
    neighborhood: "",
    deliveryPerson: "",
    status: "Pendente" as Delivery['status'],
    estimatedTime: "",
    total: "",
    paymentMethod: "",
    notes: "",
    deliveryDate: "",
  });

  useEffect(() => {
    if (delivery) {
      setFormData({
        orderId: delivery.orderId,
        customer: delivery.customer,
        phone: delivery.phone,
        address: delivery.address,
        neighborhood: delivery.neighborhood,
        deliveryPerson: delivery.deliveryPerson,
        status: delivery.status,
        estimatedTime: delivery.estimatedTime,
        total: delivery.total.toString(),
        paymentMethod: delivery.paymentMethod,
        notes: delivery.notes || "",
        deliveryDate: delivery.deliveryDate || "",
      });
    } else {
      const now = new Date();
      setFormData({
        orderId: "",
        customer: "",
        phone: "",
        address: "",
        neighborhood: "",
        deliveryPerson: "",
        status: "Pendente",
        estimatedTime: "",
        total: "",
        paymentMethod: "",
        notes: "",
        deliveryDate: now.toISOString().split('T')[0],
      });
    }
  }, [delivery, isOpen]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const deliveryData: Omit<Delivery, 'id'> = {
      orderId: formData.orderId,
      customer: formData.customer,
      phone: formData.phone,
      address: formData.address,
      neighborhood: formData.neighborhood,
      deliveryPerson: formData.deliveryPerson,
      status: formData.status,
      estimatedTime: formData.estimatedTime,
      total: parseFloat(formData.total),
      paymentMethod: formData.paymentMethod,
      notes: formData.notes,
      deliveryDate: formData.deliveryDate,
    };

    onSubmit(deliveryData);
    onClose();
  };

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-md max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {delivery ? 'Editar Entrega' : 'Nova Entrega'}
          </DialogTitle>
          <DialogDescription>
            {delivery ? 'Edite as informações da entrega abaixo.' : 'Preencha as informações para criar uma nova entrega.'}
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="orderId">ID do Pedido *</Label>
              <Input
                id="orderId"
                value={formData.orderId}
                onChange={(e) => handleChange('orderId', e.target.value)}
                placeholder="#001"
                required
              />
            </div>
            <div>
              <Label htmlFor="deliveryDate">Data da Entrega</Label>
              <Input
                id="deliveryDate"
                type="date"
                value={formData.deliveryDate}
                onChange={(e) => handleChange('deliveryDate', e.target.value)}
              />
            </div>
          </div>

          <div>
            <Label htmlFor="customer">Cliente *</Label>
            <Input
              id="customer"
              value={formData.customer}
              onChange={(e) => handleChange('customer', e.target.value)}
              required
            />
          </div>

          <div>
            <Label htmlFor="phone">Telefone *</Label>
            <Input
              id="phone"
              value={formData.phone}
              onChange={(e) => handleChange('phone', e.target.value)}
              required
            />
          </div>

          <div>
            <Label htmlFor="address">Endereço *</Label>
            <Input
              id="address"
              value={formData.address}
              onChange={(e) => handleChange('address', e.target.value)}
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="neighborhood">Bairro *</Label>
              <Input
                id="neighborhood"
                value={formData.neighborhood}
                onChange={(e) => handleChange('neighborhood', e.target.value)}
                required
              />
            </div>
            <div>
              <Label htmlFor="estimatedTime">Horário Previsto *</Label>
              <Input
                id="estimatedTime"
                type="time"
                value={formData.estimatedTime}
                onChange={(e) => handleChange('estimatedTime', e.target.value)}
                required
              />
            </div>
          </div>

          <div>
            <Label htmlFor="deliveryPerson">Entregador *</Label>
            <Select value={formData.deliveryPerson} onValueChange={(value) => handleChange('deliveryPerson', value)}>
              <SelectTrigger>
                <SelectValue placeholder="Selecione o entregador" />
              </SelectTrigger>
              <SelectContent>
                {deliveryPersons.map((person) => (
                  <SelectItem key={person} value={person}>
                    {person}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="status">Status *</Label>
              <Select value={formData.status} onValueChange={(value) => handleChange('status', value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {statusOptions.map((status) => (
                    <SelectItem key={status} value={status}>
                      {status}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="total">Total (R$) *</Label>
              <Input
                id="total"
                type="number"
                step="0.01"
                min="0"
                value={formData.total}
                onChange={(e) => handleChange('total', e.target.value)}
                required
              />
            </div>
          </div>

          <div>
            <Label htmlFor="paymentMethod">Método de Pagamento *</Label>
            <Select value={formData.paymentMethod} onValueChange={(value) => handleChange('paymentMethod', value)}>
              <SelectTrigger>
                <SelectValue placeholder="Selecione o método" />
              </SelectTrigger>
              <SelectContent>
                {paymentMethods.map((method) => (
                  <SelectItem key={method} value={method}>
                    {method}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div>
            <Label htmlFor="notes">Observações</Label>
            <Textarea
              id="notes"
              value={formData.notes}
              onChange={(e) => handleChange('notes', e.target.value)}
              placeholder="Observações sobre a entrega..."
              rows={3}
            />
          </div>

          <div className="flex gap-2 pt-4">
            <Button type="button" variant="outline" onClick={onClose} className="flex-1">
              Cancelar
            </Button>
            <Button type="submit" className="flex-1 bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700">
              {delivery ? 'Salvar' : 'Criar'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
